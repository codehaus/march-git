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

require 'fileutils'

def xmllib
  File.dirname(__FILE__) + '/../lib'  
end

def prepare(t, environment)
  t.ruby_opts << "-rtest/unit/ui/xml/testrunner"
  t.options = "--runner=xml"
  t.libs << "test"
  t.libs << xmllib
  t.pattern = "test/#{environment}/**/*_test.rb"
  t.verbose = false
end

desc 'Test all units and functionals'
namespace :test do
  task :xml   do
    ENV['XMLTEST_OUTPUT'] = 'TEST-unit.xml'
    Rake::Task["test:units:xml"].invoke       rescue got_error = true
    ENV['XMLTEST_OUTPUT'] = 'TEST-functional.xml'
    Rake::Task["test:functionals:xml"].invoke rescue got_error = true
  
    if File.exist?("test/integration")
      ENV['XMLTEST_OUTPUT'] = 'TEST-integration.xml'
      Rake::Task["test:integration:xml"].invoke rescue got_error = true
    end

    exit(1) if got_error
  end
end

namespace :test do
  namespace :units do
  desc "Run the unit tests in test/unit"
    Rake::TestTask.new(:xml => "db:test:prepare") do |t|
      prepare(t, 'unit')
    end
  end
end


namespace :test do
  namespace :functionals do
    desc "Run the functional tests in test/functional"
    Rake::TestTask.new(:xml => "db:test:prepare") do |t|
      prepare(t, 'functional')
    end
  end
end

namespace :test do
  namespace :integration do
    desc "Run the integration tests in test/functional"
    Rake::TestTask.new(:xml => "db:test:prepare") do |t|
      prepare(t, 'integration')
    end
  end
end
