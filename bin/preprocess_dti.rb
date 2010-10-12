#!/usr/bin/env ruby
## A command-line DTI-preprocessing script generation utility.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'yaml'
require 'optparse'
begin
  require 'dtitask'
rescue LoadError
  require 'rubygems'
  require 'dtitask'
end

=begin rdoc
This library provides basic processing for Diffusion Tensor Images (DTI)
This command-line processing script takes raw DTI dicoms and outputs FA, MD &
associated diffusion maps (eigenvalues & eigenvectors).

Currently, the script assumes raw data are unzipped and the output directory
exists, the glob and DTI params are passed in with a specification file.
=end


def run!
  # Parse CLI Options and Spec File
  options = parse_options
  config = load_spec(options[:spec_file])
  config.merge!(options)
  
  # Create a DTI Preprocessing Flow Task and run it.
  output_directory = ARGV.pop
  input_directories = ARGV
  input_directories.each do |input_directory|
    task = Dtitask.new(config)
    task.reconstruct!(input_directory, output_directory)
  end
end


def load_spec(spec_file)
  if File.exist?(spec_file)
    spec = YAML::load_file(spec_file)
  else
    raise IOError, "Cannot find yaml spec file #{spec_file}"
  end
  
  return spec
end


def parse_options
  options = Hash.new
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options] input_directory output_directory"

    opts.on('-s', '--spec SPEC', "Spec File for script parameters")     do |spec_file| 
      options[:spec_file] = spec_file
    end
    
    opts.on('-p', '--prefix PREFIX', "Filename Prefix")     do |prefix| 
      options[:file_prefix] = prefix
    end

    opts.on('-d', '--dry-run', "Display Script without executing it.") do
      options[:dry_run] = true
    end

    opts.on('-f', '--force', "Overwrite output directory if it exists.") do
      options[:force_overwrite] = true
    end
    
    opts.on('-m', '--mask MASK', "Add an arbitrary mask to apply to data.") do |mask|
      options[:mask] = File.expand_path(mask)
      abort "Cannot find mask #{mask}." unless (File.exist?(options[:mask]) || options[:dry_run])
    end
    
    opts.on('-t', '--tmp', "Sandbox the input directory in the case of zipped dicoms.") do
      options[:force_sandbox] = true
    end
    
    opts.on('--values VALUES_FILE', "Specify a b-values file.") do |bvalues_file|
      options[:bvalues_file] = bvalues_file
    end
        
    opts.on('--vectors VECTORS_FILE', "Specify a b-vectors file.") do |bvectors_file|
      options[:bvectors_file] = bvectors_file
    end
    

    opts.on_tail('-h', '--help',          "Show this message")          { puts(parser); exit }
    opts.on_tail("Example: #{File.basename(__FILE__)} -s configuration/dti_spec.yaml -p pd006 raw/pd006 orig/pd006")
  end
  parser.parse!(ARGV)

  if ARGV.size == 0
    # puts "Problem with arguments: #{ARGV}"
    puts(parser); exit
  end
  
  return options
end


if __FILE__ == $0
  run!
end
