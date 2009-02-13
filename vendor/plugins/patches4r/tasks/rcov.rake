################################################################################
#  Copyright (c) 2004-2007, by OpenXource, LLC. All rights reserved.           #
#                                                                              #
#  THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF OPENXOURCE                   #
#                                                                              #
#  The copyright notice above does not evidence any                            #
#  actual or intended publication of such source code.                         #
################################################################################

require 'rcov/rcovtask'

desc 'Generates a standard set of coverage notes'
Rcov::RcovTask.new(:coverage) do |t|
  t.test_files = FileList.new("test/**/*_test.rb")
  t.verbose = false
  t.rcov_opts = []
  t.rcov_opts << '-i ".*test.rb"'
  t.rcov_opts << "--rails"
  t.rcov_opts << "--sort coverage"
  t.rcov_opts << "--only-uncovered"
  t.output_dir = "./tmp/coverage"
end

  
#task :rcov => [:environment] do |t|
#  rcov `find test -name '*.rb'` --threshold 100 --sort coverage
#  dir = File.expand_path(File.dirname(__FILE__) + '/../../../../')
#  rcov_cmd = "rcov -o 'tmp/coverage' --rails --threshold 100 --sort coverage"
#  system(rcov_cmd)
#end
