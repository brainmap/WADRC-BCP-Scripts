#!/usr/bin/env bash
# run_dti_fit_for_study.sh
# Constructs and runs an interface to the preprocess_dti.rb command line
# interface for a given study.


# Sample Arguments
# raw_dir=/Data/vtrak1/raw/johnson.predict.visit1
# study_proc_dir=/Data/vtrak1/preprocessed/visits/johnson.predict.visit1
# study_prefix=pdt
# yaml_config=/Data/vtrak1/preprocessed/visits/johnson.predict.visit1/dti_config/dti_config.yaml

raw_dir=$1
study_proc_dir=$2
study_prefix=$3
yaml_config=$4

for directory in ${raw_dir}/${study_prefix}*; do
	# Assume that directories in /raw are named <subject>_<exam-number>_<date>
  subject=`basename $directory | awk -F_ '{print $1}'`

	# Full command for running DTI with Eddy Current Correction
	ruby -rubygems ~erik/code/ImageProcessing/bin/preprocess_dti.rb -t \
	-s ${yaml_config} -p ${subject} ${raw_dir}/${subject}*/dicoms/*dti* \
	${study_proc_dir}/${subject}/dti_FSL_recon
done
