% Manually generate a single spore reconstruction:
% Scripts to make a thin sphere reconstruction...

 % a 31x31 square. Radius = 15*74nm 

scale_length = 6;
recon_rad = 11;
imagemat = zeros(1+2*recon_rad*scale_length);

% Red channel parameters (BclA)
x_centre = 0;
y_centre = 0;
radius = scale_length * 565.8/74;
psf_sigma = (22/74)*scale_length;
height = 100;

im_red = fsa.image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat);

figure(1)
imagesc(im_red)


% Green channel parameters (e.g. CotD)
x_centre = 0;
y_centre = 0;
radius = scale_length * 483.7/74;
psf_sigma = (12/74)*scale_length;
height = 100;

im_green = fsa.image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat);

figure(2)
imagesc(im_green)
colormap(gray)

% Blue channel parameters (e.g. CwlJ)
x_centre = 0;
y_centre = 0;
radius = scale_length * 446.7/74;
psf_sigma = (12/74)*scale_length;
height = 100;

im_blue = fsa.image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat);


% 4th-channel parameters (e.g. SleL)
x_centre = 0;
y_centre = 0;
radius = scale_length * 455.9/74;
psf_sigma = (12.5/74)*scale_length;
height = 100;
im_4 = fsa.image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat);

% 5th-channel parameters ~(e.g. GerP x6)
x_centre = 0;
y_centre = 0;
radius = scale_length * 440/74;
psf_sigma = (20/74)*scale_length;
height = 100;
im_5 = fsa.image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat);

imcol = []; % clear to assist re-writing at different size
imcol(:,:,1) = im_red;
imcol(:,:,2) = im_green;
imcol(:,:,3) = im_blue;

figure(4)
imshow(imcol./max(imcol(:) ))

imwrite(im_red./max(im_red(:)),'example_output/BclA.png')
imwrite(im_green./max(im_green(:)),'example_output/CotD.png')
imwrite(im_blue./max(im_blue(:)),'example_output/CwlJ.png')
imwrite(im_4./max(im_4(:)),'example_output/SleL.png')
imwrite(im_5./max(im_5(:)),'example_output/GerPs.png')
