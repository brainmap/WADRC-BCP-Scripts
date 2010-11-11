
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "wadrc-bcp-scripts"
    gem.summary = %Q{Basic Common Preprocessing Scripts for Neuroimaging Data}
    gem.description = %Q{Basic Common Preprocessing Scripts for Neuroimaging Data}
    gem.email = "ekk@gmail.com"
    gem.homepage = "http://github.com/brainmap/wadrc-bcp-scripts"
    gem.authors = "Erik Kastman"
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "net-ssh"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
