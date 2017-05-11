function [in,out,opt] = zoo_brick_outline(in,out,opt)
% Generate a outine volume from a collection of manually selected bain regions
%
% SYNTAX: [IN,OUT,OPT] = ZOO_BRICK_OUTLINE(IN,OUT,OPT)
%
% IN.MASK_FUNC (string) the file name of a 3D fonctional mask
% IN.MASK_ANAT (string) the file name of a 3D anatomical mask
% IN.TARGET (string, default 'mni_icbm152_t1_tal_nlin_asym_09a_mask_dilated5mm') the file
% name of a 3D mask  defining the target space.
% IN.LAYOUT (string) the file name of a 3d layout volume.
% OUT (string) the file name for outline volume.
% OPT.THICK_BORDER (scalar, default [0.99]) thikness of brain border. range from 0 to 1.
% OPT.MODALITY (string, default "anat"). which brain outline wil be generated, possible
%   values "anat" for anatomical outline, "func" for functional outline
% OPT.TYPE_SYM (string, default "sym") possible value "sym" for symmetrical template
%    "asym" for asymmetrical template
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the brick does nothing but
%    update IN, OUT and OPT.
% Copyright (c) Yassine Benhajali,Pierre Bellec
% Centre de recherche de l'Institut universitaire de griatrie de Montral, 2017.
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

%% Defaults
niak_gb_vars
in = psom_struct_defaults( in , ...
    { 'mask_func','mask_anat','target' ,'layout' }, ...
    { ''         , ''        ,''       , NaN      });

if nargin < 3
    opt = struct;
end

opt = psom_struct_defaults ( opt , ...
    { 'thick_border' , 'modality' , 'type_sym' , 'flag_test' }, ...
    { 0.99           , 'anat'     , 'sym'      , false      });

if isempty(in.mask_func) && strcmp(opt.modality,'func')
  error('in.mask_func is empty, you need to specify a functional brain mask');
end

if isempty(in.mask_anat)
  in.mask_anat = [ GB_NIAK.path_template ...
  'mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_' opt.type_sym '_09a_mask.mnc.gz'];
end

if isempty(in.target) && strcmp(opt.modality,'func')
  in.target = [ GB_NIAK.path_template ...
  'mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_' opt.type_sym '_09a_mask_dilated5mm.mnc.gz'];
end

if opt.flag_test
    return
end

% set tmp file
[path_f,name_f,ext_f,flag_zip,ext_short] = niak_fileparts(in.mask_func);
tmp_file_reshape = psom_file_tmp(ext_short);
switch opt.modality
case 'func'
  %% Reshape
  command_reshape = ['mincresample -clobber ' in.mask_func ' ' tmp_file_reshape ' -like ' in.target];
  [status,msg] = system(command_reshape);
  if status ~=0
    error('There was an error calling mincresample. The call was: %s ; The error message was: %s',command_reshape,msg)
  end
  [hdr,avg_mask_bold] = niak_read_vol(tmp_file_reshape);
  [hdr,mask_t1] = niak_read_vol(in.mask_anat);

  %% Create func brain borders
  mask_t1_d = niak_morph(mask_t1,'-successive DDD');
  bold_in = avg_mask_bold > opt.thick_border;
  bold_outline = ~bold_in&mask_t1_d;
  outline  = bold_outline;

case 'anat'
  %% Create anat brain borders
  [hdr,vol] = niak_read_vol(in.mask_anat);
  vol_e = niak_morph (vol,'-successive EEEE');
  vol_d = niak_morph (vol,'-successive DDDD');
  vol_f = vol_d & ~vol_e;
  outline  = vol_f;
end

%% Merge brain border with layout
[hdr_layout,vol_layout] = niak_read_vol(in.layout);
vol_final = vol_layout | outline;
% smooth final volume layout
vol_final_s = niak_morph (vol_final,'-successive DDEE');
% write final volumes
hdr.file_name =  out;
niak_write_vol (hdr,vol_final_s);
