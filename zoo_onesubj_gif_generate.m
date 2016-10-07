%%% script to generate gif aniamation out of one subject anat and func volume
%% path and opt definition
in.anat = '/home/yassinebha/guillimin/data/nki_trt_2/out/anat/A00035561/anat_A00035561_nuc_stereonl.mnc';
in.func = '/home/yassinebha/guillimin/data/nki_trt_2/out/anat/A00035561/func_A00035561_mean_stereonl.mnc';
in.template =  which('mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz');
in.layout = which('mni_icbm152_t1_tal_nlin_sym_09a_outline_registration.mnc.gz');
out.anat = '/home/yassinebha/summary_A00035561_anat.jpg';
out.func = '/home/yassinebha/summary_A00035561_func.jpg';
out.template = '/home/yassinebha/summary_template.jpg';
out.layout_template = '/home/yassinebha/summary_template_layout.jpg';
out.layout_anat = '/home/yassinebha/summary_A00035561_anat_layout.jpg';
opt.coord = [-30 , -65 , -15 ;... 
            -8 , -25 ,  10 ; ...  
            30 ,  45 ,  60];
opt.flag_decoration = false;
opt.id = '';
[in,out,opt] = niak_brick_qc_fmri_preprocess (in,out,opt);

%%Gif generate
% anat2template
ing.img1 = out.layout_anat;
ing.img2 = out.template;
outg = '/home/yassinebha/summary_A00035561_anat2template.gif';
optg.ratio =  0.6;
optg.alpha = 3;
optg.transition_delay = [0.3 0.15 0.4 0.15];
niak_brick_img2gif(ing,outg,optg);

% func2anat
ing.img1 = out.func;
ing.img2 = out.layout_anat;
outg = '/home/yassinebha/summary_A00035561_func2anat.gif';
optg.ratio =  0.6;
optg.alpha = 3;
optg.transition_delay = [0.3 0.15 0.4 0.15];
niak_brick_img2gif(ing,outg,optg);  
