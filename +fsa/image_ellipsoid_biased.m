function I = image_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, imagemat, fluorophores, seed)
	% IMAGE_ELLIPSOID_BIASED Return image of a thin biased ellipsoidal shell
	%
	%   I = IMAGE_ELLIPSOID_BIASED(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, imagemat, varargin)
	%
	%   Input:
	%     x_shift        - x coordinate of shell centre
	%     y_shift        - y coordinate of shell centre
	%     orientation    - angle of major axis
	%     semiminor_axis - length of semi-minor axis
	%     psf_variance   - variance of Gaussian point spread function
	%     height         - height of image intensity
	%     eccentricity   - eccentricity of ellipsoid
	%     equatoriality  - degree of bias towards the equator
	%     X              - matrix to fill with image
	%     fluorophores   - number of fluorophores to simulate
	%     seed           - seed for random number generator
	%
	%   Output:
	%     I - image of ellipsoidal shell intensities
	%
	%   See also IMAGE_SPHERE_THIN.


image_width = size(imagemat, 2);
image_height = size(imagemat, 1);

image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;

[x y] = meshgrid(x, y);
X = [x(:) y(:)];

image_vector = fsa.cross_section_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, X, fluorophores, seed);

imagemat = reshape(image_vector, size(imagemat));
I = imagemat;

end
