################################################################################
#  Copyright 2007-2008 Codehaus Foundation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

require 'pathname'

require 'openid'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'


class AuthController < ApplicationController
  layout nil

  def start
    puts "Logging request uri of #{request.request_uri}"
    session[:request_uri] = request.referer
    begin
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:errors] << "Enter an OpenID identifier"
        redirect_chain
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:errors] << "Discovery failed for #{identifier}: perhaps you need to enter a full domain name"
      puts e
      redirect_chain
      return
    end
    params[:use_sreg] = true
    if params[:use_sreg]
      sregreq = OpenID::SReg::Request.new
      # required fields
      sregreq.request_fields(['email','nickname'], false)
      # optional fields
      sregreq.request_fields(['dob', 'fullname'], false)
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    end
    if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 2*60*60
      oidreq.add_extension(papereq)
      oidreq.return_to_args['did_pape'] = 'y'
    end
    if params[:force_post]
      oidreq.return_to_args['force_post']='x'*2048
    end
    return_to = url_for :action => 'complete', :only_path => false
    realm = url_for :action => 'index', :only_path => false
    
    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  def complete
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
    when OpenID::Consumer::FAILURE
      if oidresp.display_identifier
        flash[:error] = ("Verification of #{oidresp.display_identifier}"\
                         " failed: #{oidresp.message}")
      else
        flash[:error] = "Verification failed: #{oidresp.message}"
      end
    when OpenID::Consumer::SUCCESS
      flash[:success] = ("Verification of #{oidresp.display_identifier}"\
                         " succeeded.")
      @user = User.find_or_create_by_identifier(oidresp.display_identifier)
      set_current_user(@user)
      
      #Update the registration information from the OpenID provider
      if params[:did_sreg]
        sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
        sreg_resp.data.each {|k,v|
          puts "OpenID SReg: #{k} = #{v}"
          @user.nickname = v if k == 'nickname'
          @user.fullname = v if k == 'fullname'
        }
        @user.save!
        
      end
      
      if params[:did_pape]
        pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
        pape_message = "A phishing resistant authentication method was requested"
        if pape_resp.auth_policies.member? OpenID::PAPE::AUTH_PHISHING_RESISTANT
          pape_message << ", and the server reported one."
        else
          pape_message << ", but the server did not report one."
        end
        if pape_resp.auth_time
          pape_message << "<br><b>Authentication time:</b> #{pape_resp.auth_time} seconds"
        end
        if pape_resp.nist_auth_level
          pape_message << "<br><b>NIST Auth Level:</b> #{pape_resp.nist_auth_level}"
        end
        flash[:pape_results] = pape_message
      end
    when OpenID::Consumer::SETUP_NEEDED
      flash[:errors] << "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:errors] << "OpenID transaction cancelled."
    else
    end
    @user.save! if @user
    request_uri = session[:request_uri]
    session[:request_uri] = nil
    return redirect_chain(request_uri)
  end
  
  def logout
    clear_current_user
    flash[:notices] << 'You have been logged out'
    return redirect_chain
  end

private 
  
  def redirect_chain(uri = nil)
    if uri
      redirect_to uri
    elsif request.referer
      redirect_to request.referer
    else
      redirect_to :controller => 'home', :action => 'index'
    end
  end

  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('tmp').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
