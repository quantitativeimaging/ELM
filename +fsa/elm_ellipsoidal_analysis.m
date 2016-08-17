function elm_ellipsoidal_analysis(input_dir, output_dir, pixel_size)

% Parameters for shell finding
radius_lower = 5;
radius_upper = 15;
segment_half_size = 20;
edge_border = 0;

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
	[centres, radii, metric] = fsa.find_circular_shells(image_data, radius_lower, radius_upper, segment_half_size, edge_border, true);
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

	% Save segmented shell tiles
	imwrite(mat2gray(tiled_segments), fullfile(output_dir, [image_basename, '_raw.tif']));

	% Fit all segmented shells and display to the user one by one, if flag set
	fits = cell(length(shell_segments) + 1, 1);
	fits{1} = {'x segment pos', 'y segment pos', 'x shift', 'y shift', 'orientation', 'semiminor axis', 'PSF variance', 'brightness', 'aspect ratio', 'equatoriality', 'residual'};
	parfor i=1:length(shell_segments)
		actual_image = shell_segments{i};
		background = median(actual_image(actual_image < mean(actual_image(:))));
		actual_image = double(actual_image - background);

		bw_image = actual_image;
		threshold = 35 - background;
		bw_image(actual_image > threshold) = 1;
		bw_image(actual_image <= threshold) = 0;

		stats = regionprops(bw_image, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');

		x_shift = 0;
		y_shift = 0;
		orientation = -1;
		semiminor_axis = 6;
		psf_variance = 6;
		height = max(actual_image(:));
		eccentricity = 0.2;
		equatoriality = -0.2;

		% Fit shell to spore segment
		[x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, residual] = fsa.fit_ellipsoid(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image);

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

	% Super-resolved segments
	sr_segments = cell(length(shell_segments));
	for i=1:length(sr_segments)
		fit = fits{i+1};
		sr_image = fsa.image_ellipsoid_biased(fit(3), fit(4), fit(5), fit(6), 1, fit(8), fit(9), fit(10), shell_segments{i});
		sr_segments{i} = sr_image;
	end
	sr_tiles = fsa.tile_segments(sr_segments);
	figure(4)
	imshow(sr_tiles, [])
	title(['SR shells for ', image_basename], 'interpreter', 'none')

	% Save fitted shell tiles
	imwrite(mat2gray(sr_tiles), fullfile(output_dir, [image_basename, '_sr.tif']));

	% Save fit parameters
	save(fullfile(output_dir, [image_basename, '_params.mat']), 'fits')
	fits{1} = [];
	csvwrite(fullfile(output_dir, [image_basename, '_params.csv']), fits)

	% Update waitbar
	waitbar(image_num / length(input_files));
end
close(progress)

end
