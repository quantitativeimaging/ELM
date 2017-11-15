function I = cross_section_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, X, fluorophores, seed)
% CROSS_SECTION_ELLIPSOID_BIASED Return radial intensities of image of a thin biased ellipsoidal shell
%
%   I = CROSS_SECTION_ELLIPSOID_BIASED(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, X, fluorophores)
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
%     X              - array of (x, y) coordinates
%     fluorophores   - number of fluorophores to simulate
%     seed           - seed for random number generator
%
%   Output:
%     I - vector of radial image intensities
%
%   See also CROSS_SECTION_SPHERE_THIN.

rng(seed);

num_points = uint16(fluorophores);
aspect_ratio = eccentricity + 1;
phi = 2 * pi * rand(num_points, 1);
cos_theta = 2 * rand(num_points, 1) - 1;

sin_theta = sqrt(1 - cos_theta.^2);
semimajor_axis = semiminor_axis * aspect_ratio;
x_axis = semimajor_axis .* sin_theta .* cos(phi);
y_axis = semiminor_axis .* sin_theta .* sin(phi);
z_axis = semiminor_axis .* cos_theta;

% Use attenuation sampling to produce uniformly dense surface brightness then polarise it (make poles relatively brighter) with a sinT term
brightness_ratio = sqrt((y_axis ./ semiminor_axis).^2 + (z_axis ./ semiminor_axis).^2 + (x_axis .* semiminor_axis).^2 ./ (semimajor_axis^4));
sinT = sqrt((y_axis.^2 + z_axis.^2) ./ sqrt(x_axis.^2 + y_axis.^2 + z_axis.^2));
brightness_ratio = brightness_ratio .* (1 + equatoriality .* sinT);

% Produce surfaces
surface_x = x_axis .* cos(orientation) + y_axis .* sin(orientation)  + x_shift;
surface_y = -x_axis .* sin(orientation) + y_axis .* cos(orientation) + y_shift;
num_points_accepted = length(surface_x);

% Calculate intensities
I = zeros([size(X, 1), 1]);
for point = 1:num_points_accepted
	square_displacements = ((surface_x(point) - X(:, 1) ).^2 + (surface_y(point) - X(:, 2) ).^2 + (1/11)*(z_axis(point)).^2 );
	intensities = exp(-(square_displacements) / (2 * abs(psf_variance)));
	I = I + intensities * brightness_ratio(point);
end
I = I * height / max(I(:));

% Clean-up rare troublesome values...
I(isnan(I)) = 0;
I(isinf(I)) = height / 2;

end
