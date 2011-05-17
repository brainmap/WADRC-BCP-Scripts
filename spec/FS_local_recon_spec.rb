$:.unshift File.join(File.dirname(__FILE__),'..','bin')

require 'helper_spec'
load 'FS_local_recon'

describe "Perform local recon" do  
  
  # before(:all) do
  #   @normalizer = Normalizer.new('/tmp/awr011_8414_06182009')
  # end

  it "should run local recon on a subject" do
    hostname = 'localhost'
    subject = "tami99999"
    options = {:server_analysis_dir => '/Data/vtrak1/raw/test/fixtures/ImageProcessing', :autorecon_options => '-autorecon2-wm -autorecon3'}
    lambda { run!(hostname, subject, options) }.should_not raise_error
  end
  
  # after(:each) do
  # end
  
end