% Script to run zooniverse gif generation pipeline
addpath(genpath('/home/yassinebha/git/niak'))
addpath(genpath('/home/yassinebha/git/psom'))
addpath(genpath('/home/yassinebha/git/zooniverse_qc'))

path_fmri_preproc = '/media/yassinebha/database25/MAVEN_06_2016/fmri_preprocess_INSCAPE_REST/';
files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
opt.folder_out = '/media/yassinebha/database25/test_zooniverse/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);