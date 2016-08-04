function img = niak_visu_slices(hdr,vol,coord,opt)
% Generate a figure with a montage of different slices of a volume 
%
% SYNTAX: [IN,OUT,OPT] = NIAK_VISU_SLICES(HDR,VOL,COORD,OPT)
%
% HDR.SOURCE (structure) the header of the volume
% HDR.TARGET (structure) the header of a volume defining the sampling space
% VOL        (3D array) brain volume, in stereotaxic space.
% COORD      (vector 1x3) defines which slices to display (X,Y,Z).
% OPT.METHOD     (string, default 'linear') the spatial interpolation 
%            method. See METHOD in INTERP2.
% OPT.TYPE_FLIP (string, default 'rot90') how to flip slices to represent them. 
% OPT.COLORBAR (boolean, default true)
% OPT.COLORMAP (string, default 'gray') The type of colormap. Anything supported by 
%   the instruction `colormap` will work. 
% OPT.TITLE (string, default '') a title for the figure. 
% OPT.LIMITS (vector 1x2) the limits for the colormap. By defaut it is using [min,max].
%
% Copyright (c) Pierre Bellec
% Centre de recherche de l'Institut universitaire de gériatrie de Montréal, 2016.
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

%% Set defaults
if nargin < 4
    opt = struct;
end

opt = psom_struct_defaults ( opt , ...
    { 'method' , 'type_flip'  , 'colorbar' , 'limits' , 'colormap' , 'title' }, ...
    { 'linear'     , 'rot90'      , true         , []        , 'gray'         , ''       });
    
%% Generate the image
opt_img.method = opt.method;
opt_img.type_flip = opt.type_flip;
for cc = 1:size(coord,1)
    [img_tmp,slices] = niak_vol2img(hdr,vol,coord(cc,:),opt_img);
    if cc == 1
        img = img_tmp;
        size_slices = size(slices{1});
        size_slices = [size_slices ; size(slices{2})];
        size_slices = [size_slices ; size(slices{3})];
    else
        img = [img ; img_tmp];
    end
end

%% The image
hf = figure;
if isempty(opt.limits)
    climits = [min(img(:)) max(img(:))];
else
    climits = opt.limits;
end
imagesc(img,climits);

%% Colorbar/map
colormap(opt.colormap);
daspect([1 1]);
if opt.colorbar
    colorbar
end

%% Title
if ~isempty(opt.title)
    title(opt.title)
end

%% Set X axis 
ha = gca;
valx = zeros(3,1);
valx(1) = size_slices(1,2)/2;
valx(2) = size_slices(2,2)/2 + size_slices(1,2);
valx(3) = size_slices(3,2)/2 + size_slices(2,2) + size_slices(1,2);
set(ha,'xtick',valx);
set(ha,'xticklabel',{'sagital','coronal','axial'})

%% Set y axis
ny = size(img,1);
valy = round(linspace(1,ny,size(coord,1)*2+1));
label_view = cell(1,size(coord,1));
for cc = 1:size(coord,1)
    label_view{cc} = sprintf('(%i,%i,%i)',round(coord(cc,1)),round(coord(cc,2)),round(coord(cc,3)));
end
set(ha,'ytick',valy(2*(1:size(coord,1))));
set(ha,'yticklabelmode','manual')
set(ha,'yticklabel',label_view);

%% Deal with font type and size
%FN = findall(ha,'-property','FontName');
%set(FN,'FontName','/usr/share/fonts/truetype/dejavu/DejaVuSerifCondensed.ttf');
FS = findall(ha,'-property','FontSize');
set(FS,'FontSize',8);