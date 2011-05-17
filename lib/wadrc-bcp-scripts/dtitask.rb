module WadrcBcpScripts
  
  # This library creates scripts for basic processing for Diffusion Tensor Images 
  # (DTI).
  # 
  # The main function reconstruct! takes 3 arguements: A directory of raw DTI 
  # dicoms, an output directory and a filename prefix.  A set of batch commands 
  # using standard imaging tools (AFNI & FSL) are generated and executed to create
  # Fractional Anisotropy (FA), Mean Diffusivity (MD) and associated diffusion 
  # maps (eigenvalues & eigenvectors) in the output directory.
  # 
  # The script depends on AFNI to be in the path for reconstruction (to3d) and
  # FSL to be in the path for DTI Data Fitting (eddy_correct, bet & dtifit)
  class Dtitask < BasicTask
  
    # Task Configuration Options Hash
    attr_accessor :config
    # Source Directory of DICOMS
    attr_reader :input_directory
    # Source Directory of _unzipped_ DICOMS if using a Sandbox (or input_directory if not)
    attr_reader :working_input_directory
    # Destination Directory for DTI vectors, values, and maps
    attr_reader :output_directory
    # File Prefix to use for processing.
    attr_reader :file_prefix


    # Intialize DTItask with the following options:
    # 
    # DTI Options
    # * bvectors_file : 
    # * bvalues_file :
    # * repetition_time : TR in milliseconds, defaults to 8000
    # 
    # 
    # File Conversion Options
    # * file_glob :
    # * volumes :
    # * slices_per_volume :
    # * slice_order:
    # 
    # 
    # Runtime Options
    # * dry_run :
    # * force_overwrite :
    # * sandbox : Forces copying and unzipping to a temp directory in the case 
    #             of zipped dicom files.
    #  
    def initialize(config = Hash.new)
      @config = config

      @config[:dry_run] = true if config.empty?
    
      begin 
        # Intialize Settings for File Conversion and Diffusion Directions and Values
        config_requires :bvectors_file, :bvalues_file, :file_glob, :volumes, 
        :slices_per_volume, :slice_order
      
        # List binaries requried for the script to run.
        environment_requires :to3d, :eddy_correct, :bet, :dtifit, :rotbvecs
      rescue ScriptError => e
        raise e unless @config[:dry_run]
      end
    
    end
  
  
    # Reconstruct creates a script of commands to execute in order to prepare
    # DTI data for analyses (take a raw directory of DICOMS, convert them to 
    # nifti, eddy current correct them, and fit them using FSL to create 
    # eigen vectors and values, and MD and FA maps.
    #
    # Throws an IOError if input_directory is not found on the filesystem or
    # output directory already exists (except during a dry_run).
    def reconstruct!(input_directory, output_directory, file_prefix = nil)
      @input_directory = File.expand_path(input_directory)
      @output_directory = File.expand_path(output_directory)
      @file_prefix = file_prefix ? file_prefix : File.basename(input_directory)
    
      introduction = "Begin processing #{File.join(@input_directory)}"; puts
      puts "-" * introduction.size
      puts introduction; puts
    
      begin check_setup unless @config[:dry_run]
      rescue IOError => e
        puts "Error: #{e}"
        exit
      end
    
      # Construct the Script, output it and run it.
      batch_cmd = construct_commands(@working_input_directory, @output_directory, @file_prefix)

      batch_cmd.each do |cmd|
        puts cmd; $LOG.info cmd
        puts `#{cmd}` unless @config[:dry_run]
        puts
      end
    
      cleanup unless @config[:dry_run]
    
      puts "Done processing #{@file_prefix}" unless @config[:dry_run]
    
    end
  
  
    # Constructs the commands used in the script from constants and variables
    # set during intialization/configuration and gathered by the main
    # reconstruct! function.
    def construct_commands(input_directory, output_directory, file_prefix)
      rep_time = @config[:repetition_time] ? @config[:repetition_time] : 8000
      to3d_recon_options = "-time:zt #{@config[:slices_per_volume]} #{@config[:volumes]} #{rep_time} #{@config[:slice_order]} #{input_directory}/#{@config[:file_glob]}"
    
      commands = Array.new
    
      # Recon
      commands << "to3d -prefix #{file_prefix}.nii -session #{output_directory} #{to3d_recon_options}"
    
      # Eddy Current Correction
      commands << "eddy_correct #{output_directory}/#{file_prefix}.nii #{output_directory}/#{file_prefix}_ecc.nii 0"
    
      if @config[:rotate]
        # Rotate_bvecs
        subject_bvectors_file = File.join(output_directory, file_prefix + "_" + File.basename(@config[:bvectors_file]))
        commands << "rotbvecs #{@config[:bvectors_file]} #{subject_bvectors_file} #{File.join(output_directory, file_prefix)}_ecc.ecclog"
      else
        subject_bvectors_file = @config[:bvectors_file]
      end
    
    
      # Apply Mask
      if @config[:mask]
        out = "#{File.join(output_directory, file_prefix)}_ecc_ss"
        commands << "fslmaths #{@config[:mask]} -mul #{File.join(output_directory, file_prefix)}_ecc #{out}"
      else
        out = "#{File.join(output_directory, file_prefix)}_ecc"
      end
      commands << "bet #{out} #{out}_brain -f 0.1 -g 0 -n -m"
    
      # Run DTI Fit
      commands << "dtifit --data=#{output_directory}/#{file_prefix}_ecc.nii \
        --out=#{output_directory}/#{file_prefix}_dti \
        --mask=#{out}_brain_mask \
        --bvecs=#{subject_bvectors_file} \
        --bvals=#{@config[:bvalues_file]}"

      return commands
    end
  
  end

  # Message for when excuting from the command line.
  if __FILE__ == $0
    puts "Script generation library for DTI processing.  To use this with the command-line, use preprocess_dti.rb"
  end

end