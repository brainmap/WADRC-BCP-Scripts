module WadrcBcpScripts
  # We want to sample to ASL perfusion data (PET data, or other data) from ROIs,
  # determined in subject space by running a high-resolution T1 through
  # Freesurfer. As part of it's recon-all, freesurfer outputs segmentation images
  # (volume parcellation) that include ~ 100 ROIs for cortical gm, wm and
  # sub-cortical structures. All we need to do is get that segmentation into a
  # common space with the image of interest, and then we can sample it to get
  # meaningful estimates of the data.
  # 
  # The Process:
  # 1) Do Basic Reconstruction for Anatomical Images
  # 2) Run a high resolution T1 through Freesurfer
  # 3) Convert the aparc.a2009s+aseg.mgz back to NIfTI in T1 space for sampling.
  # 4) Rigidly register & reslice Target modality to T1 space 
  # 5) Sample mean and measures of interest
  class FreesurferRoiTask < BasicTask

    def initialize(raw_directory, output_directory, config)
      @config = config
      @raw_directory = raw_directory
      @output_directory = output_directory
      @commands = ShellQueue.new(:dry_run => true)
    end

    # Do Basic Reconstruction for Anatomical Images
    def basic_anatomical_reconstruction

      # Create the T1 & other Anatomicals
      @commands << "convert_visit.rb #{@raw_directory} #{@config[:subj_processed_dir]}"

      # Create the ASL
      modality_dir = File.join(@config[:subj_processed_dir], @config[:modality])
      Dir.mkdir_p modality_dir unless File.exists? modality_dir 
      Dir.chdir modality_dir do
        # fmap_make /Data/vtrak1/raw/dempsey.plaque.visit1/plq20005_1959_04072011/009
        #(Or, to search automatically: )
        @commands << "fmap_make `list_visit #{@raw_directory} -g #{@config[:modality]}`"

        # Link the T1 into the ASL directory for easy visualization if you want.

        # File.symlink("../unknown/plq02002_Ax-FSPGR-BRAVO_003.nii", "plq02002_Ax-FSPGR-BRAVO_003.nii")
      end
    end

    # Run a high resolution T1 through Freesurfer
    def run_t1_through_freesurfer
      ENV[:SUBJECTS_DIR] = @proc_options[:freesurfer_subjects_dir]

      system("recon-all -all -s #{OPTIONS[:subid]} -i #{File.join(OPTIONS[:subj_raw_dir], OPTIONS[:subid], "003/I0001.dcm")}")

      # This will run for 20 hours, and return a pretty subject directory. See below
      # for a sample manifest.
    end

    # Convert the aparc.a2009s+aseg.mgz back to NIfTI in T1 space for sampling.
    def prepare_segmentation
      aparc_base = "aparc.a2009s+aseg"
      freesurfer_subj_mri_dir = File.join(OPTIONS[:freesurfer_subjects_dir], OPTIONS[:subid], "mri")

      Dir.chdir modality_dir do 
        system("mri_convert #{File.join(freesurfer_subj_mri_dir, aparc_base)}.mgz #{apar_base}.nii")

        # Resample the Segementation image to the T1 space (using nearest neighbor so as
        # to not change any values):
        system("
          flirt -in aparc.a2009s+aseg.nii -ref plq20005_Ax-FSPGR-BRAVO_003.nii \
          -out raparc.a2009s+aseg.nii -applyxfm -init $FSLDIR/etc/flirtsch/ident.mat \
          -interp nearestneighbour"
        )
      end

      # You could resample with SPM as well (Coregister - Write) but this is a nice
      # command line option. For the actual registration, we are using SPM because
      # it's a somewhat better (qualitatively) algorithm.
    end

    # Rigidly register & reslice Target modality to T1 space 
    def register_modality_to_t1
      # For ASL, we ill use the PD image because it's information is closer to
      # anatomical than the computed flow maps, bringing along the flow maps. 

      # system("spm8")
      # Click Coregister - Estimate and Reslice
      # Reference Image: Select the BRAVO
      # Source Image: Select the PD Map
      # Other Images: Select the ASL Map
      # Use other defaults (NMI, etc.) 
    end

    # Sample mean and measures of interest
    def sample_roi
      system("3dROIstats -mask_f2short -mask raparc.a2009s+aseg.nii plq20005_Ax-FSPGR-BRAVO_003.nii rASL_plq20005_fmap.nii > stats.txt")
    end
    
    
  end
  
  # Heroes in a half shell - Turtle Power!
  # 
  # Manage a list of shell commands.
  # q = ShellQueue.new(:dry_run => true)
  # q << "ls"
  # q << "time"
  # q.run!
  class ShellQueue
    attr_reader :dry_run, :commands, :completed_commands, :failed_commands
    
    # Initialize a queue with an options hash.
    def initialize(options = {:dry_run => false})
      @commands = Array.new
      @dry_run = options[:dry_run]
    end
    
    # Run a queue (or print if dry_run)
    def run!
      while @commands.length > 0
        command = @commands.shift
        puts command
        @run_success = run command unless @dry_run
      end      
    end
    
    def <<(cmd)
      @commands << cmd
      run!
    end
    
    # Expose >>, << array methods to commands array.
    def method_missing(m, *args, &block)
      @commands.send(m, *args, &block)
    end

  end
end
