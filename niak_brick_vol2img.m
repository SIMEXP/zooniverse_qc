function [in,out,opt] = niak_brick_vol2img(in,out,opt)
% Generate a figure with a montage of different slices of a volume 
%
% SYNTAX: [IN,OUT,OPT] = NIAK_BRICK_VOL2IMG(IN,OUT,OPT)
%
% IN.SOURCE (string) the file name of a 3D volume
% IN.TARGET (string, default '') the file name of a 3D volume defining the target space. 
%   If left empty, or unspecified, OUT is the world space associated with IN.SOURCE 
%   i.e. the volume is resamples to have no direction cosines. 
% OUT (string) the file name for the figure. The extension will determine the type. 
% OPT.COORD (array N x 3) coordinates to generate the slices.
% OPT.COLORBAR (boolean, default true)
% OPT.COLORMAP (string, default 'gray') The type of colormap. Anything supported by 
%   the instruction `colormap` will work. 
% OPT.TITLE (string, default '') a title for the figure. 
% OPT.SIZE_IMG (vector 1x2) the size of each image in the mosaic (before concatenation in time).
%   This is purely an output parameter.
% OPT.LIMITS (vector 1x2) the limits for the colormap. By defaut it is using [min,max].
%    If a string is specified, the function will implement an adaptative strategy. 
% OPT.FLAG_DECORATION (boolean, default true) if the flag is true, produce a regular figure
%    with axis, title and colorbar. Otherwise just output the plain mosaic.
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the brick does nothing but 
%    update IN, OUT and OPT.
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

%% Defaults
in = psom_struct_defaults( in , ...
    { 'source' , 'target' }, ...
    { NaN       , ''          });
    
opt = psom_struct_defaults ( opt , ...
    { 'colorbar' , 'coord' , 'limits' , 'colormap' , 'size_slices' , 'title' , 'flag_decoration' , 'flag_test' }, ...
    { true       , NaN     , []       , 'gray'     , []            , ''      , true              , false         });

if opt.flag_test 
    return
end

%% Check the extension of the output 
[path_f,name_f,ext_f] = fileparts(out);
ext_f = ext_f(2:end);
    
%% Read the data 
[hdr.source,vol] = niak_read_vol(in.source);
if isempty(in.target)
    N = [diag(hdr.source.info.voxel_size) zeros(3,1) ; 0 0 0 1];
    W = N\([hdr.source.info.mat(1:3,1:3) zeros(3,1) ; 0 0 0 1]);
    hdr.target.info.mat = W*hdr.source.info.mat;
    hdr.target.info.dimensions = hdr.source.info.dimensions;
else
    hdr.target = niak_read_vol(in.target);    
end


%% Build image
for tt = 1:size(vol,4)
    for cc = 1:size(opt.coord,1)
        [img_tmp,slices] = niak_vol2img(hdr,vol(:,:,:,tt),opt.coord(cc,:));
        if (cc == 1)&&(tt==1)
            img = img_tmp;
            size_slices = size(slices{1});
            size_slices = [size_slices ; size(slices{2})];
            size_slices = [size_slices ; size(slices{3})];
        else
            img = [img ; img_tmp];
        end
    end
end
opt.size_img = size(img_tmp);

%% image limits
if ischar(opt.limits)
    mask = niak_mask_brain(vol);
    mvol = median(vol(mask));
    svol = niak_mad(vol(mask));
    climits = [0 mvol+2*svol];
    opt.limits = climits;
end

if isempty(opt.limits)
    climits = [min(img(:)) max(img(:))];
else
    climits = opt.limits;
end

%% No decoration: generate a bare mosaic
if ~opt.flag_decoration
    img(img>climits(2)) = climits(2);
    img(img<climits(1)) = climits(1);
    cm = colormap(opt.colormap);
    bins = linspace(climits(1),climits(2),size(cm,1));
    [tmp,idx] = histc(img,bins);
    idx(idx==0) = 1;
    rgb = zeros([size(img),3]);
    rgb(:,:,1) = reshape(cm(idx(:),1),size(img));
    rgb(:,:,2) = reshape(cm(idx(:),2),size(img));
    rgb(:,:,3) = reshape(cm(idx(:),3),size(img));
    imwrite(rgb,out);
    return
end

%% Build a figure
hf = figure;
imagesc(img,climits);

%% Colorbar/map
colormap(opt.colormap);
daspect([1 1]);
if opt.colorbar
    colorbar
end

%% Title
if ~isempty(opt.title)
    title(strrep(opt.title,'_','\_'));
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
valy = round(linspace(1,ny,size(opt.coord,1)*2+1));
label_view = cell(1,size(opt.coord,1));
for cc = 1:size(opt.coord,1)
    label_view{cc} = ' ';
end
set(ha,'ytick',valy(2*(1:size(opt.coord,1))));
set(ha,'yticklabelmode','manual')
set(ha,'yticklabel',label_view);

%% Deal with font type and size
%FN = findall(ha,'-property','FontName');
%set(FN,'FontName','/usr/share/fonts/truetype/dejavu/DejaVuSerifCondensed.ttf');
FS = findall(ha,'-property','FontSize');
set(FS,'FontSize',8);

%% Save figure
print(out,['-d' ext_f]);
close(hf)