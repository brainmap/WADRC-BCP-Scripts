require 'fileutils'
require 'escoffier'

module WadrcBcpScripts

  # Enviornment and configuration checks common between processing streams.
  class BasicTask
    # Task Configuration Options Hash
    attr_accessor :config

    # Check for some required helper applications that must be installed on the
    # system prior to use.  It returns true if there are no missing
    # processing program binaries, otherwise it puts them to the screen and 
    # raises a ScriptError.
    def environment_requires(*args)
      missing_binaries = []
      args.each do |required_binary|
        if system("which #{required_binary.to_s} > /dev/null") == false
          missing_binaries << required_binary
        end
      end
  
      begin
        unless missing_binaries.size == 0
          error = "
          Warning: The following processing tools weren't found on your system.
          - #{missing_binaries.join(', ')}
      
      
          Please install the missing programs, run this script from a properly configured workstation,
          or use the dry_run option to output your script to the terminal.\n "
          puts error
          raise(ScriptError, "Missing #{missing_binaries.join(", ")}")
        end
      end
  
      return
    end

    # Check for required keys in the @config hash.
    def config_requires(*args)
      missing_keys = []
      args.each do |required_key|
        unless @config.has_key?(required_key)
          missing_keys << required_key
        end
      end
  
      unless missing_keys.size == 0
        error = "
        Warning: Misconfiguration detected.
        You are missing the following keys from your spec file:
        - #{missing_keys.join(', ')}
    
    
        Please install the missing programs, run this script from a properly configured workstation,
        or use the dry_run option to output your script to the terminal.\n "
        puts error
        raise(ScriptError, "Missing Keys: #{missing_keys.join(", ")}")
      end
    end

    # Basic IO Directory Checks
    def check_setup(input_directory = @input_directory, output_directory = @output_directory)
      # Check Input Directory
      raise(IOError, "#{input_directory}: not found.") unless File.directory?(input_directory)

      # Check Gradient Tensor Files
      ensure_file_exists @config[:bvectors_file], @config[:bvalues_file] 
  
      unless @config[:dry_run]
        # Check Working Input Directory
        if @config[:force_sandbox]
          path = Pathname.new(input_directory)
          # @working_input_directory = path.sandbox(input_directory)
          @working_input_directory = path.prep_mise(input_directory + '/', Dir.mktmpdir + '/')
          @working_input_directory = File.join(@working_input_directory, File.basename(input_directory))
        else
          @working_input_directory = input_directory
        end
  
        # Check Output Directory and force cleanup if necessary.
        colliding_files = Dir.glob(File.join(output_directory, @file_prefix) + '*')
        puts colliding_files
        if File.directory?(output_directory) && colliding_files.empty? == false
          if @config[:force_overwrite] then colliding_files.each {|file| puts "Removing #{file}..."; File.delete(file) }
          else raise(IOError, "#{output_directory} already exists. Set force_overwite in your spec file to overwrite the directory.") 
          end
        end
        FileUtils.mkdir_p(output_directory)
      else
        # Use the real input directory if the working directory was not assigned 
        # (ie during dry run)
        @working_input_directory = input_directory
      end
  
      # Setup Logging
      logfile = File.join(output_directory, "#{File.basename(input_directory)}_#{today}.log")
      if File.writable?(output_directory) && ! @config[:dry_run]
        $LOG = Logger.new(logfile)
      else
        $LOG = Logger.new(STDOUT)
      end
  
      # Switch CWD (default output location for rotbvecs script)
      @cwd = Dir.pwd
      Dir.chdir(output_directory) unless @config[:dry_run]
    end

    def ensure_file_exists(*args)
      args.each do |file|
        raise(IOError, "#{file} not found.") unless File.exists?(file)
      end
  
    end

    private

    def cleanup
      Dir.chdir(@cwd)
      puts Dir.pwd
      cleanup_directories
      # $LOG.close
    end

    # Cleanup Sandbox Directories
    def cleanup_directories
      if File.directory?(@working_input_directory) && (@input_directory != @working_input_directory)
        FileUtils.rm_r @working_input_directory 
      end
    end

    def today
      [Date.today.month, Date.today.day, Date.today.year].join
    end
  end
end
