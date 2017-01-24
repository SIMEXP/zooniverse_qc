
param.transparency = 0.7;
param.perc_min = 0.05;
param.perc_max = 0.95;

% Invert image
[hdr,vol] = niak_read_vol('func_mean_average_stereonl.nii.gz');
[hdr,mask] = niak_read_vol('func_mask_group_stereonl.nii.gz');
mask = mask>0;
val = sort(vol(mask),'ascend');
vmin = val(round(param.perc_min*length(val)));
vmax = val(round(param.perc_max*length(val)));
vol(vol<vmin) = vmin;
vol(vol>vmax) = vmax;
vol(mask) = (vol(mask) - vmin)/(vmax-vmin);
vol(~mask) = 0;
vol = 1 - vol;
vol = sqrt(vol);
hdr.file_name = 'func_mean_average_stereonl_inv.nii.gz';
niak_write_vol(hdr,vol);

% Create montage for the template
clear jin jout jopt
% Input
jin.source = 'func_mean_average_stereonl_inv.nii.gz';
jin.target = '/home/pbellec/data/template.nii.gz';

% Output
jout = 'func_mean_average_stereonl.png';

% Options
jopt.colormap = 'gray';
jopt.limits = 'adaptative';
jopt.method = 'linear';
jopt.flag_decoration = false;
jopt.coord =[-30 , -65 , -15 ; 
             -8 , -25 ,  10 ;  
             30 ,  45 ,  60];
             
% The generation of the montage itself
niak_brick_vol2img(jin,jout,jopt)

%% Add overlay 

clear jin jout jopt
jin.background = 'func_mean_average_stereonl.png';
jin.overlay = 'outline.png';
jout = 'func_mean_average_stereonl_outline.png';
jopt.transparency = param.transparency;
jopt.threshold = 0.9;
niak_brick_add_overlay(jin,jout,jopt);

% Invert image
[hdr,vol] = niak_read_vol('func_HC0040013_mean_stereonl.nii.gz');
[hdr,mask] = niak_read_vol('func_mask_group_stereonl.nii.gz');
mask = mask>0;
val = sort(vol(mask),'ascend');
vmin = val(round(param.perc_min*length(val)));
vmax = val(round(param.perc_max*length(val)));
vol(vol<vmin) = vmin;
vol(vol>vmax) = vmax;
vol(mask) = (vol(mask) - vmin)/(vmax-vmin);
vol(~mask) = 0;
vol = 1 - vol;
vol = sqrt(vol);
hdr.file_name = 'func_HC0040013_mean_stereonl_inv.nii.gz';
niak_write_vol(hdr,vol);

% Create montage for the image
clear jin jout jopt
% Input
jin.source = 'func_HC0040013_mean_stereonl_inv.nii.gz';
jin.target = '/home/pbellec/data/template.nii.gz';

% Output
jout = 'func_HC0040013_mean_stereonl.png';

% Options
jopt.colormap = 'gray';
jopt.limits = 'adaptative';
jopt.method = 'linear';
jopt.flag_decoration = false;
jopt.coord =[-30 , -65 , -15 ; 
             -8 , -25 ,  10 ;  
             30 ,  45 ,  60];
             
% The generation of the montage itself
niak_brick_vol2img(jin,jout,jopt)


%% Add overlay 

clear jin jout jopt
jin.background = 'func_HC0040013_mean_stereonl.png';
jin.overlay = 'outline.png';
jout = 'func_HC0040013_mean_stereonl_outline.png';
jopt.transparency = param.transparency ;
jopt.threshold = 0.9;
niak_brick_add_overlay(jin,jout,jopt);
