require 'find'
require 'tmpdir'
require 'fileutils'
require 'rubygems'
require 'metamri'

module Find
  def match(path)
    matched = []
    find(path) do |p|
      if yield p
        if File.file?(p) && File.readable?(path): matched << p; end
      end  
    end    
    return matched
  end
  module_function :match
end

  
class FieldmapTask
  DWELL_TIME = 0.688
  attr_accessor :log
  attr_accessor :incoming_tar_file

  def initialize(incoming_tar_file)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @incoming_tar_file = incoming_tar_file
  end
    
  def setup_paths
    @log.debug { %x[set_default_paths.sh] }
  end
  
  def unpack(incoming_tar_file)
    unpacked_directory = unzip_incoming_tar_file(incoming_tar_file)
    @log.debug { "Unpacked Directory: #{unpacked_directory}"}
    fieldmap_directory = File.join(unpacked_directory, 'fieldmap')
    files_to_fieldmap = Find.match(unpacked_directory) { |f| File.extname(f) == '.nii' }
    @log.debug {"Files to be fieldmapped: #{files_to_fieldmap.each { |file| File.basename(file) } } " }

    return unpacked_directory, fieldmap_directory, files_to_fieldmap
  end
  
  def unzip_incoming_tar_file(incoming_tar_file, output_directory = nil)
    unless output_directory
      # Unless your ruby version is greater than 1.8.7
      # output_directory = Dir.mktmpdir
      output_directory = File.join(Dir.tmpdir, File.basename(@incoming_tar_file, '.tar.gz'))
      Dir.mkdir(output_directory) unless File.exists?(output_directory)
    end
    msg = %x[tar --directory #{output_directory} -xzvf #{incoming_tar_file} ]
    
    return output_directory
  end

  def create_fieldmap(fieldmap_directory, output_file = nil)
    fieldmap_file = output_file ? output_file : 'fmap.nii'
    make_fmap_cmd = "make_fmap #{fieldmap_directory} #{fieldmap_file}"
    @log.info make_fmap_cmd
    system(make_fmap_cmd)
    #@log.info { %x["#{make_fmap_cmd}"] }
    return fieldmap_file
  end

  def apply_fieldmap(fieldmap_file, files_to_fieldmap, output_directory = nil)
    unless output_directory then output_directory = Dir.pwd; end
    p files_to_fieldmap
    fieldmap_correction_cmd = "fieldmap_correction #{fieldmap_file} #{DWELL_TIME} #{output_directory} #{ files_to_fieldmap.join(" ") }"
    @log.info { fieldmap_correction_cmd }
    @log.info { %x[#{fieldmap_correction_cmd}] }

=begin    
    # Pretend fieldmapping works!
    files_to_fieldmap.each do |f| 
      fieldmapped_filename = File.join(File.dirname(f), File.basename(f, '.nii') + '_fm.nii')
      FileUtils.copy(f, fieldmapped_filename) 
      p fieldmapped_filename
    end
=end
  end

  def zip_up_fieldmapped_files(output_name, fieldmapped_files)
    tar_and_zip_cmd = "tar -czvf #{output_name} #{fieldmapped_files.join(" ")}"
    @log.info {tar_and_zip_cmd}
  end
  
  def cleanup(tmpdir)

    output_name='fieldmapped_files.tar.gz'
    
    fieldmapped_files = Find.match(tmpdir) { |f| File.fnmatch('*_fm*', f ) }
    p fieldmapped_files
    zip_up_fieldmapped_files(output_name, fieldmapped_files)
    
    @log.close

  end
  
  
end

class LocalFieldmapSetup
  attr_accessor :prefix
  attr_accessor :files_to_fieldmap_directory
  attr_accessor :dicoms_directory
  
  REMOTE_SCRATCH_DIR = '/scratch/johnson_fieldmaps'
  REMOTE_USER = 'johnson'
  REMOTE_HOST = 'tezpur'
  REMOTE_PROCESSING_HOST = 'jaloro'
  
  def initialize(prefix, files_to_fieldmap_directory, dicoms_directory)
    @prefix = prefix
    @files_to_fieldmap_directory = files_to_fieldmap_directory
    @dicoms_directory = dicoms_directory
  end
  
  def find_fieldmap_directory(dicoms_directory)
    visit = VisitRawDataDirectory.new(dicoms_directory)
    visit.scan
    visit.datasets.each do |ds|
      if ds.series_description =~ /.*F Map.*/ then
        fieldmap_directory = ds.directory
      end
    end
    
    return fieldmap_directory
  end
  
  def find_files_to_fieldmap(files_to_fieldmap_directory)
    files_to_fieldmap = Find.match(files_to_fieldmap_directory) { |p| File.fnmatch('r*', p) }
    return files_to_fieldmap
  end
  
  def create_tarfile(prefix, files_to_fieldmap, fieldmap_directory)
    local_tarfile = "#{prefix}.tar.gz"
    system("tar -czvf #{local_tarfile} #{fieldmap_directory} #{files_to_fieldmap.join(" ")}")
    return local_tarfile
  end

  def transfer_tarfile_to_move(local_tarfile)
    remote_tarfile = REMOTE_SCRATCH_DIR + File.basename(tarfile)
    system("scp #{REMOTE_USER}@#{REMOTE_HOST}:#{remote_tarfile}")
    return remote_tarfile
  end
  
  def execute_remote_fieldmapping(remote_tarfile)
    system(ssh -t johnson@tezpur "ssh johnson@${REMOTE_PROCESSING_HOST} ~/bin/createFieldmap.rb #{remote_tarfile}")
  end
  
  def transfer_tarfile_from_remote
    system("scp #{REMOTE_USER}@#{REMOTE_HOST}:#{remote_tarfile} .")
  end

  def unpack_tarfile_locally
    system("tar -xzvf #{local_tarfile}")
  end
  
end
