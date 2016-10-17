function I = image_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, imagemat, varargin)

image_width = size(imagemat, 2);
image_height = size(imagemat, 1);

image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;

[x y] = meshgrid(x, y);
X = [x(:) y(:)];

if nargin > 9
	num_points = varargin{1};
	image_vector = fsa.cross_section_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, X, num_points);
else
	image_vector = fsa.cross_section_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, X);
end

imagemat = reshape(image_vector, size(imagemat));
I = imagemat;

end
