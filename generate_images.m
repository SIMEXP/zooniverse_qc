% generate images for zooniverse platform
path_preproc = '/media/yassinebha/database24/adhd200/';
files_in = niak_grab_qc_fmri_preprocess(path_preproc);
folder_out = [path_preproc '/qc_report2/'];
folder_out_zooniv = [folder_out 'QC_zooniverse/'];
niak_mkdir(folder_out_zooniv);
coord_select = [-30 , -65 , -15 ; 
                -8 , -25 ,  10 ;  
                 30 ,  45 ,  60];
%% Generate the image for the template
fprintf('Generating slices of the template...\n');
in_t.source = files_in.template;
in_t.target = files_in.template;
out_t = [folder_out 'summary_template.jpg'];
opt_t.coord = coord_select;
opt_t.colorbar = false;
opt_t.colormap = 'gray';
opt_t.limits = 'adaptative';
opt_t.title = '';
opt_t.flag_decoration = false;
niak_brick_vol2img(in_t,out_t,opt_t);
n_shift = 0;
for ss = 1:length(fieldnames(files_in.func))
    subj_id = fieldnames(files_in.func){ss};
    
    %% Generate the image for the structural scan
    fprintf('%s : Generating slices of the anatomical scan...\n',subj_id);
    in_a.source = files_in.anat.(subj_id);
    in_a.target = files_in.template;
    out_a = [folder_out 'summary_' subj_id '_anat.jpg'];
    opt_a.coord = coord_select;
    opt_a.colorbar = false;
    opt_a.colormap = 'gray';
    opt_a.limits = 'adaptative';
    opt_a.title = '';
    opt_a.flag_decoration = false;
    niak_brick_vol2img(in_a,out_a,opt_a);
    
    %% Generate the image for the functional scan
   
    fprintf('%s : Generating slices of the functional scan...\n',subj_id);
    in_f.source = files_in.func.(subj_id);
    in_f.target = files_in.template;
    out_f = [folder_out 'summary_' subj_id '_func.jpg'];
    opt_f.coord = coord_select;
    opt_f.colorbar = false;
    opt_f.colormap = 'jet';
    opt_f.limits = 'adaptative';
    opt_f.title = '';
    opt_f.flag_decoration = false;
    niak_brick_vol2img(in_f,out_f,opt_f);

    ## Morph anat and template
    system(['convert ' folder_out 'summary_template.jpg  ' folder_out 'summary_' subj_id '_anat.jpg ' folder_out 'summary_template.jpg -delay 1 -morph 3 ' folder_out_zooniv 'morph_' subj_id '_anat_template.gif']);
    ## Resize image
    system(['mogrify -resize 315x353 ' folder_out_zooniv 'morph_' subj_id '_anat_template.gif']);
    ## Morph anat and func
    system(['convert  ' folder_out 'summary_' subj_id '_anat.jpg  ' folder_out 'summary_' subj_id '_func.jpg ' folder_out 'summary_' subj_id '_anat.jpg -delay 1 -morph 3 ' folder_out_zooniv 'morph_' subj_id '_anat_func.gif']);
    ## Resize image
    system(['mogrify -resize 310x348 ' folder_out_zooniv 'morph_' subj_id '_anat_func.gif']);
    
    ## Create manifest csv file
    
    if ss == 1 
       tab{ss,1} = [subj_id '_anat'] ;
       tab{ss,2} = ['morph_' subj_id '_anat_template.gif'];
       tab{ss+1,1} = [subj_id '_func'];
       tab{ss+1,2} = ['morph_' subj_id '_anat_func.gif'];
    else
       tab{ss+n_shift,1} = [subj_id '_anat'] ;
       tab{ss+n_shift,2} = ['morph_' subj_id '_anat_template.gif'];
       tab{ss+n_shift+1,1} = [subj_id '_func'] ;
       tab{ss+n_shift+1,2} = ['morph_' subj_id '_anat_func.gif'];
    end
    n_shift = n_shift+1; 
    
    % make separate anat func files
    tab_a{ss,1} = [subj_id] ;
    tab_a{ss,2} = ['morph_' subj_id '_anat_template.gif'];
    tab_f{ss,1} = [subj_id];
    tab_f{ss,2} = ['morph_' subj_id '_anat_func.gif']; 
    
end
header_labels = {'subject_ID','images'};
tab_final = [header_labels ; tab];
file_name = [folder_out_zooniv 'QC_Project_manifest_file.csv'];
niak_write_csv_cell(file_name,tab_final);

tab_a_final = [header_labels ; tab_a];
file_name = [folder_out_zooniv 'QC_Project_manifest_anat_file.csv'];
niak_write_csv_cell(file_name,tab_a_final);

tab_f_final = [header_labels ; tab_f];
file_name = [folder_out_zooniv 'QC_Project_manifest_func_file.csv'];
niak_write_csv_cell(file_name,tab_f_final);
