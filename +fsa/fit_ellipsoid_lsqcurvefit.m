function [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, aspect_ratio, equatoriality, residual] = fit_ellipsoid_lsqcurvefit(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, aspect_ratio, equatoriality, actual_image, ~)

image_width = size(actual_image, 2);
image_height = size(actual_image, 1);

image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;
[x, y] = meshgrid(x, y);
X = [x(:) y(:)];

% Background subtraction
background = median(actual_image(actual_image < mean(actual_image(:))));
actual_image = double(actual_image - background);

f = @(initial_params, X) fsa.cross_section_ellipsoid_biased(initial_params(1), initial_params(2), initial_params(3), initial_params(4), initial_params(5), initial_params(6), initial_params(7), initial_params(8), X);
initial_params = [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, aspect_ratio, equatoriality];
opts = optimoptions('lsqcurvefit', 'Display', 'none', 'TolFun', 1e-10);
upper_bounds = [5, 5, pi, 10, 10, max(actual_image(:)) * 2, 2, 0];
lower_bounds = [-5, -5, -pi, 3, 3, max(actual_image(:)) * 0.5, -2, -1];
fit_params = lsqcurvefit(f, initial_params, X, actual_image(:), lower_bounds, upper_bounds, opts);

x_shift        = fit_params(1);
y_shift        = fit_params(2);
orientation    = fit_params(3);
semiminor_axis = fit_params(4);
psf_variance   = fit_params(5);
height         = fit_params(6);
aspect_ratio   = fit_params(7);
equatoriality  = fit_params(8);
fit = fsa.cross_section_ellipsoid_biased(fit_params(1), fit_params(2), fit_params(3), fit_params(4), fit_params(5), fit_params(6), fit_params(7), fit_params(8), X);
residual = sum((actual_image(:) - fit).^2);

end
