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

# =============================================================================
# A set of rake tasks for invoking the Capistrano automation utility.
# =============================================================================

# Invoke the given actions via Capistrano
def cap(*parameters)
  begin
    require 'rubygems'
  rescue LoadError
    # no rubygems to load, so we fail silently
  end

  require 'capistrano/cli'

  Capistrano::CLI.new(parameters.map { |param| param.to_s }).execute!
end

namespace :remote do
  desc "Backup DB."
  task(:backup_db) { cap :backup_db }
end

