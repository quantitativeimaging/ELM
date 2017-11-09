function I = cross_section_sphere_thin(x_shift, y_shift, radius, psf_sigma, height, X)
% CROSS_SECTION_SPHERE_THIN Return radial intensities of image of a thin spherical shell
%
%   I = CROSS_SECTION_SPHERE_THIN(x_shift, y_shift, radius, psf_sigma, height, X)
%
%   Input:
%     x_shift   - x coordinate of shell centre
%     y_shift   - y coordinate of shell centre
%     radius    - shell radius
%     psf_sigma - standard deviation of Gaussian point spread function
%     height    - height of image intensity
%     X         - array of (x, y) coordinates
%
%   Output:
%     I - vector of radial image intensities
%
%   See also CROSS_SECTION_ELLIPSOID_BIASED.


% Radial position
r = sqrt((X(:, 1) - x_shift).^2 + (X(:, 2) - y_shift).^2);

psf_variance = psf_sigma^2;

I = height * (exp(-(r - radius).^2 / (2 * psf_variance)) - exp(-(r + radius).^2 / (2 * psf_variance))) ./ r;

% For r = 0, a singular point, use the limiting case
I(r == 0) = (2 * radius * height / psf_variance) * exp(-(radius^2) / (2 * psf_variance));

end
