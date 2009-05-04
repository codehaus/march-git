################################################################################
#  Copyright 2006-2009 Codehaus Foundation
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

require 'recaptcha'

module ApplicationHelper
  include March::Authentication
  include LinkHelper
  include FormatHelper
  include RenderHelper
  include RedactHelper
  include BreadcrumbHelper
  include ReCaptcha::ViewHelper
  
  attr_accessor :image_header
  
  def target
    return @target
  end
  
  def evenodd
    if not defined?(@evenodd)
      @evenodd = EvenOdd.new
    end
    return @evenodd
  end
  
  def latest_id
    if not defined?(@latest_id) or @latest_id.nil?
      @latest_id = Message.maximum(:id)
    end
    return @latest_id
  end
  
  def today_yyyymmdd
    return Time.new.strftime('%Y%m%d')
  end
  
  def selector(value, value_zero, value_one, value_many)
    return value_zero if value == 0 or value == nil
    return value_one if value == 1
    return value_many
  end

  def march_root
    @march_root
  end

  def march_root_group
    @march_root_group
  end

  def march_path
    @march_path
  end

  attr_reader :page_title
  
  def set_page_title(page_title)
    @page_title = h(page_title)
  end

  def header_link_to(text, page_controller)
    #if '/' + controller.controller_path == page_controller
    #  link_to text, page_controller, :class => 'selected'
    #else
      link_to text, page_controller
    #end
  end
  
  def get_navigation_menu
    menu = {}
    
    menu[:home] = []

    menu[:recent] = []
    menu[:recent] << {
      :text => 'Latest messages',
      :url  => url_for_target(@target, :latest)
    }
    
    menu[:lists] = []
    if @group
      for list in @group.recently_active(10)
        menu[:lists] << {
          :text => list.address,
          :url  => url_for_target(list)
        }
      end
    end
    
    if current_user?
      menu[:my] = []
      for favorite in current_user.favorites
        menu[:my] << {
          :text => favorite.target.name,
          :url => url_for_target(favorite.target)
        }
      end
    end
    return menu
  end  
  
  
  
  def image_link_to(image, text, url, options = {})
    options = [ {} ] if not options
    options = options.first if options.class == Array and options.length == 1
    
    if options.has_key?(:class)
      options[:class] = options[:class] + ' image-link'
    end
    
    if url
      link_to( image_tag(image) + '&#160;' + text, url, options )
    else
      xm = Builder::XmlMarkup.new
      
      xm.span( options ) {
        xm << image_tag(image) + '&#160;' + text
      }
    end
  end
  
  def render_chart(*options)
     options = options.first #To get the hash
     width = options[:width] || 400
     height = options[:height] || 300
     url = options[:url]
     id = options[:id] || 'a-chart'

     render :partial => '/march/chart', 
            :locals => { :chart_url => url, :width => width, :height => height, :id => id }
   end
   
   def render_favorite_icon(target)
     if current_user
       render :partial => '/favorites/favorite_icon_wrapper', :locals => { :target => target }
     end
   end
   
   def render_ad?(identifier)
     return March::GOOGLE_ADS.has_key?(identifier.to_sym)
   end
   
   def render_ad(identifier)
     return '' if not render_ad?(identifier)
     
     ad = March::GOOGLE_ADS[identifier.to_sym]
     return <<EOF
<div id="ad-#{identifier.to_s}">
<script type="text/javascript"><!--
google_ad_client = "#{ ad[:client] }";
google_ad_slot = "#{ ad[:slot] }";
google_ad_width = #{ ad[:width] || 728 };
google_ad_height = #{ ad[:height] || 90 };
//-->
</script>
<script type="text/javascript" 
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
EOF
   end
   
   
   def render_flash( flash_position = nil )
     if not flash_position or flash_position == @flash_position
       @flash_types = [ :messages, :notices, :warnings, :errors ]
       @flash_var = flash
       render :partial => '/layouts/flash'
     end
   end
   
   def mail_hide_simple(obj)
     from_name = obj.respond_to?(:from_name) ? obj.from_name : nil
     from_address = obj.respond_to?(:from_address) ? obj.from_address : nil
     
     from_address = obj.to_s if from_address.nil?
     from_name = truncate(from_address,10) if from_name.nil?
     
     k = ReCaptcha::MHClient.new(MH_PUB, MH_PRIV)
     enciphered = k.encrypt(from_address)
     uri = "http://mailhide.recaptcha.net/d?k=#{MH_PUB}&c=#{enciphered}"
     
     render :partial => '/core/mailhide', :locals => { :uri => uri, :contents => from_name }
   end
   
   def render_rating(message)
     render( :partial => '/ratings/rating_wrapper', :locals => { :message => message } )
   end

   # Request from an iPhone or iPod touch? (Mobile Safari user agent)
   def iphone_user_agent?
     request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
   end   
end
