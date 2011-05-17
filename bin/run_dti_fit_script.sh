#!/usr/bin/env bash
# 05/11/10
# Full command for running DTI with Eddy Current Correction and Sundry Options

# subject=pdt00001;
# rawdir=/Data/vtrak1/raw/johnson.predict.visit1
# procdir=/Data/vtrak1/preprocessed/visits/johnson.predict.visit1/pdt00001/dti_FSL_recon
# yaml_config=/Data/vtrak1/preprocessed/visits/johnson.predict.visit1/dti_config/dti_config.yaml


subject=$1
rawdir=$2
procdir=$3
yaml_config=$4




# This is kinda a shity way of doing it, but...  It's alright.  

# The reason why you have to give it here, at the final call to
# preprocess_dti.rb, is because it's possible that there are more than one
# series named dti. The script will handle that, as it will actually process
# each series that matches /dti/, but only when they're multilple arguments
# given to the preprocess_dti.rb; other shell scripts (like run_dti_fit_script)
# would intercept and mess up the arguments.

# We don't need 2 of these shell scripts now.'