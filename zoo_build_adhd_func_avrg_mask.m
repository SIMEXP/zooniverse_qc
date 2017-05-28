% build average mask for ADHD200
%% first untar the archive
clear all
path_root = '/gs/project/gsf-624-aa/preprocess/adhd200/niak/fmri_preprocess';
cd(path_root);
list_site = dir([path_root filesep 'anat_*']);
list_site = {list_site.name};
list_site = list_site(~ismember(list_site,{'.','..','anat_kki','anat_kki.tar'}));

for ii = 1:length(list_site)
  site = list_site{ii};
  command = ['tar -xvf ' site];
  system(command);
end


%% read and stack func mask un build average mask
clear all
path_root = '/gs/project/gsf-624-aa/preprocess/adhd200/niak/fmri_preprocess/anat';
cd(path_root);
list_subject = dir(path_root);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..'}));

nb_subject = 0;
for mm = 1 : length(list_subject)
  niak_progress(mm,length(list_subject));
  subject = list_subject{mm};
  mask_func = dir([path_root filesep subject filesep 'anat_' subject '_mask_stereonl.*']);
  mask_func = [path_root filesep subject filesep mask_func.name];
  if ~exist(mask_func)
    fprintf('subject %s has no functional mask \n', subject)
    continue
  else
    if mm == 1
      [hdr,mask] = niak_read_vol(mask_func);
      mask_stack = mask;
    else
      [hdr,mask] = niak_read_vol(mask_func);
      mask_stack = mask + mask_stack;
    end
    nb_subject = nb_subject +1;
  end
end

% calculate mean average
mask_func_avg = mask_stack/nb_subject;
mask_func_group = mask_func_avg > 0.5;

% save average mask
hdr.file_name = ['/gs/project/gsf-624-aa/preprocess/adhd200/niak/fmri_preprocess/mask/anat_mask_average_stereonl.nii.gz'];
niak_write_vol(hdr,mask_func_avg);
% save group mask
hdr.file_name = ['/gs/project/gsf-624-aa/preprocess/adhd200/niak/fmri_preprocess/mask/anat_mask_group_stereonl.nii.gz'];
niak_write_vol(hdr,mask_func_group);
