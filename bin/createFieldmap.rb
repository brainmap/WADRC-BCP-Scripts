#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/fieldmap_classes'
require 'logger'

=begin rdoc
This script creates and applies fieldmaps in a scratch directory and handles some basic file zipping and unzipping.

Pass in the path to a tar of fieldmaps and files.  The file should have two directories inside:
incoming.tar.gz/
|-- fieldmap
|   |-- I0001.dcm
|   `-- I0002.dcm
`-- files_to_fieldmap
    |-- rSnodC.nii
    `-- rSnodD.nii
=end

if __FILE__ == $0
  if ARGV.size != 1
    puts "Usage: createFieldmap.rb incoming_tarfile.tar.gz"
  else
    t = FieldmapTask.new(ARGV[0])
    t.setup_paths
    tmpdir, fieldmap_directory, files_to_fieldmap = t.unpack(t.incoming_tar_file)
    Dir.chdir(tmpdir)
    
    fieldmap_file = t.create_fieldmap(fieldmap_directory)
    t.apply_fieldmap(fieldmap_file, files_to_fieldmap)
    t.cleanup(tmpdir)
  end
end
