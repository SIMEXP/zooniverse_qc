% build average mask for ADHD200
path_root = '/gs/project/gsf-624-aa/preprocess/adhd200/niak/fmri_preprocess';
list_site = dir(path_root);
list_site = {list_site.name};
list_site = list_site(ismember(list_site,{'.','..','anat_kki'}))
