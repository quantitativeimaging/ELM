function sr_recon = tile_reconstruction(sr_segments, size_image_data, centres, segment_half_size, scale_factor);
% scale_factor is ignored in this script, and a 1:1 reconstruction is made

sr_recon = zeros([size_image_data(1:2),1]); % Make gray in case was RGB

  for ii=1:size(centres, 1)
	row_centre = floor(centres(ii, 2));
	rows = (row_centre - segment_half_size):(row_centre + segment_half_size);
	col_centre = floor(centres(ii, 1));
	cols = (col_centre - segment_half_size):(col_centre + segment_half_size);
	sr_recon(rows, cols) = sr_recon(rows, cols) + sr_segments{ii};
  end

% sr_recon = -1;
end