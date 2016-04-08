function [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality] = fit_ellipsoid(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image)

x_shift_step = 0.75;
y_shift_step = 0.75;
orientation_step = 0.2;
semiminor_axis_step = 0.1;
psf_variance_step = 0.1;
height_step = 1;
eccentricity_step = 0;
equatoriality_step = 0.05;

steps = [x_shift_step, y_shift_step, orientation_step, semiminor_axis_step, psf_variance_step, height_step, eccentricity_step, equatoriality_step];

[x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality] = fsa.fit_ellipsoid_ejr_unmod(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image, steps);

end
