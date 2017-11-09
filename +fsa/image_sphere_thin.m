function I = image_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, imagemat)
	% IMAGE_SPHERE_THIN Return image of a thin spherical shell
	%
	%   I = IMAGE_SPHERE_THIN(x_shift, y_shift, radius, psf_sigma, height, imagemat)
	%
	%   Input:
	%     x_shift   - x coordinate of shell centre
	%     y_shift   - y coordinate of shell centre
	%     radius    - shell radius
	%     psf_sigma - standard deviation of Gaussian point spread function
	%     height    - height of image intensity
	%     imagemat  - matrix to fill with image
	%
	%   Output:
	%     I - image of spherical shell intensities
	%
	%   See also IMAGE_ELLIPSOID_BIASED.


image_width = size(imagemat, 2);
image_height = size(imagemat, 1);

image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;

[x y] = meshgrid(x, y);
X = [x(:) y(:)];

image_vector = fsa.cross_section_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, X);

imagemat = reshape(image_vector, size(imagemat));
I = imagemat;

end
