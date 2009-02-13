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

# Every request into the core controller has a root which determines the base of all processing, and a path
# the path is ALWAYS in the subscope of the root.
# It is illegal to make requests with no root (developers should set up shortcuts)
class March::Pather

  GROUP_ACTIONS   = [ '~search', '~activity', '~latest', '~info' ]
  LIST_ACTIONS    = [ 'rss', '~search', '~activity', '~latest', '~info', '~charts', '~charts_xml' ]
  MESSAGE_ACTIONS = [ ]
  PART_ACTIONS    = [ '~download' ]
  
  attr_accessor :root
  attr_accessor :root_group
  attr_accessor :target #This is the target you specifically asked for
  attr_accessor :best_target #This is the best target we could fine
  attr_accessor :action
  attr_accessor :action_segments
  

  def to_s
    "Pather[target=#{target}, action=#{action}, action_segments=#{action_segments}]"
  end
  
  def initialize(root, path, debug = false)
    begin
    #Makes using March without mod_rewrite in front possible. 
    root = 'haus' if RAILS_ENV == 'development' && root == nil
    
    path ||= []
    
    self.root = root
    self.root_group = find_group(root)
    logger.debug { "root: #{root} path: #{path.inspect}"}
    segments = path.dup
    logger.debug { "segments: #{segments.inspect}" }
    if segments.empty?
      self.target = self.root_group
      return
    end

    current = self.root_group    
    last_current = current
    
    while ( ! segments.empty? )
      next_segment = segments.shift
      logger.trace { " #{next_segment}" } 
      if ( next_segment =~ /^\~/ )
        #Actions start with ~
      end
      logger.trace { "At #{current}, looking for #{next_segment.inspect}" }
      case ( current )
        when Group
          if GROUP_ACTIONS.include?( next_segment )
            self.action = next_segment.to_sym
            strip_action_tilde
            self.action_segments = segments
            break
          end

          tmp = current.children.find_by_key( next_segment )
          if not tmp
            logger.debug { "looking for list with key #{next_segment}" }
            tmp = current.lists.find_by_key( next_segment )
            logger.debug { "found #{tmp} from #{List.count()} lists" }
          end
          
          current = tmp
        when List
          if LIST_ACTIONS.include?( next_segment )
            self.action = next_segment.to_sym
            strip_action_tilde
            self.action_segments = segments
            break
          end
          current = Message.find_by_list_id_and_message_id822( current.id, Message.normalize_message_id822(next_segment) )
        when Message
          part_index = next_segment.to_i
          logger.debug { "Part_index: #{next_segment} / #{part_index}" }
          if part_index < 0 || part_index > current.parts.length
            self.target = nil
            self.best_target = current
          end
          current = current.parts[part_index]
        when Part
          if PART_ACTIONS.include?( next_segment )
            self.action = next_segment.to_sym
            strip_action_tilde
            self.action_segments = segments
            break
          end
      end

      logger.debug { "Current: #{current} / Last Current: #{last_current}" }
      if not current
        self.target = nil
        self.best_target = last_current
        return
      else
        last_current = current
      end
    end

    self.target = current
    self.best_target = current
    ensure
      logger.debug { "Completed configuring the pather" }
      logger.debug { "segments: #{segments.inspect}"}
    end
  end
  
  def strip_action_tilde()
    self.action = self.action.to_s[1..-1].to_sym if self.action.to_s[0..0] == '~'
  end
  
  
  def target_group
    
    case target
      when Group
        return target
      when List 
        return target.group
      when Message
        return target.list.group
      else
        return root_group
    end
    
  end
  
  def target_search

    case target
      when Group
        return target
      when List 
        return target
      when Message
        return target.list
    end
    
    return nil
  end
          
      
private
  def find_group(root)
    if not root
      raise Exception.new("null root")
    end
    
    return Group.find_by_path(root)
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
    
end
