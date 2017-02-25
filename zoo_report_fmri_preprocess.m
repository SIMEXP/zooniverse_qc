function pipeline = zoo_report_fmri_preprocess(in,opt)
% Generate images for the zooniverse brain match report
%
% SYNTAX: PIPE = ZOO_REPORT_FMRI_PREPROCESS(IN,OPT)
%
% IN.IND (structure)
%   ANAT.(SUBJECT) (string) the file name of an individual T1 volume (in stereotaxic space).
%   FUNC.(SUBJECT) (string) the file name of an individual functional volume (in stereotaxic space)
%
% IN.TEMPLATE (structure)
%   ANAT (string) the file name of the template used for registration in stereotaxic space.
%   FMRI (string)the file name of the template used to resample fMRI data.
%   ANAT_OUTLINE (string, default anatomical symmetric outline)
%     the file name of a binary masks, highlighting regions for coregistration.
%   FUNC_OUTLINE (string, default functional symmetric outline)
%     the file name of a binary masks, highlighting regions for coregistration.
%
% OPT
%   (structure) with the following fields:
%   FOLDER_OUT (string) where to generate the outputs.
%   COORD (array N x 3) Coordinates for the registration figures.
%     The default is:
%     [-30 , -65 , -15 ;
%       -8 , -25 ,  10 ;
%       30 ,  45 ,  60];
%   TYPE_OUTLINE (string, default 'sym') what type of registration landmarks to use (either
%     'sym' for symmetrical templates or 'asym' for asymmetrical templates).
%   PSOM (structure) options for PSOM. See PSOM_RUN_PIPELINE.
%   FLAG_VERBOSE (boolean, default true) if true, verbose on progress.
%   FLAG_TEST (boolean, default false) if the flag is true, the pipeline will
%     be generated but no processing will occur.
%
% Note:
%   Labels SUBJECT, SESSION and RUN are arbitrary but need to conform to matlab's
%   specifications for field names.
%
%   This pipeline needs the PSOM library to run.
%   http://psom.simexp-lab.org/
%
% Copyright (c) Pierre Bellec
% Centre de recherche de l'Institut universitaire de griatrie de Montral, 2016.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : visualization, montage, 3D brain volumes

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%% PSOM/NIAK variables
psom_gb_vars;
niak_gb_vars;

%% Defaults

% Inputs
in = psom_struct_defaults( in , ...
    { 'ind' , 'template' }, ...
    { NaN   , NaN        });


in.ind = psom_struct_defaults( in.ind , ...
    { 'anat' , 'func' }, ...
    { NaN    , NaN    });

in.template = psom_struct_defaults( in.template , ...
    { 'anat' , 'fmri' , 'anat_outline' , 'func_outline'}, ...
    { NaN    , NaN    , NaN            , NaN           });

if ~isstruct(in.ind.anat)
    error('IN.IND.ANAT needs to be a structure');
end

if ~isstruct(in.ind.func)
    error('IN.IND.FUNC needs to be a structure');
end

list_subject = fieldnames(in.ind.anat);

if (length(fieldnames(in.ind.func))~=length(list_subject))||any(~ismember(list_subject,fieldnames(in.ind.func)))
    error('IN.IND.ANAT and IN.IND.FUNC need to have the same field names')
end

%% Options
if nargin < 2
    opt = struct;
end
coord_def =[-30 , -65 , -15 ;
             -8 , -25 ,  10 ;
             30 ,  45 ,  60];
opt = psom_struct_defaults ( opt , ...
    { 'type_outline' , 'folder_out' , 'coord'   , 'flag_test' , 'psom'   , 'flag_verbose' }, ...
    { 'sym'          , pwd          , coord_def , false       , struct() , true           });

opt.folder_out = niak_full_path(opt.folder_out);
opt.psom.path_logs = [opt.folder_out 'logs' filesep];

if ~ismember(opt.type_outline,{'sym','asym'})
    error(sprintf('%s is an unknown type of outline',opt.type_outline))
end
file_outline_anat = [GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep 'mni_icbm152_t1_tal_nlin_' opt.type_outline '_09a_anat_outline_registration.mnc.gz'];
file_outline_func = [GB_NIAK.path_niak filesep 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep 'mni_icbm152_t1_tal_nlin_' opt.type_outline '_09a_func_outline_registration.mnc.gz'];
%% Build file names

%% Copy and update the report templates
pipeline = struct;
clear jin jout jopt
niak_gb_vars
path_template = [GB_NIAK.path_niak 'reports' filesep 'fmri_preprocess' filesep 'templates' filesep ];
jin = niak_grab_folder( path_template , {'.git',[path_template 'motion'],[path_template 'registration'],[path_template 'summary'],[path_template 'group']});
jout = strrep(jin,path_template,opt.folder_out);
jopt.folder_out = opt.folder_out;
pipeline = psom_add_job(pipeline,'cp_report_templates','niak_brick_copy',jin,jout,jopt);

