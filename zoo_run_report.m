addpath (genpath('~/git/projects'))
build_path zooniverse_qc
build_path niak
path_fmri_preproc = '/gs/scratch/pbellec/cobre_fmri_preprocess_nii_20160920/'; 
files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
in.ind.anat = files_in.anat;
in.ind.func = files_in.func;
%%%% for debugging only 10 subjects %%%%
in.ind.anat = rmfield(in.ind.anat,fieldnames(in.ind.anat)(11:end));
in.ind.func = rmfield(in.ind.func,fieldnames(in.ind.func)(11:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in.template.anat = files_in.template;
in.template.func = '';
in.group.avg_func = '/gs/scratch/pbellec/cobre_fmri_preprocess_nii_20160920/quality_control/group_coregistration/func_mean_average_stereonl.nii.gz';
in.group.mask_func_group = '/gs/scratch/pbellec/cobre_fmri_preprocess_nii_20160920/quality_control/group_coregistration/func_mask_group_stereonl.nii.gz';
in.template.anat_outline = '/home/yassinebha/outline/anat_outline.mnc.gz';
in.template.func_outline = '/home/yassinebha/outline/func_outline.nii.gz';
opt.folder_out = '/home/yassinebha/database/qc_project/zooqc';
pipeline = zoo_report_fmri_preprocess(in,opt);
