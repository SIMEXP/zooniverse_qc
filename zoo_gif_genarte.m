% Script to run zooniverse gif generation pipeline
addpath(genpath('/home/yassinebha/git/niak'))
addpath(genpath('/home/yassinebha/git/psom'))
addpath(genpath('/home/yassinebha/git/zooniverse_qc'))
%niak
path_fmri_preproc = '/media/yassinebha/database25/zooniverse_project/adhd200_fmri_preprocess_niak/';
files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
opt.folder_out = '/media/yassinebha/database25/zooniverse_project/test_zooniverse/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.template_layout = '~/git/zooniverse_qc/mask_all_layout.nii.gz';
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);

%athena
path_fmri_preproc = '/media/yassinebha/database25/zooniverse_project/adhd200_fmri_preprocess_athena/';

list_subject = {(dir([path_fmri_preproc 'anat'])).name};
list_subject = list_subject(~ismember(list_subject,{'.','..','octave-wokspace','octave-core'}));
for ll = 1:length(list_subject)
    subject = list_subject{ll};
    path_subj = [path_fmri_preproc 'anat/' subject '/'];
    subject_id = ['X_' subject];
    files_in.anat.(subject_id) = [path_subj (dir([path_subj '*anat*'])).name];
    files_in.func.(subject_id) = [path_subj (dir([path_subj '*rest_1*'])).name];
end

niak_gb_vars
files_in.template = [gb_niak_path_template 'mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz'];
opt.folder_out = '/media/yassinebha/database25/zooniverse_project/zooniverse_adhd200_athena/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);
