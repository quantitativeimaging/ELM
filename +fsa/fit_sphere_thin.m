function [x_centre, y_centre, radius, psf_sigma, height] = fit_sphere_thin(x_centre, y_centre, radius, psf_sigma, height, actual_image)

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

f = @(initial_params, X) fsa.cross_section_sphere_thin(initial_params(1), initial_params(2), initial_params(3), initial_params(4), initial_params(5), X);
initial_params = [x_centre, y_centre, radius, psf_sigma, height];
fit_model = fitnlm(X, actual_image(:), f, initial_params);
fit_params = fit_model.Coefficients.Estimate;

x_centre  = fit_params(1);
y_centre  = fit_params(2);
radius    = fit_params(3);
psf_sigma = fit_params(4);
height    = fit_params(5);

end
