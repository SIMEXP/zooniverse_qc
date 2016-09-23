% Script to run zooniverse gif generation pipeline
addpath(genpath('/home/yassinebha/git/niak'))
addpath(genpath('/home/yassinebha/git/psom'))
addpath(genpath('/home/yassinebha/git/zooniverse_qc'))
%niak
path_fmri_preproc = '/media/yassinebha/database25/zooniverse_project/adhd200_fmri_preprocess_niak/';
files_in  = niak_grab_qc_fmri_preprocess(path_fmri_preproc);
files_in.template_layout = '~/git/zooniverse_qc/mask_all_layout.nii.gz';
opt.folder_out = '/media/yassinebha/database25/zooniverse_project/test_zooniverse/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
opt.psom.max_queued = 8;
niak_pipeline_qc_fmri_preprocess(files_in,opt);

%athena
path_fmri_preproc = '/gs/project/gsf-624-aa/adhd200_preproc/athena/';
list_sites = dir(path_fmri_preproc);
dirFlags = [list_sites.isdir];
list_sites = list_sites(dirFlags);
list_sites = {list_sites.name};
list_sites = list_sites(~ismember(list_sites,{'.','..','octave-wokspace','octave-core','qc_report'}));
for ss = 1:length(list_sites)
    site = list_sites{ss};
    list_subject = dir([path_fmri_preproc site filesep]);
    dirFlags = [list_subject.isdir];
    list_subject = list_subject(dirFlags);
    list_subject = {list_subject.name};
    list_subject = list_subject(~ismember(list_subject,{'.','..','octave-wokspace','octave-core','motion'}));
    for ll = 1:length(list_subject)
        subject = list_subject{ll};
        path_subj = [path_fmri_preproc site filesep subject filesep];
        subject_id = ['X_' subject];
        files_in.anat.(subject_id) = [path_subj (dir([path_subj '*_anat.nii.gz'])).name];
        files_in.func.(subject_id) = [path_subj (dir([path_subj 'wmean*_rest_1.nii.gz'])).name];
    end
end

files_in.template = which('mni_icbm152_t1_tal_nlin_asym_09a.mnc.gz');
files_in.template_layout = which('mni_icbm152_t1_tal_nlin_asym_09a_outline_registration.mnc');
opt.folder_out = '/gs/project/gsf-624-aa/adhd200_preproc/zooniverse_report_athena/';
opt.gif.transition_delay = [0.3 0.15 0.4 0.15];
niak_pipeline_qc_fmri_preprocess(files_in,opt);
