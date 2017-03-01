function [in,out,opt] = zoo_brick_manifest(in,out,opt)
% Generate the manifest file for zooniverse platform
%
% SYNTAX: [IN,OUT,OPT] = ZOO_BRICK_MANIFEST( IN , OUT , OPT )
%
% IN not used. Available to conform to the syntax of "bricks".
% OUT (string) the name of spreadsheet with comma-separated values(CSV).
% OPT.LIST_SUBJECT (cell of strings) the ID of the subject
% OPT.MODALITY(string) modality to be loaded to zooniverse. Available 'anat' or'func'.
% OPT.FLAG_TEST (boolean, default false) if the flag is true,
%   nothing is done but update IN, OUT and OPT.
%
% _________________________________________________________________________
% Copyright (c) Yassine Benhajali, Pierre Bellec
% Centre de recherche de l'institut de geriatrie de Montreal,
% Department of Computer Science and Operations Research
% University of Montreal, Quebec, Canada, 2013-2016
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : medical imaging, fMRI preprocessing, quality control

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

%% Set default options
if ~ischar(out)
    error('OUT should be a string');
end

opt = psom_struct_defaults(opt, ...
    { 'list_subject' , 'modality' , 'flag_test' }, ...
    { NaN            , NaN        , false       });

if opt.flag_test
    return
end

switch opt.modality
 case 't1'
  template = 'anat_template_stereotaxic.png';
 case 'bold'
  template = 'func_template_stereotaxic.png';
end

%% Initialize the manifest file
manifest_report = cell(length(opt.list_subject)+1,3);
manifest_report(2:end,1) = opt.list_subject;
manifest_report(2:end,2) = strcat(opt.list_subject,'_',opt.modality,'.png');
manifest_report(2:end,3) = repmat({[opt.modality '_template_stereotaxic.png']},[length(opt.list_subject),1]);
manifest_report(1,1) = 'subject_ID';
manifest_report(1,2) = 'image1';
manifest_report(1,3) = 'image2';

%% Save the report
niak_write_csv_cell(out,manifest_report);
