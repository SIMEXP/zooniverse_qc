[hdr,mask] = niak_read_vol ('layout/left_calcarine_sulcus_smoothed.nii.gz');
[hdr,vol] = niak_read_vol ('mni_icbm152_gm_tal_nlin_sym_09a.nii.gz');
vol(mask==0) = 0;
vol_t = vol>0.2;
hdr.file_name = 'layout/mask_layout/mask_left_calcarine_sulcus_final.nii.gz';
niak_write_vol (hdr,vol_t);
hdr.file_name = 'layout/mask_layout/mask_right_calcarine_sulcus_final.nii.gz';
niak_write_vol (hdr,vol_t(end:-1:1,:,:));