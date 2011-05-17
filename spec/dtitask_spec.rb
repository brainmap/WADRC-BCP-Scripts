$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'helper_spec'
require 'wadrc-bcp-scripts/basic_task'
require 'wadrc-bcp-scripts/dtitask'

describe "Exception Testing for DtiTask" do
  before(:all) do
    $LOG = Logger.new(STDOUT)
  end
  
  before(:each) do
    # @valid_config = {
    #   :slice_order=>"altplus", 
    #   :bvectors_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvectors.txt", 
    #   :bvalues_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvalues.txt", 
    #   :file_glob=>"'*.dcm'", 
    #   :force_overwrite=>true, 
    #   :volumes=>26, 
    #   :dry_run=>true, 
    #   :slices_per_volume=>48
    # }
    
    @valid_config = {
        :slice_order=>"altplus", 
        :bvectors_file=>"/Data/vtrak1/preprocessed/visits/johnson.alz.snodrest.visit2/DTI_info/preproc_dti/enc12_rows.txt", 
        :bvalues_file=>"/Data/vtrak1/preprocessed/visits/johnson.alz.snodrest.visit2/DTI_info/preproc_dti/bvalues", 
        :file_glob=>"'I*'", 
        :force_overwrite=>true, 
        :volumes=>13, 
        :dry_run=>true, 
        :slices_per_volume=>39,
        :rotate=>true
    }
    @valid_dtitask = WadrcBcpScripts::Dtitask.new(@valid_config)
    
    @subid = 'alz021_2'
    @valid_input_directory = File.join($MRI_DATA, @subid, 'anatomicals', 'S9')
  end

  it "should raise an IOError if tensor_files do not exist." do
    File.stub!(:exists?).and_return(false)
    lambda { @valid_dtitask.ensure_file_exists(@valid_config[:bvectors_file])}.should raise_error(IOError, "#{@valid_config[:bvectors_file]} not found.")
  end
  
  it "should not raise an IOError if tensor_files do exist." do
    File.stub!(:exists?).and_return(true)
    lambda { @valid_dtitask.ensure_file_exists(@valid_config[:bvectors_file])}.should_not raise_error(IOError, "#{@valid_config[:bvectors_file]} not found.")
  end
  
  it "should raise an error if required keys are not in config file." do
    missing_key = :bvectors_file
    invalid_config = @valid_config
    invalid_config.delete(missing_key)
    lambda { WadrcBcpScripts::Dtitask.new(invalid_config).config_requires(missing_key) }.should raise_error(ScriptError, "Missing Keys: #{missing_key}")
  end
  
  it "should create a valid command array when given correct configuration using rotbvecs" do
    dir = Dir.tmpdir
    valid_command = [
      "to3d -prefix #{@subid}.nii -session #{dir} -time:zt #{@valid_config[:slices_per_volume]} #{@valid_config[:volumes]} 8000 altplus #{@valid_input_directory}/#{@valid_config[:file_glob]}", 
      "eddy_correct #{dir}/#{@subid}.nii #{dir}/#{@subid}_ecc.nii 0", 
      "rotbvecs #{@valid_config[:bvectors_file]} #{dir}/#{@subid}_#{File.basename(@valid_config[:bvectors_file])} #{dir}/#{@subid}_ecc.ecclog", 
      "bet #{dir}/#{@subid}_ecc #{dir}/#{@subid}_ecc_brain -f 0.1 -g 0 -n -m", 
      "dtifit --data=#{dir}/#{@subid}_ecc.nii --out=#{dir}/#{@subid}_dti --mask=#{dir}/#{@subid}_ecc_brain_mask --bvecs=#{dir}/#{@subid}_#{File.basename(@valid_config[:bvectors_file])} --bvals=#{@valid_config[:bvalues_file]}"
    ]
    cmd = @valid_dtitask.construct_commands(@valid_input_directory, dir, @subid).collect! {|cmd| cmd.squeeze(" ") }
    cmd.should == valid_command
  end
  
  it "should create a valid command array when given correct configuration NOT using rotbvecs" do
    dir = Dir.tmpdir
    config = @valid_config.dup
    config[:rotate] = false
    valid_command = [
      "to3d -prefix #{@subid}.nii -session #{dir} -time:zt #{@valid_config[:slices_per_volume]} #{@valid_config[:volumes]} 8000 altplus #{@valid_input_directory}/#{@valid_config[:file_glob]}", 
      "eddy_correct #{dir}/#{@subid}.nii #{dir}/#{@subid}_ecc.nii 0", 
      "bet #{dir}/#{@subid}_ecc #{dir}/#{@subid}_ecc_brain -f 0.1 -g 0 -n -m", 
      "dtifit --data=#{dir}/#{@subid}_ecc.nii --out=#{dir}/#{@subid}_dti --mask=#{dir}/#{@subid}_ecc_brain_mask --bvecs=#{@valid_config[:bvectors_file]} --bvals=#{@valid_config[:bvalues_file]}"
    ]
    cmd = WadrcBcpScripts::Dtitask.new(config).construct_commands(@valid_input_directory, dir, @subid).collect! {|cmd| cmd.squeeze(" ") }
    cmd.should == valid_command
  end
  
  it "should sucessfully run through fixture data for johnson.alz.visit2" do
    Dir.mktmpdir do |dir|
      cmd = @valid_dtitask.construct_commands(@valid_input_directory, dir, @subid).collect! {|cmd| cmd.squeeze(" ") }
      puts cmd.join("; ")
      system(cmd.join("; ")).should == true
    end
  end
  
  # after(:each) do
  # end
end