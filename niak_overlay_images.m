function [img12,img2_rgb] = niak_overlay_images(img1,img2,opt)
% overlay two images: a master image (ex: template) and salve one( ex: layout)  
%
% SYNTAX: IMG12 = NIAK_OVERLAY_IMAGES(IMG1,IMG2,OPT)
%
% IMG1 (array N x 2 or 3) backgoud image
% IMG2 (array N x 2) Overlay image
% OPT.THRESH (integer, default 0.20)
% OPT.ALPHA (integer, default 0.25)
% OPT.COLOR (string, default 'red') The color of the overlay image 

% Copyright (c) Pierre Bellec , Yassine Benhajali
% Centre de recherche de l'Institut universitaire de griatrie de Montral, 2016.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : visualization, montage

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


% Options 
if nargin < 3
   opt = struct;
end

opt = psom_struct_defaults ( opt , ...
    { 'thresh' , 'alpha' , 'color' }, ...
    { 0.25     , 0.2     , 'red'   });


%% Color layout template
switch opt.color
      case 'red'
      img2_rgb = cat(3,img2,zeros(size(img1)),zeros(size(img2)));
      case 'yellow'
      img2_rgb = cat(3,img2,zeros(size(img1)),zeros(size(img2)));
      case 'green'
      img2_rgb = cat(3,img2,zeros(size(img1)),zeros(size(img2)));
end

%% Merge layout with template
img2 = img2_rgb;
img1 = repmat(img1,[1 1 3]); 
img2_i = mean(img2,3);
img2_i = img2_i / max(img2_i(:));
mask = img2_i > opt.thresh;
mask = repmat(mask,[1 1 size(img2,3)]);
img12 = img1;
img12(mask) = opt.alpha * img2(mask) + (1-opt.alpha) * img1(mask); ' ...

