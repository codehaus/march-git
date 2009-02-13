#!/usr/bin/env ruby
#
# Copyright (c) 2007, Ben Walding
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
# 
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Original concept found in Systir, though it's now hacked to pieces and doesn't resemble the original.

require 'test/unit/ui/testrunnermediator'
require 'test/unit/ui/testrunnerutilities'
require 'test/unit/ui/console/testrunner'
require 'test/unit/autorunner'
require 'rexml/document'
require 'fileutils'

class MemoryLoggerCore
  
  def initialize
    @lines =[]
  end
  
  def add(type, s)  
    @lines << [type, s]
  end  
  
  def get_and_clear
    tmp_lines = @lines
    @lines = []
    return tmp_lines
  end
  
  def clear
    @lines = []
  end
  
  def to_useful_string
    result = ""
    @lines.each { |line|
      result << "#{line[0]}: #{line[1].chomp}\n"
    }
    return result
    #return result.join
  end
end

class MemoryLogger
  
  def initialize(type, logger, fallback)
    @type = type
    @logger = logger
  end
  
  def write(s)
    @logger.add( @type, s )
  end  
  
  def <<(s)
    @logger.add( @type, s )
  end
  
  def method_missing(name, *args)
    fallback.write("missing: #{name} #{args}")
  end
  
end


module Test
  module Unit
    module UI
      module XML

        class TestRunner < Test::Unit::UI::Console::TestRunner

          def output_file
            ENV['XMLTEST_OUTPUT']
          end
          
          def initialize(suite, output_level=NORMAL, io = nil)
            super(suite)

            @filename = "target/test-reports/#{output_file}"
            FileUtils.mkdir_p( File.dirname( @filename ) )

            @doc = create_document
          end

          def create_document
            decl = REXML::XMLDecl.new
            decl.encoding = 'UTF-8'
            
            doc = REXML::Document.new
            doc << decl
            
            e = REXML::Element.new("testsuite")
            doc << e
            
            return doc
          end

          def start
            @current_test = nil
            # setup_mediator
            @mediator = TestRunnerMediator.new( @suite )
            suite_name = @suite.to_s
            if @suite.kind_of?(Module)
              suite_name = @suite.name
            end
            @doc.root.attributes['name'] = suite_name
            # attach_to_mediator - define callbacks
            @mediator.add_listener( TestResult::FAULT, 
                                    &method(:add_fault) )
            @mediator.add_listener( TestRunnerMediator::STARTED,
                                    &method(:started) )
            @mediator.add_listener( TestRunnerMediator::FINISHED,
                                    &method(:finished) )
            @mediator.add_listener( TestCase::STARTED, 
                                    &method(:test_started) )
            @mediator.add_listener( TestCase::FINISHED, 
                                    &method(:test_finished) )
            # return start_mediator
            
            @default_stdout = $stdout
            @default_stderr = $stderr

            @default_stdout.write("Attaching stdout monitor\n")
            @logger = MemoryLoggerCore.new
            $stdout = MemoryLogger.new(:stdout, @logger, @default_stderr)
            $stderr = MemoryLogger.new(:stderr, @logger, @default_stderr)
            
            return @mediator.run_suite
          end

          # TestResult::FAULT
          def add_fault( fault )
            @faults << fault
            e = REXML::Element.new( "failure" )
            e.attributes['message'] = fault.message
            e.attributes['type'] = fault.class.name
            e << REXML::CData.new( fault.long_display ) 
            e << REXML::CData.new( @logger.to_useful_string)
            @logger.clear
            @current_test << e
          end

          # TestRunnerMediator::STARTED
          def started( result )
            @result = result
          end

          # TestRunnerMediator::FINISHED
          def finished( elapsed_time )
            @doc.root.attributes['errors'] = @result.error_count
            @doc.root.attributes['failures'] = @result.failure_count
            @doc.root.attributes['tests'] = @result.run_count
            @doc.root.attributes['time'] = sprintf("%2.4f", elapsed_time)

            @doc.root << REXML::Element.new( "properties")
            @doc.root << REXML::Element.new( "system-out")
            @doc.root << REXML::Element.new( "system-err")

            File.open( @filename, "w" ) { |io|
              io.puts( @doc.to_s )
            }
     
            @default_stdout.write("Detaching stdout monitor\n")
            $stdout = @default_stdout
            $stderr = @default_stderr
          end
          
          def test_started( name )
            @test_started_time = Time.now
            @default_stderr.write("#{name} running...\n")
            e = REXML::Element.new( "testcase" )
            
            pieces = split_name(name)
            e.attributes['classname'] = pieces[0]
            e.attributes['name'] = pieces[1]
            e.attributes['time'] = '0.0000'
            @doc.root << e
            @current_test = e
          end
          
          #Given method(class), returns [ class, method ]
          def split_name(name)
            name =~ /^(.*)\((.*)\)$/
            return [ $2, $1 ]
          end

          def test_finished( name )
            @test_finished_time = Time.now
            @current_test.attributes['time'] = sprintf( "%2.4f", (@test_finished_time.to_f - @test_started_time.to_f) )
            
            @current_test = nil
            pieces = split_name(name)
            test = find_test(pieces[0], pieces[1])
          end
          
          def find_suite( suite, suite_name)
            suite.tests.each { | test | 
              return test if test.name == suite_name
              if test.is_a?(Test::Unit::TestSuite)
                result = find_suite(test, suite_name)
                return result if result
              end
            }
            return nil
          end
          
          def find_method( suite, method_name )
            for test in suite.tests
              return test if test.method_name == method_name
            end
            return nil
          end
          
          def find_test( class_name, method_name )
            #puts "Searching #{@suite.to_s} for #{class_name}.#{method_name}"
            suite = find_suite(@suite, class_name)
            return nil unless suite
            return find_method(suite, method_name)
          end
          
          def dump_suite_hierarchy()
            puts "*" * 80
            dump_suite_hierarchy_internal(@suite)
            puts "*" * 80
          end
          
          def dump_suite_hierarchy_internal(suite, indent = '')
            if suite.is_a?(Test::Unit::TestSuite)
              puts "#{indent}SUITE: #{suite.name}"
              for test in suite.tests
                dump_suite_hierarchy_internal(test, indent + '  ')
              end
              return
            elsif suite.is_a?(Test::Unit::TestCase)
              puts "#{indent}TEST: #{suite.class.name}.#{suite.method_name}"
              return
            else
              puts "#{indent}UNKNOWN: #{suite.class.name}  #{suite}"
              c = suite.class
              while c
                puts "#{indent}  #{c.name}"
                c = c.superclass
              end
              return
            end
          end

        end
      end
    end
  end
end


Test::Unit::AutoRunner::RUNNERS[:xml] = proc do |r|
  Test::Unit::UI::XML::TestRunner
end
