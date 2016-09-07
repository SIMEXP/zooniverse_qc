% generate volume layout on stereotaxic space

root_path = '/media/yassinebha/database25/Drive/QC_zooniverse/template_layout/';
path_layout = [root_path 'layout/'];
list_layout = {(dir([path_layout 'left_*.nii.gz'])).name};

[hdr,vol] = niak_read_vol ([root_path 'mni_icbm152_gm_tal_nlin_sym_09a.nii.gz']);
vol_final = zeros(size(vol));
for ii=1:length(list_layout)
    fprintf('%s\n',list_layout{ii}(6:end-7))
    [hdr,mask] = niak_read_vol ([path_layout list_layout{ii}]);
    vol_raw = vol;
    vol_raw(mask==0) = 0;
    vol_t = vol_raw>0.2;
    hdr.file_name = [path_layout 'mask_layout/mask_' list_layout{ii}] ;
    niak_write_vol (hdr,vol_t);
    hdr.file_name = [path_layout 'mask_layout/mask_right' list_layout{ii}(5:end)];
    vol_transpose = vol_t(end:-1:1,:,:);
    niak_write_vol (hdr,vol_transpose);
    vol_final = vol_final |vol_t | vol_transpose;
end


% Extract the brain outline
[hdr,vol] = niak_read_vol ([root_path 'mni_icbm152_t1_tal_nlin_sym_09a_mask.nii.gz']);
niak_montage (vol)
vol_e = niak_morph (vol,'-successive EE');
niak_montage (vol + vol_e)
vol_d = niak_morph (vol,'-successive DD');
niak_montage (vol+vol_d)
vol_f = vol_d & ~vol_e;
niak_montage (vol_f)
hdr.file_name = [path_layout 'mask_layout/mask_outline_brain.nii.gz'];
niak_write_vol (hdr,vol_f);


% write final volume layout
vol_final = vol_final | vol_f;
hdr.file_name = [path_layout 'mask_layout/mask_all_layout.nii.gz'];
niak_write_vol (hdr,vol_final);