%% Write a text description of the pipeline parameters
clear jin jout jopt
jin = in.params;
jout.list_subject = [opt.folder_out 'group' filesep 'listSubject.js'];
jout.list_run = [opt.folder_out 'group' filesep 'listRun.js'];
jout.files_in = [opt.folder_out 'summary' filesep 'filesIn.js'];
jout.summary = [opt.folder_out 'summary' filesep 'pipeSummary.js'];
jopt.list_subject = list_subject;
pipeline = psom_add_job(pipeline,'params','niak_brick_preproc_params2report',jin,jout);

%% The summary of BOLD registration
clear jin jout jopt
jin = in.group.summary_func;
jout = [opt.folder_out 'summary' filesep 'chartBOLD.js'];
pipeline = psom_add_job(pipeline,'summary_func','niak_brick_preproc_func2report',jin,jout);

%% The summary of T1 registration
clear jin jout jopt
jin = in.group.summary_func;
jout = [opt.folder_out 'summary' filesep 'chartT1.js'];
pipeline = psom_add_job(pipeline,'summary_anat','niak_brick_preproc_anat2report',jin,jout);

%% The summary of FD
clear jin jout jopt
jin = in.group.summary_scrubbing;
jout = [opt.folder_out 'summary' filesep 'fd.js'];
pipeline = psom_add_job(pipeline,'summary_scrubbing','niak_brick_preproc_scrubbing2report',jin,jout);

%% The summary of brain masks
clear jin jout jopt
jin = in.ind.registration;
jout = [opt.folder_out 'summary' filesep 'chartBrain.js'];
pipeline = psom_add_job(pipeline,'summary_intra','niak_brick_preproc_intra2report',jin,jout);

%% Generate group images
clear jin jout jopt
jin.target = in.template.anat;
jopt.coord = opt.coord;
jopt.colorbar = true;

% Template
jin.source = in.template.anat;
jout = [opt.folder_out 'group' filesep 'template_stereotaxic_raw.png'];
jopt.colormap = 'gray';
jopt.colorbar = false;
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'template_stereo','niak_brick_vol2img',jin,jout,jopt);

% Group average T1
jin.source = in.group.avg_t1;
jout = [opt.folder_out 'group' filesep 'average_t1_stereotaxic.png'];
jopt.colormap = 'gray';
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'average_t1_stereo','niak_brick_vol2img',jin,jout,jopt);

% Group outline
jin.source = file_outline;
jout = [opt.folder_out 'group' filesep 'outline.png'];
jopt.colormap = 'jet';
jopt.limits = [0 1.1];
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'t1_outline_registration','niak_brick_vol2img',jin,jout,jopt);

% Group average BOLD
jin.source = in.group.avg_func;
jout = [opt.folder_out 'group' filesep 'average_func_stereotaxic.png'];
jopt.colormap = 'jet';
jopt.limits = 'adaptative';
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'average_func_stereo','niak_brick_vol2img',jin,jout,jopt);

% Group BOLD mask
jin.source = in.group.mask_func_group;
jout = [opt.folder_out 'group' filesep 'mask_func_group_stereotaxic.png'];
jopt.colormap = 'jet';
jopt.limits = [0 1];
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'mask_func_group_stereo','niak_brick_vol2img',jin,jout,jopt);

% Average BOLD mask
jin.source = in.group.avg_mask_func;
jout = [opt.folder_out 'group' filesep 'average_mask_func_stereotaxic.png'];
jopt.colormap = 'jet';
jopt.limits = [0 1];
jopt.flag_decoration = false;
pipeline = psom_add_job(pipeline,'avg_mask_func_stereo','niak_brick_vol2img',jin,jout,jopt);

%% Panel on individual registration

% Individual T1 images
jopt.colormap = 'gray';
jopt.limits = 'adaptative';
jopt.method = 'linear';
for ss = 1:length(list_subject)
    jin.source = in.ind.anat.(list_subject{ss});
    jout = [opt.folder_out 'registration' filesep list_subject{ss} '_anat_raw.png'];
    jopt.flag_decoration = false;
    pipeline = psom_add_job(pipeline,['t1_' list_subject{ss}],'niak_brick_vol2img',jin,jout,jopt);
end

% Individual BOLD images
jopt.colormap = 'jet';
jopt.limits = 'adaptative';
jopt.method = 'linear';
for ss = 1:length(list_subject)
    jin.source = in.ind.func.(list_subject{ss});
    jout = [opt.folder_out 'registration' filesep list_subject{ss} '_func.png'];
    jopt.flag_decoration = false;
    pipeline = psom_add_job(pipeline,['bold_' list_subject{ss}],'niak_brick_vol2img',jin,jout,jopt);
end

