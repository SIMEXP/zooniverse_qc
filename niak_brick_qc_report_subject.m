% Inputs
in = psom_struct_defaults( in , ...
    { 'anat' ,'anat', 'template', 'template_layout' , 'func' }, ...
    { NaN    , NaN  , NaN      , NaN       , NaN   });

% Outputs
if (nargin < 2) || isempty(out)
    out = struct;
end 
out = psom_struct_defaults( out , ...
    { 'anat' , 'template' ,  'layout_template' ,'layout_anat' , 'func' , 'report' }, ...
    { ''     , ''         ,  ''               ,''            , ''     , ''       });
 
% Options 
if nargin < 3
    opt = struct;
end
coord_def =[-30 , -65 , -15 ;... 
            -8 , -25 ,  10 ;... 
            30 ,  45 ,  60];
opt = psom_struct_defaults ( opt , ...
    { 'folder_out' , 'coord'   , 'flag_decoration' , 'flag_test' , 'id'          , 'template',  'flag_layout' , 'flag_merge_layout_anat' , 'flag_verbose' }, ...
    { pwd          , coord_def , true              , false       , 'anonymous'   , ''        ,  false                        , false                    , true           });

opt.folder_out = niak_full_path(opt.folder_out);


%% Generate the html report
if ~strcmp(out.report,'gb_niak_omitted')
    if opt.flag_verbose
        fprintf('Generating the QC html report...\n');
    end
    
    %% Read html template
    file_self = which('niak_pipeline_qc_fmri_preprocess');
    path_self = fileparts(file_self);
    file_html = [path_self filesep 'niak_template_qc_fmri_preprocess.html'];
    hf = fopen(file_html,'r');
    str_html = fread(hf,Inf,'uint8=>char')';
    fclose(hf);

    %% Modify template and save output
    hf = fopen(out.report,'w+');
    if opt.flag_layout == true
       [path_a,name_a,ext_a] = fileparts(out.anat);
       [path_al,name_al,ext_al] = fileparts(out.layout_anat);
       [path_t,name_t,ext_t] = fileparts([opt.folder_out 'summary_template_layout.jpg']);
    else
       [path_a,name_a,ext_a] = fileparts(out.anat);
       path_al = path_a;
       name_al = name_a;
       ext_al = ext_a;
       if ~isempty(opt.template)
          [path_t,name_t,ext_t] = fileparts(opt.template);
       else
          [path_t,name_t,ext_t] = fileparts(out.template);
       end
    end
    [path_f,name_f,ext_f] = fileparts(out.func);
    text_write = strrep(str_html,'$TEMPLATE',[name_t ext_t]);
    text_write = strrep(text_write,'$ANAT',[name_a ext_a]);
    text_write = strrep(text_write,'$LAYOUTANAT',[name_al ext_al]);
    text_write = strrep(text_write,'$FUNC',[name_f ext_f]);
    fprintf(hf,'%s',text_write);
    fclose(hf);
end