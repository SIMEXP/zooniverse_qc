% Script to run zooniverse gif generation pipeline
addpath(genpath('/home/yassinebha/git/niak'))
addpath(genpath('/home/yassinebha/git/psom'))
addpath(genpath('/home/yassinebha/git/zooniverse_qc'))
%niak
path_fmri_preproc = '/media/yassinebha/database25/zooniverse_project/adhd200_fmri_preprocess_niak/';
files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
opt.folder_out = '/media/yassinebha/database25/zooniverse_project/test_zooniverse/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);

%athena
path_fmri_preproc = '/media/yassinebha/database25/zooniverse_project/adhd200_fmri_preprocess_athena/';
list_subject = dir([path_fmri_preproc 'anat/'];


files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
opt.folder_out = '/media/yassinebha/database25/zooniverse_project/zooniverse_adhd200_athena/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);