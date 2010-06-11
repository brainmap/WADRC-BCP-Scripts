Factory.define :dtitask do |f|  
  f.config({
    :bvectors_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvectors.txt",
    :bvectors_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvectors.txt", 
    :bvalues_file=>"/Data/vtrak1/analyses/barb/cathy_temp/25_directions_bvalues.txt", 
    :file_glob=>"'*.dcm'", 
    :volumes=>26, 
    :dry_run=>true, 
    :slices_per_volume=>48 }
  )
end