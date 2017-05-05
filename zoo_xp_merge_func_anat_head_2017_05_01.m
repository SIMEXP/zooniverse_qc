
path_work = pwd
cd
build_path  niak psom zooniverse_qc  
cd(path_work)

% Set parameters
niak_gb_vars
path_root = [pwd filesep];
#path_root = '/media/yassinebha/database29/Drive/QC_zooniverse/';
subject = 'HC0040013'

# anat subject vol 
niak_gb_vars
[hdr,vol] = niak_read_vol([path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl.nii.gz']);
[hdr,mask] = niak_read_vol([ GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep ...
'mni_icbm152_t1_tal_nlin_asym_09a_headmask.mnc.gz']);
opt.type_color = 'gray';
niak_montage(vol,opt)

% Create montage for the image
clear jin jout jopt
% Input
jin.source = [path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl.nii.gz'];
jin.target = [ GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep ...
'mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz'];

% Output
jout = [path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl.png'];

% Options
jopt.colormap = 'gray';
jopt.colorbar = false;
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
jopt.padding = false;
jopt.coord =[-30 , -65 , -6 ; 
             -8 , -25 ,  10 ;  
             30 ,  45 ,  60];
             
% The generation of the montage itself
niak_brick_vol2img(jin,jout,jopt);
imshow(jout)

# Alpply non uniformity corretion first
clear  files_in files_out opt
files_in.vol = [path_root 'template_layout/test_data/' subject '/func_' subject '_mean_stereonl.nii.gz'];
files_in.mask = [path_root 'template_layout/test_data/' subject '/func_mask_group_stereonl.nii.gz'];
files_out.vol_nu = '';
files_out.vol_imp = '';
opt.folder_out =  [path_root 'template_layout/test_data/' subject '/'];
[files_in,files_out,opt] = niak_brick_nu_correct(files_in,files_out,opt);

# Dispaly before correction image
[hdr,vol] = niak_read_vol(files_out.vol_nu);
[hdr,vol_raw] = niak_read_vol(files_in.vol);
opt.type_color = 'gray';
niak_montage(vol_raw,opt)

# After correction
niak_montage(vol,opt)

%% Invert contrast
[hdr,vol] = niak_read_vol(files_out.vol_nu);
[hdr,mask] = niak_read_vol(files_in.mask);
param.perc_min = 0.15;
param.perc_max = 0.99;

mask = mask>0;
val = sort(vol(mask),'ascend');
vmin = val(round(param.perc_min*length(val)));
vmax = val(round(param.perc_max*length(val)));
vol(vol<vmin) = vmin;
vol(vol>vmax) = vmax;
vol(mask) = (vol(mask) - vmin)/(vmax-vmin);
vol(~mask) = 0;
vol = 1 - vol;
vol = (abs(vol));
hdr.file_name =  [path_root 'template_layout/test_data/' subject '/func_' subject '_mean_stereonl_nu_inv.nii.gz'];
niak_write_vol(hdr,vol);

opt.type_color = 'gray';
niak_montage(vol,opt)

%% Create montage for the image
clear jin jout jopt
% Input
jin.source = [path_root 'template_layout/test_data/' subject '/func_' subject '_mean_stereonl_nu_inv.nii.gz'];
jin.target = [ GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep ...
'mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz'];

% Output
jout = [path_root 'template_layout/test_data/' subject '/func_' subject '_mean_stereonl_nu_inv.png'];

% Options
jopt.colormap = 'gray';
jopt.colorbar = false;
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
jopt.padding = true;
jopt.coord =[-30 , -65 , -6 ; 
             -8 , -25 ,  10 ;  
             30 ,  45 ,  60];
             
% The generation of the montage itself
niak_brick_vol2img(jin,jout,jopt);
imshow(jout)

%% Create montage forom the mask
clear jin jout jopt
% Input
jin.source = [path_root 'template_layout/test_data/' subject '/func_mask_group_stereonl.nii.gz'];
jin.target = [ GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep ...
'mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz'];

% Output
jout = [path_root 'template_layout/test_data/' subject '/func_mask_group_stereonl.png'];

% Options
jopt.colormap = 'gray';
jopt.colorbar = false;
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
jopt.padding = false;
jopt.coord =[-30 , -65 , -6 ; 
             -8 , -25 ,  10 ;  
             30 ,  45 ,  60];

             
% The generation of the montage itself
niak_brick_vol2img(jin,jout,jopt);

img  = imread(jout);
img= img / max(img(:));

# read images
img1 = imread([path_root 'template_layout/test_data/' subject '/func_' subject '_mean_stereonl_nu_inv.png']);
img2 = imread([path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl.png']);
img3 = img;

# buid a mask
img1_i = img1; % Generate intensity
img1_i = img1_i / max(img1_i(:)); % Express intensity as a fraction of the max intensity
mask = img1_i >=1;
mask_all = img1_i & ~img;
imshow(mask_all)

img12 = img2;
img12(~mask_all) = img1(~mask_all);
imshow(img12)

# sebastian method
#x = size(img1,1);
#y = size(img1,2);
#mask = zeros(x,y);
#for xi=1:x
#    for yi=1:y
#        mask(xi,yi) = all(img1(xi, yi, :)==255);
#    end
#end

#mask_3d = repmat(logical(mask), 1, 1, 3);
#img_good = img2;
#img_good(~mask_3d) = img1(~mask_3d);

out=[path_root 'template_layout/test_data/' subject '/func_anat_' subject '_mean_stereonl_nu_inv.png'];
imwrite(img12,out,'quality',90);

%% Add overlay 
clear jin jout jopt
jin.background =[path_root 'template_layout/test_data/' subject '/func_anat_' subject '_mean_stereonl_nu_inv.png'];
jin.overlay = [path_root 'template_layout/layout/mask_layout/mask_all_layout_v2_smoothed.png'];
jout = [path_root 'template_layout/test_data/' subject '/func_anat_' subject '_mean_stereonl_nu_inv_outline.png'];
jopt.transparency = 0.7 ;
jopt.threshold = 0.9;
niak_brick_add_overlay(jin,jout,jopt);
imshow(jout)

%% Add overlay functional-layout to anat subject 
clear jin jout jopt
param.transparency = 0.7;
jin.background =  [path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl.png'];
jin.overlay = [path_root 'template_layout/layout/mask_layout/mask_all_layout_v2_smoothed.png'];
jout = [path_root 'template_layout/test_data/' subject '/anat_' subject '_nuc_stereonl_func_outline.png'];
jopt.transparency = param.transparency;
jopt.threshold = 0.9;
niak_brick_add_overlay(jin,jout,jopt);
imshow(jout)

# generate gif
PATH = [path_work '/template_layout/test_data/' subject filesep];
command = ['convert '  PATH  'func_anat_' subject '_mean_stereonl_nu_inv_outline.png '  PATH ...
'anat_' subject '_nuc_stereonl_func_outline.png '   PATH  'func_anat_' subject '_mean_stereonl_nu_inv_outline.png  -delay 1 -morph 4 ' ...
PATH  'morph_' subject '_xp.gif']

system(command)


