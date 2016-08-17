function [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual] = fit_ellipsoid(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image)

[x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual] = fsa.fit_ellipsoid_lsqcurvefit(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image);

end
