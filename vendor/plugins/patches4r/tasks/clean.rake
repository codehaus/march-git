require 'fileutils'

def clean()
  base = File.dirname(__FILE__) + '/../../../..'
  FileUtils.rm_rf(Dir.glob("#{base}/log/*"))  
  FileUtils.rm_rf(Dir.glob("#{base}/target/*"))
  FileUtils.rm_rf(Dir.glob("#{base}/tmp/*"))
end

desc 'Cleans out temporary files'
task :clean => [:environment] do |t|
  clean
end
