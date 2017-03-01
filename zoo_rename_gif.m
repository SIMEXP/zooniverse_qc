clear all
path_in = '/media/yassinebha/database25/Drive/QC_zooniverse/zooniverse_gif_niak';
path_out = '/media/yassinebha/database25/Drive/QC_zooniverse/zooniverse_gif_niak_validation';
list_subj = dir(path_in);
list_subj = {list_subj.name};
list_subj = list_subj(~ismember(list_subj,{'.','.~lock.zooniverse_manifest_file.csv#','..','octave-wokspace','octave-core','zooniverse_manifest_file.csv'}));
for ii = 1: length(list_subj)
    subject_raw = list_subj{ii};
    subject = strrep(subject_raw,'summary_X_','summary_X');
    system(['scp ' path_in  filesep subject_raw ' ' path_out filesep subject]);
end
