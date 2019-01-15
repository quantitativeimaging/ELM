function [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual] = fit_ellipsoid_nelder_meade(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image, ~)
% PURPOSE
% Try to fit the ellipsoid model parameters using Nelder-Meade algorithm
%   Could try a library version or a modified implementation for this task
% PLAUSIBLE CUSTOMISATIONS OF NELDER MEADE:
%   - Prevent PSF variance exceeding 12 (produces slowly-varying output)
%   - Adjust forward model to decrease stochastic variation (# dyes?)
%   - Different Nelder-Meade parameters (alpha, gamma, rho, sigma) for
%   different variables. Try allowing orientation to vary rapidly. But this
%   may be unnecessary. 
%   - Constrain aspect ratio, or axis lengths, to plausible range
%   - Don't overconstrain PSF variance - it may still provide a good
%   indicator of a correct fit (i.e. if a large PSF variance is fitted, the
%   result might be discarded). 
%   - Run a few iterations of cylic-coordinate descent after getting an 
%   initial solution from Nelder-Meade (JDM)
%   - Reasonably strict bounds on all possible parameters (JDM)


% fsa.cross_section_ellipsoid_biased returns a list of pixel values
% Need to subtract actual pixel values, square and sum, to get objective function for minimisation 
I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);

end