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

class GestaltController < ApplicationController
  #before_filter :filter_setup_march_context
  attr_reader :pather
  
  def index
    @group = pather.target
  end
  
  def profile
    id = request.env['SERVER_PORT']
    MemoryProfiler.start( :id => id )
    render :text => "profiler started : #{id}", :layout => false
  end

  def profile_with_strings
    id = request.env['SERVER_PORT']
    MemoryProfiler.start(:string_debug => true, :id => id)
    render :text => "profiler started (with strings) : #{id}", :layout => false
  end
  
  def pop_message
    do_pop(1)
    render 'gestalt/pop_messages'
  end

  def pop_messages
    do_pop(10000)
    render 'gestalt/pop_messages'
  end
  
  
  def scan_objectspace
    text = ""
    # trying to see where our memory is going
    population = Hash.new{|h,k| h[k] = [0,0]}
    array_sizes = Hash.new{|h,k| h[k] = 0}
    ObjectSpace.each_object do |object|
      # rough estimates, see http://eigenclass.org/hiki.rb?ruby+space+overhead
      size = case object 
             when Array
               array_sizes[object.size / 10] += 1
               case object.size
               when 0..16
                 20 + 64
               else
                 20 + 4 * object.size * 1.5
               end
             when Hash;    40 + 4 * [object.size / 5, 11].max + 16 * object.size
             when String;  30 + object.size
             else 120 # the iv_tbl, etc
             end
      count, tsize = population[object.class] 
      population[object.class] = [count + 1, tsize + size]
    end

    population.sort_by{|k,(c,s)| s}.reverse[0..10].each do |klass, (count, bytes)|
      text << "%-20s  %7d  %9d\n" % [klass, count, bytes]
    end

    text << "Array sizes:\n"
    array_sizes.sort.each{|k,v| text << "%5d  %6d\n" % [k * 10, v]}
      
    render :text => text, :content_type => 'text/plain', :layout => false
  end
  
  
private
  def do_pop(max)
    popper = March::Popper.new( 'tmp/popqueue', :pop_user => March::POP_USERNAME, :pop_pass => March::POP_PASSWORD, :pop_host => March::POP_HOST, :pop_port => March::POP_PORT )
    @messages = []
    popper.pop_messages(:max => 1) { |queue_file|  
      logger.info { "Queue File: #{queue_file}" }
      @messages << queue_file
      importer = March::FileMessageImporter
      importer.import_file(queue_file)
    }
  end
  
end
