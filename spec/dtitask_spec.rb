$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rubygems'
require 'spec'
require 'dtitask'

describe "Exception Testing for DtiTask" do
  before(:all) do
    # $LOG = Logger.new(STDOUT)
  end
  
  before(:each) do
    @valid_config = {
      :slice_order=>"altplus", 
      :bvectors_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvectors.txt", 
      :bvalues_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvalues.txt", 
      :file_glob=>"'*.dcm'", 
      :force_overwrite=>true, 
      :volumes=>26, 
      :dry_run=>true, 
      :slices_per_volume=>48
    }
    @valid_dtitask = Dtitask.new(@valid_config)
    p @valid_dtitask
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
    lambda { Dtitask.new(invalid_config).config_requires(missing_key) }.should raise_error(ScriptError, "Missing Keys: #{missing_key}")
  end
  
  # after(:each) do
  # end
end