#!/usr/bin/env ruby

=begin rdoc
This command-line utility executes local preprocessing required for fieldmapping.  It prepares a tar-file to transfer to a remote machine for processing, in the form:

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
    puts "Usage: FieldmapAtWaisman.rb "
  else
    prefix = ARGV[0]
    files_to_fieldmap_directory = ARGV[1]
    dicoms_directory = ARGV[2]
    
    
    t = LocalFieldmapSetup.new(prefix, files_to_fieldmap_directory, dicoms_directory)

    fieldmap_directory = t.find_fieldmap_directory(dicoms_directory)
    files_to_fieldmap = t.find_files_to_fieldmap(files_to_fieldmap_directory)
    local_tarfile = t.create_tarfile(prefix, files_to_fieldmap, fieldmap_directory)
    remote_tarfile = t.transfer_tarfile_to_move(local_tarfile)
    t.execute_remote_fieldmapping(remote_tarfile)
    t.transfer_tarfile_from_remote
    t.unpack_tarfile_locally

  end
end