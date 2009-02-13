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

module FormatHelper

  def format_date(date,link=false)
    text = date.utc.strftime( "%l:%M %p, %A %e %B %Y" ).gsub( /\s+/, ' ').gsub( ' ', '&#160;' )
    return text unless link
    link_to text, url_for_date( date ), { :title => 'go to timezone conversion chart' }
  end

  def format_date_short(date,link=false)
    if Time.new - date.utc < 86400
      text = date.utc.strftime( "%H:%M" ).gsub( ' ', '&#160;' )
    else
      text = date.utc.strftime( "%d %b %Y" ).gsub( /\s+/, ' ').gsub( ' ', '&#160;' )
    end
    
    if link
      return link_to(text, url_for_date( date ), { :title => 'go to timezone conversion chart' })
    else
      return text
    end
  end
  
  def url_for_date(date)
    date.utc.strftime( "http://www.timeanddate.com/worldclock/fixedtime.html?month=%m&amp;day=%e&amp;year=%Y&amp;hour=%l&amp;min=%M&amp;sec=0" )
  end
  
  def format_email(message)
    mail_hide(message.from_address, message.from_name)
  end
  
  def format_size(length)
    return "unknown" if not length or length == -1
    return sprintf("%2.2f mbytes", length/1024.0/1024.0 ) if length > 1024 * 1024 * 5
    return sprintf("%2.2f kbytes", length/1024.0 ) if length > 1024 * 5
    return sprintf("%d bytes", length )
  end


end
