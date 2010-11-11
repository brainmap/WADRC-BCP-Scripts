$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'optparse'
require 'tensor'

def run!
  # Parse CLI Options and Spec File
  options = parse_options

  # Create a DTI Preprocessing Flow Task and run it.
  tensor = Tensor.new(options[:tensor_file])
  tensor.to_fsl_txt(options[:output_file])

end

def parse_options
  options = Hash.new
  
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options] input_tensor output_transposed_tensor"

    # opts.on('-t', '--tensor TENSOR_FILE', "Tensor File.")     do |tensor_file| 
    #   options[:tensor_file] = tensor_file
    # end
    
    opts.on_tail('-h', '--help',          "Show this message")          { puts(parser); exit }
    opts.on_tail("Example: #{File.basename(__FILE__)} 40_direction.txt 40_direction_transposed.txt")
  end
  parser.parse!(ARGV)

  options[:tensor_file] = ARGV[0]
  options[:output_file] = ARGV[1]  

  unless ARGV.size == 2
    puts(parser); exit
  end

  return options
end


if File.basename(__FILE__) == File.basename($0)
  run!
end
