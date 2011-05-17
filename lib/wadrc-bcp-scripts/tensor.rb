module WadrcBcpScripts

# A class for manipulating Tensor info for DTI.
class Tensor
  attr_accessor :data
  
  def initialize(filepath)
    @data = []
    open(filepath, 'r').each do |line|
      @data << line.split(/[\,\:\s]+/).each { |val| val.strip }
    end
  end
  
  # Write out Data to a file.
  def to_fsl_txt(output_file = 'out.txt')
    puts "Writing " + output_file
    open(output_file, 'w') do |file|
      @data.transpose.each do |line|
        file.puts line.join(' ')
      end
    end
  end
end

end