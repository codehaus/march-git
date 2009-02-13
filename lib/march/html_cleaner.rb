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
#  Much code borrowed from FeedTools                                           #
#      http://rubyforge.org/projects/feedtools/ (MIT licence)                  #
################################################################################
require 'tidy'
require 'rexml/document'

class March::HtmlCleaner
  
  ACCEPTABLE_ELEMENTS = ['a', 'abbr', 'acronym', 'address', 'area', 'b',
          'big', 'blockquote', 'br', 'button', 'caption', 'center', 'cite',
          'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'dir', 'div', 'dl',
          'dt', 'em', 'fieldset', 'font', 'form', 'h1', 'h2', 'h3', 'h4',
          'h5', 'h6', 'hr', 'i', 'img', 'input', 'ins', 'kbd', 'label', 'legend',
          'li', 'map', 'menu', 'ol', 'optgroup', 'option', 'p', 'pre', 'q', 's',
          'samp', 'select', 'small', 'span', 'strike', 'strong', 'sub', 'sup',
          'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'tr', 'tt',
          'u', 'ul', 'var']
  
  ACCEPTABLE_ATTRIBUTES = ['abbr', 'accept', 'accept-charset', 'accesskey',
         'action', 'align', 'alt', 'axis', 'border', 'cellpadding',
         'cellspacing', 'char', 'charoff', 'charset', 'checked', 'cite', 'class',
         'clear', 'cols', 'colspan', 'color', 'compact', 'coords', 'datetime',
         'dir', 'disabled', 'enctype', 'for', 'frame', 'headers', 'height',
         'href', 'hreflang', 'hspace', 'id', 'ismap', 'label', 'lang',
         'longdesc', 'maxlength', 'media', 'method', 'multiple', 'name',
         'nohref', 'noshade', 'nowrap', 'prompt', 'readonly', 'rel', 'rev',
         'rows', 'rowspan', 'rules', 'scope', 'selected', 'shape', 'size',
         'span', 'src', 'start', 'summary', 'tabindex', 'target', 'title', 'style',
         'type', 'usemap', 'valign', 'value', 'vspace', 'width']
  
  def clean(html)
    #First pass gets rid of a lot of crap you get in Office documents (see test harness cases 06, 07)
    Tidy.open(:output_xhtml => true, :quiet => true, :show_body_only => true) do |tidy|
      html = "<html><body>\n" + tidy.clean(html) + "</body></html>"
    end

    #Get rid of all the other crap
    Tidy.open(:output_xml => true) do |tidy|
      html = tidy.clean(html)
    end
    
    return clean_xml(html)  
  end
  
  def strip_ifs(xml)
    xml.gsub!(Regexp.new('<!\\[if [^\\]]+\\]>'), '')
    xml.gsub!(Regexp.new('<!\\[endif\\]>'), '')
    return xml
  end
  
  def clean_xml(xml)
    xml = strip_ifs(xml)
    
    html_doc = REXML::Document.new(xml)
    
    root = html_doc.root
    
    body = root.elements["/html/body"]
    if body
      #puts "Stripping off html/body"
      root = body
      #change it to a div
      root.name = "div"
      root.add_attribute('class', 'clean')
    end
    
    sanitize_node = lambda do |html_node|
      if html_node.respond_to? :children
        #puts "looking at children of #{html_node}"
        for child in html_node.children
          if child.kind_of? REXML::Element
            #puts "Checking #{child.name}"
            unless ACCEPTABLE_ELEMENTS.include? child.name.downcase
              html_node.delete_element(child)
            end 
            child.attributes.each_attribute do |attribute|
              if !(attribute.name =~ /^xmlns(:.+)?$/)
                unless ACCEPTABLE_ATTRIBUTES.include?(attribute.name.downcase)
                  #puts "Deleting attribute: #{attribute.name}"
                  child.delete_attribute(attribute.name)
                end 
              end 
            end 
            
            child.add_attribute('rel', 'nofollow') if child.name.downcase == 'a'
          end 
          sanitize_node.call(child)
        end 
      end 
      html_node
    end 
    sanitize_node.call(root)
    clean_xml = ''
    
    formatter = REXML::Formatters::Default.new
    
    formatter.write(root, clean_xml)
    return clean_xml
    
  end
  
end
