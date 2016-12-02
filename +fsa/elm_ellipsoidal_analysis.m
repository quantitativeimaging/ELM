function elm_ellipsoidal_analysis(input_dir, output_dir, pixel_size, hough_low, hough_high, segmentation, border, seed, fluorophores, hough_sensitivity)

% Parameters for shell finding
radius_lower = hough_low;
radius_upper = hough_high;
segment_half_size = segmentation;
edge_border = border;

rng(seed);

% Set the following flag to 1 to see each segment as it is fitted
SHOW_ALL_FITS = 0;

input_files = dir(input_dir);
progress = waitbar(0, 'Performing ELM analysis...');
for image_num = 1:length(input_files)
	image_filename = input_files(image_num).name;
	if (image_filename(1) == '.')
		% Skip hidden files
		continue
	end

	image_data = imread(fullfile(input_dir, image_filename));

	[~, image_basename, ~] = fileparts(image_filename);

	% Find and display shells
	figure(1)
	[centres, radii, metric] = fsa.find_circular_shells(image_data, radius_lower, radius_upper, segment_half_size, edge_border, hough_sensitivity, true);
	title(image_basename, 'interpreter', 'none')
    
    if(length(centres) < 1)
        continue
    end

	% Tile segmented shells in figure
	shell_segments = fsa.segment_shells(image_data, centres, segment_half_size);
	tiled_segments = fsa.tile_segments(shell_segments);
	figure(2)
	imshow(tiled_segments, [])
	title(['Segmented shells for ', image_basename], 'interpreter', 'none')
    try
       shell_segment_mat = cell2mat(shell_segments);
       Mxss = max(shell_segment_mat(:));
       Mnss = min(shell_segment_mat(:));
       caxis([Mnss, Mxss])
    catch
       warning('Problem reshaping segments to set caxis'); 
    end
    
	% Save segmented shell tiles
	imwrite(mat2gray(tiled_segments), fullfile(output_dir, [image_basename, '_raw.tif']));

	% Fit all segmented shells. Display to the user one by one, if flag set
	fits = cell(length(shell_segments) + 1, 1);
    % Write headers in first row, and  copy as a string for file output
	fits{1} = {'x segment pos', 'y segment pos', 'x shift', 'y shift', 'orientation', 'semiminor axis', 'PSF variance', 'brightness', 'aspectRatioMinusOne', 'equatoriality', 'residual'};
    fitsHdr = ['x segment pos,   y segment pos,   x shift,   y shift,   orientation,   semiminor axis,   PSF variance,   brightness,   aspectRatioMinusOne,   equatoriality,   residual'];
    parfor i=1:length(shell_segments)
		actual_image = shell_segments{i};
		background = median(actual_image(actual_image < mean(actual_image(:))));
		actual_image = double(actual_image - background);

		bw_image = actual_image;
		threshold = 35 - background;
		bw_image(actual_image > threshold) = 1;
		bw_image(actual_image <= threshold) = 0;

		stats = regionprops(bw_image, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Area');

        % stats = regionprops(imSpore > mean(imSpore(:)),'Area','Orientation','Centroid');
        areas       = cat(1, stats.Area);
        orientations= cat(1, stats.Orientation);
        centroids   = cat(1, stats.Centroid);
        dat2  = [areas, orientations, centroids];
        dat2  = sortrows(dat2); % Sort by first row (Area) ascending
        orientation = dat2(end,2)*(pi/180); % estimate major axis orientation
        centroid    = dat2(end, 3:4);       % [X, Y] or [COL, ROW] estimate 
        
		x_shift = centroid(1) - segment_half_size - 1;
		y_shift = centroid(2) - segment_half_size - 1;
		% orientation =  -1; % Arbitrary initial guess
        
        
		semiminor_axis = 6;
		psf_variance = 8;
		height = max(actual_image(:));
		eccentricity = 0.2;
		equatoriality = -0.2;

		% Fit shell to spore segment
		[x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual] = fsa.fit_ellipsoid(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image);
        if(eccentricity<0) 
            % 1: Need to rename 'eccentricity' to 'aspectRatioMinusOne' or
            % a better fix by changing models to use aspect ratio
            % 2: This 'if statement' makes sure the semiminor_axis variable
            % does indeed store the short semiaxis length, and not the long
            % one due to any flip in fitting
            correct_semiminor_axis = semiminor_axis*(1+eccentricity);
            correct_semimajor_axis = semiminor_axis;
            correct_eccentricity = correct_semimajor_axis/correct_semiminor_axis - 1;
            semiminor_axis = correct_semiminor_axis;
            eccentricity = correct_eccentricity;
        end
		x_pos = centres(i, 1);
		y_pos = centres(i, 2);
		fits{i+1} = [x_pos, y_pos, x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual];
	end

	% Fitted segments
	fit_segments = cell(length(shell_segments));
	for i=1:length(fit_segments)
		fit = fits{i+1};
		fit_image = fsa.image_ellipsoid_biased(fit(3), fit(4), fit(5), fit(6), fit(7), fit(8), fit(9), fit(10), shell_segments{i});
		fit_segments{i} = fit_image;
	end
	fit_tiles = fsa.tile_segments(fit_segments);
	figure(3)
	imshow(fit_tiles, [])
	title(['Fitted shells for ', image_basename], 'interpreter', 'none')

	% Save fitted shell tiles
	imwrite(mat2gray(fit_tiles), fullfile(output_dir, [image_basename, '_fits.tif']));

	% Super-resolved segments (seems not to scale the canvas size?)
	sr_segments = cell(length(shell_segments));
	for i=1:length(sr_segments)
		fit = fits{i+1};
		sr_image = fsa.image_ellipsoid_biased(fit(3), fit(4), fit(5), fit(6), 1, fit(8), fit(9), fit(10), shell_segments{i});
		sr_segments{i} = sr_image;
	end
	sr_tiles = fsa.tile_segments(sr_segments);
    sr_recon = fsa.tile_reconstruction(sr_segments, size(image_data),centres, segment_half_size, 1); %
	figure(4)
	imshow(sr_tiles, [])
	title(['SR shells for ', image_basename], 'interpreter', 'none')

    % Display reconstruction as (non-scaled) image
    figure(5)
    imshow(sr_recon, [])
    title(['Reconstructed image for', image_basename])
    
	% Save fitted shell tiles
	imwrite(mat2gray(sr_tiles), fullfile(output_dir, [image_basename, '_sr.tif']));
    imwrite(mat2gray(sr_recon), fullfile(output_dir, [image_basename, '_recon.tif']));

	% Save fit parameters
	save(fullfile(output_dir, [image_basename, '_params.mat']), 'fits')
    
    fid = fopen([output_dir, image_basename, '_params.csv'],'wt');
      fprintf(fid, [fitsHdr '\n']); % Write headers into what will be a csv
    fclose(fid);
    dlmwrite(fullfile(output_dir, [image_basename, '_params.csv']), cell2mat(fits(2:end)), '-append' )

	% fits{1} = [];
	% csvwrite(fullfile(output_dir, [image_basename, '_params.csv']), fits)
    
	% Update waitbar
	waitbar(image_num / length(input_files));
end
close(progress)

end
