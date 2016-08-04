function [files,opt] = niak_grab_qc_fmri_preprocess(path_data,opt)
% Grab fMRI preprocessed files for quality control. 
%
% SYNTAX: FILES_OUT = NIAK_GRAB_QC_FMRI_PREPROCESS( PATH_DATA , OPT)
%
% PATH_DATA (string, default pwd) full path to the outputs of NIAK_PIPELINE_FMRI_PREPROCESS
% OPT.REGISTRATION (string, default 'nonlinear') type of registration 
%   to QC. Available options: 'linear', 'nonlinear'.
% OPT.TEMPLATE (string, default 'mni_icbm152_nlin_sym_09a') the template that 
%       was used as a target for brain coregistration. This option only applies if 
%       the template cannot be found in the output of the preprocessed data. 
%       Available choices: 
%           'mni_icbm152_nlin_asym_09a' : an adult symmetric template 
%              (18.5 - 43 y.o., 40 iterations of non-linear fit). 
%           'mni_icbm152_nlin_sym_09a' : an adult asymmetric template 
%             (18.5 - 43 y.o., 20 iterations of non-linear fit). 
% FILES (structure) the list of expected inputs for NIAK_PIPELINE_QC_FMRI_PREPROCESS. 
%
% Copyright (c) Yassine Benhajali, Pierre Bellec 
%               Centre de recherche de l'institut de Geriatrie de Montreal,
%               Departement d'informatique et de recherche operationnelle,
%               Universite de Montral, 2016.
% Maintainer: pierre.bellec@criugm.qc.ca, yassine.ben.haj.ali@umontreal.ca
% See licensing information in the code.
% Keywords: grabber, QC
% See also: NIAK_PIPELINE_QC_FMRI_PREPROCESS

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

niak_gb_vars

%% Defaults
if nargin<1
    path_data = pwd;
end
path_data = niak_full_path(path_data);
files = struct();

if nargin<2
    opt = struct;
end
opt = psom_struct_defaults( opt , ...
    { 'registration' , 'template'                      }, ...
    { 'nonlinear'    , 'mni_icbm152_nlin_sym_09a' });
    
%% List of folders
path_anat  = [path_data 'anat' filesep];
path_qc    = [path_data 'quality_control' filesep];
if ~exist(path_anat,'dir')||~exist(path_qc,'dir')
    error('The specified folder does not contain some expected outputs from the fMRI preprocess (anat ; quality_control)')
end

%% Check the format of the data
file_aal = [path_anat 'template_aal.mnc'];
if psom_exist(file_aal)
    ext = '.mnc';
end

file_aal = [path_anat 'template_aal.mnc.gz'];
if psom_exist(file_aal)
    ext = '.mnc.gz';
end

file_aal = [path_anat 'template_aal.nii'];
if psom_exist(file_aal)
    ext = '.nii';
end

file_aal = [path_anat 'template_aal.nii.gz'];
if psom_exist(file_aal)
    ext = '.nii.gz';
end

%% Grab the list of subjects
list_qc = dir(path_anat);
list_qc = {list_qc.name};
list_qc = list_qc(~ismember(list_qc,{'.','..'}));
nb_subject = 0;
for num_q = 1:length(list_qc)
    subject = list_qc{num_q};
    switch opt.registration
        case 'nonlinear'
            file_anat = [path_anat  subject filesep 'anat_' subject '_nuc_stereonl' ext];
            file_func = [path_anat  subject filesep 'func_' subject '_mean_stereonl' ext];
        case 'linear'
            file_anat = [path_anat  subject filesep 'anat_' subject '_nuc_stereolin' ext];
            file_func = [path_anat  subject filesep 'func_' subject '_mean_stereolin' ext];
        otherwise
           error('%s is an unknown type of registration',opt.registration);
    end
    if  psom_exist(file_anat)&&psom_exist(file_func)
        files.anat.(subject) = file_anat;
        files.func.(subject) = file_func;
    end
end

%% Grab the template
files.template = [path_anat 'template_anat_stereo' ext];
if ~exist(files.template);
    switch opt.template
        case 'mni_icbm152_nlin_sym_09a'
            files.template =  [gb_niak_path_niak 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep 'mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz'];    
        case 'mni_icbm152_nlin_asym_09a'
            files.template =  [gb_niak_path_niak 'template' filesep 'mni-models_icbm152-nl-2009-1.0' filesep 'mni_icbm152_t1_tal_nlin_asym_09a.mnc.gz'];
        otherwise
            error('%s is an unkown template space',opt.template)
    end
end  