% Merge individual T1 and outline
for ss = 1:length(list_subject)
    clear jin jout jopt
    jin.background = pipeline.(['t1_' list_subject{ss}]).files_out;
    jin.overlay = pipeline.t1_outline_registration.files_out;
    jout = [opt.folder_out 'registration' filesep list_subject{ss} '_anat.png'];
    jopt.transparency = 0.7;
    jopt.threshold = 0.9;
    pipeline = psom_add_job(pipeline,['t1_' list_subject{ss} '_overlay'],'niak_brick_add_overlay',jin,jout,jopt);
end

jopt.transparency = 0.3;
jopt.threshold = 0.9;
pipeline = psom_add_job(pipeline,'template_stereo_overlay','niak_brick_add_overlay',jin,jout,jopt);

% Merge average T1 and outline
clear jin jout jopt
jin.background = pipeline.template_stereo.files_out;
jin.overlay = pipeline.t1_outline_registration.files_out;
jout = [opt.folder_out 'group' filesep 'template_stereotaxic.png'];
jopt.transparency = 0.7;
jopt.threshold = 0.9;
pipeline = psom_add_job(pipeline,'template_stereo_overlay','niak_brick_add_overlay',jin,jout,jopt);

% Add a spreadsheet to write the QC.
clear jin jout jopt
jout = [opt.folder_out 'qc_registration.csv'];
jopt.list_subject = list_subject;
pipeline = psom_add_job(pipeline,'init_report','niak_brick_init_qc_report','',jout,jopt);

%% Panel on motion

% Movies (and target image for all runs)
[list_fmri_native,labels] = niak_fmri2cell(in.ind.fmri_native);
[list_fmri_stereo,labels] = niak_fmri2cell(in.ind.fmri_stereo);
for ll = 1:length(labels)
    clear jin jout jopt

    % Native movie
    jin.source = list_fmri_native{ll};
    jin.target = list_fmri_native{ll};
    jout = [opt.folder_out 'motion' filesep 'motion_native_' labels(ll).name '.png'];
    jopt.coord = 'CEN';
    jopt.colormap = 'jet';
    jopt.flag_vertical = false;
    jopt.limits = 'adaptative';
    jopt.flag_decoration = false;
    pipeline = psom_add_job(pipeline,['motion_native_' labels(ll).name],'niak_brick_vol2img',jin,jout,jopt);

    % Native spacer
    jopt.flag_median = true;
    jout = [opt.folder_out 'motion' filesep 'target_native_' labels(ll).name '.png'];
    pipeline = psom_add_job(pipeline,['target_native_' labels(ll).name],'niak_brick_vol2img',jin,jout,jopt);

    % Stereotaxic movie
    jopt.flag_median = false;
    jopt.coord = [0 0 0];
    jin.source = list_fmri_stereo{ll};
    jin.target = list_fmri_stereo{ll};
    jout = [opt.folder_out 'motion' filesep 'motion_stereo_' labels(ll).name '.png'];
    pipeline = psom_add_job(pipeline,['motion_stereo_' labels(ll).name],'niak_brick_vol2img',jin,jout,jopt);

    % Stereotaxic spacer
    jopt.flag_median = true;
    jout = [opt.folder_out 'motion' filesep 'target_stereo_' labels(ll).name '.png'];
    pipeline = psom_add_job(pipeline,['target_stereo_' labels(ll).name],'niak_brick_vol2img',jin,jout,jopt);
end

% Motion parameters
[list_confounds,labels] = niak_fmri2cell(in.ind.confounds);
for ll = 1:length(labels)
    clear jin jout jopt
    jin = list_confounds{ll};
    jout = [opt.folder_out 'motion' filesep 'dataMotion_' labels(ll).name '.js'];
    pipeline = psom_add_job(pipeline,['motion_ind_' labels(ll).name],'niak_brick_preproc_ind_motion2report',jin,jout);
end

% Pick reference runs
labels_ref = struct;
for ss = 1:length(list_subject)
    session = fieldnames(in.ind.fmri_native.(list_subject{ss}));
    session = session{1};
    run = fieldnames(in.ind.fmri_native.(list_subject{ss}).(session));
    run = run{1};
    labels_ref.(list_subject{ss}) = [list_subject{ss} '_' session '_' run];
end

% Generate the motion report
for ll = 1:length(labels)
    clear jin jout jopt
    jout = [opt.folder_out 'motion' filesep 'motion_report_' labels(ll).name '.html'];
    jopt.label = labels(ll).name;
    jopt.label_ref = labels_ref.(labels(ll).subject);
    jopt.num_run = ll;
    pipeline = psom_add_job(pipeline,['motion_report_' labels(ll).name],'niak_brick_preproc_motion2report','',jout,jopt);
    if ll==1
        jout = [opt.folder_out 'motion' filesep 'motion.html'];
        pipeline = psom_add_job(pipeline,'motion_report','niak_brick_preproc_motion2report','',jout,jopt);
    end
end

if ~opt.flag_test
    psom_run_pipeline(pipeline,opt.psom);
end
