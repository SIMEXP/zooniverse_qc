function [in,out,opt] = niak_brick_img2gif(in,out,opt)
% Generate GIF animated image from anatomical, template or functional images.
% This function is made for zooniverse QC project
%
% SYNTAX: [IN,OUT,OPT] = NIAK_BRICK_IMG2GIF(IN,OUT,OPT)
%
% IN.IMG1 (string) file name of the first image (.png or .jpg)
% IN.IMG2 (string) file name of the second image (.png or .jpg)
% OUT (string) the file name for the GIF animated image. 
% OPT.RATIO (integer, default 0.6) reduce image size, numbers can range from 0.1 to 1.
% OPT.ALPHA (integer, default 3) Number of transition frames betwenen to images to build the gif animation
% OPT.TRANSITION_DELAY (array 1 x N , where N = alpha +1, default delay time  = 0.3). Delay time betwen frames.
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the brick does nothing but 
%    update IN, OUT and OPT.
%
% Note:
%   This brick needs the PSOM library to run. 
%   http://psom.simexp-lab.org/
%
% Copyright (c) Pierre Bellec , Yassine Benhajali
% Centre de recherche de l'Institut universitaire de griatrie de Montral, 2016.
% Maintainer : pierre.bellec@criugm.qc.ca ; yanamarji@gmail.com
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

%% Defaults
in = psom_struct_defaults( in , ...
    { 'img1' , 'img2' }, ...
    { NaN    , NaN });
    
if nargin < 2 
   warning( 'output filename specified: we will use the current directory : s%/out_img2gif.gif n\',pwd) 
   out = 'out_img2gif.gif';
end  
opt = psom_struct_defaults ( opt , ...
    { 'ratio' , 'alpha' , 'transition_delay' , 'flag_test' }, ...
    { 0.6     , 3       , []                 , false         });

if isempty(opt.transition_delay)
   opt.transition_delay = repmat(0.3,1,opt.alpha+1);
elseif size(opt.transition_delay)(2) ~= opt.alpha+1
   error('Transition array size must be 1 x (alpha+1)')
end

if opt.flag_test 
    return
end
    
%% Read the images 
img1 = imread(in.img1);
img2 = imread(in.img2);
dims_img1 = (ndims(img1));
dims_img2 = (ndims(img2));

if (dims_img1 > 3) || (dims_img2 > 3)
   error('one or all images have more than 3 dimensions')
end
 
%% Generate image 
ratio = opt.ratio;
alpha = linspace(0,1,opt.alpha);
dims_cases = dims_img1 - dims_img2;
switch  dims_cases
       case 0 
           if dims_img1 == 2
              imgr = imresize (img1,ratio);
              img_all = zeros([size(imgr),1,length(alpha)]);
              for aa =1:length(alpha)
                  img_all(:,:,1,aa) = imresize(alpha(aa)*img1 + (1-alpha(aa))*img2,ratio);
              end
              img_all2 = zeros([size(imgr) 1 length(alpha)*2-2]);
           elseif dims_img1 == 3
              imgr = imresize (img1,ratio);
              img_all = zeros([size(imgr),length(alpha)]);
              for aa =1:length(alpha)
                  img_all(:,:,:,aa) = imresize(alpha(aa)*img1 + (1-alpha(aa))*img2,ratio);
              end
              img_all2 = zeros([size(imgr) length(alpha)*2-2]);
           end
       case 1
           imgr = imresize (img1,ratio);
           img_all = zeros([size(imgr),length(alpha)]);
           for aa =1:length(alpha)
               img_all(:,:,:,aa) = imresize(alpha(aa)*img1 + (1-alpha(aa))*img2,ratio);
           end
           img_all2 = zeros([size(imgr) length(alpha)*2-2]);          
       case -1
           imgr = imresize (img2,ratio);
           img_all = zeros([size(imgr),length(alpha)]);
           for aa =1:length(alpha)
               img_all(:,:,:,aa) = imresize(alpha(aa)*img2 + (1-alpha(aa))*img1,ratio);
           end
           img_all2 = zeros([size(imgr) length(alpha)*2-2]);     
end     
img_all2(:,:,:,1:length(alpha)) = img_all;
img_all2(:,:,:,length(alpha)+1:end) = img_all(:,:,:,end-1:-1:2);

%% Save image
imwrite(img_all2/max(img_all2(:)),out,'Quality',0.25,'DelayTime',opt.transition_delay);