#!/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'fileutils'
require 'dtifit_processing'

class ReconstructDTI_test < Test::Unit::TestCase
  def setup
    @input_directory = '/Data/vtrak1/raw/wrap140/wrp002_5938_03072008/017'
    @output_directory = '/tmp/wrp002/dti'
    @subject_prefix = 'wrp002'
  end

  def test_dti_reconstruction_class
    ReconstructDTI.reconstruct!(@input_directory, @output_directory, @subject_prefix)
  end


  def teardown
    FileUtils.rm_r @output_directory
  end

end
