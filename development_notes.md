# Development notes for ELM

Eric J. Rees

# Problems that need fixing:

## Identified circa 29 Nov 2016:
1. In the ELM code presented  with the Biophys J paper (2015), there
   was no problem with the software outputting significant numbers of
   aspect ratio estimates (listFittedAR) which were < 1.
   The aspect ratio is intended to be b/a, with semimajor axis length
   b and semiminor axis length a.
   In the (2015) ELM code, the initial guess of orientation was
   obtained from regionprops(), with an ad hoc thresholding method,
   and was a good guess, so only very bad
   fits flipped aspect ratio from >1 to <1.
   In the new ELM code, the initial guess of orientation is not from
   regionprops (i.e. it doesn't use the same method) and often gets the
   aspect ratio flipped to <1. This means the 'orientation' is out
   by 90 degrees, and attempts to calculate the equivalent sphere
   radius as = (a^2 b)^(1/3) go wrong, because a and b are flipped
   compared to the way we may expect to find them.
   This problem should be fixed by:

 * implementing a better initial guess of orientation, and/or
 * implementing a check to fix flipped axis lengths (and orientations should be flipped by 90 degrees, or actually pi/2 radians at the same time).
 * Note that the new 'fast fitting method' using lsqcurvefit as an initial fitting step is actually so good it doens't need a good orientation guess from regionprops in order to get good fits. The problem seems to be that it is able to explore orientation and aspect ratio ranges much more widely and can switch the long- and short-axes in a way that was not anticipated in the original method.
 * identified 29 Nov 2016
 >- Have put in the check to flip values if the fitted aspect ratio is less than unity. This is in 'elm_ellipsoid_analysis'.
 >- Still need to do the orientation estimate from regionprops().

2. Need to fix the data array output, so that simple Matlab arrays of
   numbers are available for students to play with. (Alternatively,
   the listedFittedRadii arrays might be provided as single row arrays.)
   Also add an array for just the column headers, for reference, if not saving individual lists
   * identified 29 Nov 2016
   >- note should fix csv to include headers.
   >- but cell2mat(fits(2:end) ) extracts the array of values, and fits{1} extracts the headers, and programmers can use this, given instructions in readme.md user guide. Most users will probably just read the csv, which should include headers.
   >- Have implemented a hardcoded fprintf header, and dlmwrite for both spherical and ellipsoidal code.
   >- Need to edit Aspect Ratio to match header in ellipsoid -

3. Need to add a reconstruction algorithm to produce a visualisation to compare with the raw image data. Possibly add a button to the advanced GUI for this -- or add a script that takes data from fits{} and also perhaps from rawImParams{}.
   * identified 29 Nov 2016
   * Could add a function fsa.tile_reconstruction(sr_segments, fits) to assign the generated recons to each position in real space. Will need to check orientation works. Disentangling cell arrays from this may be tricky.
   * Problem (?). sr_image = fsa.image_ellipsoid_biased() seems not to scale the canvas size. I'd prefer this for a full reconstruction. This could be ignored for now, and a full scaled_sr_image() and tile_scaled_reconstruction() could be added later.

   >- added a basic tile_reconstruction for the ellipsoid model but need to improve fitting a bit now.

   * Need to add tile reconstruction for spherical model.

4. Consider shifting all parameter arrays to match the new reconstruction code (b1 array) rather than shuffling the b0 parameter array.
   * identified 29 Nov 2016
   * Make sure parameter arrays match, as far as possible, for spheres and ellipsoids, to make sure outputs are consistent. This will make it easier to feed the results into reconstruction code.

5. Note that the enforced limit on psfVar at 9 (pix^2) may be biasing
fitted radii. But this limit was enforced to prevent mis-fitting.
Try improving initial guess of psfVar before running relaxing this limit.
   * identified 29 Nov 2016

   >- Changed limit to 16 in 'fit_ellipsoid_ejr_unmod'

6. Fix colour scale on panel of segmented images.
   >- identified 29 Nov 2016
   >- done for ellipsoids in 'elm_ellipsoidal_analysis'
   >- done (copy of above) in 'elm_spherical_analysis'
   >- Used try/catch for both in case cell array reshaping ever breaks
   >- Done, EJR, 1 Dec 2016

7. Write instructions for IIB student / collaborator post-processing of results, and possibly edit the saved output to make this analysis easier.
   * identified 29 Nov 2016
   >- Writing this at the end of readme.md

8. Default parameters in new GUI should be loaded on program startup rather than needing to be applied in the advanced GUI panel.
 * identified 29 Nov 2016

 >- Done. 1 Dec 2016. Uses setappdata() and getappdata().

9. Consider switching from cell arrays to structures (or just arrays) for objects like shell_segments. (Longer term.)
 * Probably sensible - but longer term

10. Add (..., 'Sensitivity', value) to imfindcircles in find_circular_shells and make controllable. Default seems to be 0.85 currently - keep this default, but load explicitly on program start.
 * identified 29 Nov 2016

 >- Done, as default 0.85 sensitivity on startup, and editable and re-defualtable in advanced settings panel. 1 Dec 2016

11. Write a reconstruction script that takes (fits, im_size, segment_half_size, scale_factor) as inputs.
 * Include nice scaling, and possibly number_of_fluorophores.

12. Why is the sample data RGB colour, not 16 bit gray?
 * In some places, this means it is necessary to take care when generating thing such as a reconstruction of size(image_data) as this should be intended to be monochrome but can end up being RGB.
 * Do we need to include a 'flatten' option to convert RGB input to gray.
 * Really, we should try to capture 16 bit data! Micromanager does this fine!

13. Put in checkbox option to bring back debugging images.
 * It is hard to check that orientation fitting works properly without these.

14. Resized GUI for correct display on Windows.
>- Done 2 Dec 2016. Not sure what it will look like on an Apple.

15. Put in extra radiobutton for the ellipsoid fit that uses lsqcurvefit.

16. Put in a thing to save 'raw_data_parameters'
