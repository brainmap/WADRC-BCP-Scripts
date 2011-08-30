# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wadrc-bcp-scripts/version"

Gem::Specification.new do |s|
  s.name = "wadrc-bcp-scripts"
  s.version = WadrcBcpScripts::VERSION

  s.authors = ["Erik Kastman"]
  s.date = "2011-08-30"
  s.summary = "Basic Common Preprocessing Scripts for Neuroimaging Data"
  s.description = "This gem contains scripts for basic preprocessing in the Wisconsin Alzheimer's Disease Research Center Neuroimaging Group"
  s.email = "ekk@medicine.wisc.edu"
  s.homepage = "http://github.com/brainmap/wadrc-bcp-scripts"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'net-ssh', '~>2.2'
  s.add_runtime_dependency 'escoffier', '~>0.1.3'
  s.add_development_dependency 'rspec', "~> 2.5"
  s.add_development_dependency 'factory_girl', "~> 2.0.5"
end

