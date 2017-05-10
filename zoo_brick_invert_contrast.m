function [in,out,opt] = zoo_brick_invert_contrast(in,out,opt)
% Invert a volume color contrast
%
% SYNTAX: [IN,OUT,OPT] = ZOO_BRICK_INVERT_CONTRAST(IN,OUT,OPT)
%
% IN.SOURCE (string) the file name of a 3D volume to be iverted
% IN.MASK (string, default '') the file name of a 3D volume defining the mask.
%    notice: this mask is used only if OPT.ONLY_MASK set to true.
% OUT (string) the file name for the inverted volume.
% OPT.ONLY_MASK (boolean, default false) if true the brick only mask volume background.
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the brick does nothing but
%    update IN, OUT and OPT.
%
% Copyright (c) Pierre Bellec , Yassine Benhajali
% Centre de recherche de l'Institut universitaire de griatrie de Montral, 2016.
% Maintainer : pierre.bellec@criugm.qc.ca; yassine.benhajali@gmail.com
% See licensing information in the code.
% Keywords : visualization, contrast, 3D brain volumes

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
    { 'source' , 'mask' }, ...
    { NaN      , ''     });

if isempty(in.mask)
  in.mask = [ GB_NIAK.path_template ...
  'mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_asym_09a_mask.mnc.gz'];
end

if ~ischar(out)
  error('OUT should be a string');
end

if nargin < 3
    opt = struct;
end

% Options
opt = psom_struct_defaults ( opt , ...
    { 'perc_max' , 'perc_min' , 'only_mask' , 'flag_test' }, ...
    { 0.99       , 0.01       , false       , false       });

if opt.flag_test
    return
end

%% Read the source
[hdr,source] = niak_read_vol(in.source);

%% if only mask background
if opt.only_mask
  [hdr,mask]   = niak_read_vol(in.mask);
  source(~mask) = max(source(:));
  hdr.file_name = out;
  niak_write_vol(hdr,source);
  return
end

% Invert image contrast
mask = niak_mask_brain(source);
mask = mask>0;
val = sort(source(mask),'ascend');
vmin = val(round(opt.perc_min*length(val)));
vmax = val(round(opt.perc_max*length(val)));
source(source<vmin) = vmin;
source(source>vmax) = vmax;
source(mask) = (source(mask) - vmin)/(vmax-vmin);
source(~mask) = 0;
source = 1 - source;
source = abs(source);
hdr.file_name = out;
niak_write_vol(hdr,source);
