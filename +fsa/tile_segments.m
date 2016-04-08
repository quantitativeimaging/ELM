function tiled_segments = tile_segments(shell_segments)

num_segments = length(shell_segments);
num_rows = floor(sqrt(num_segments));
num_cols = ceil(num_segments / num_rows);
segment_size = size(shell_segments{1}, 1);

tiled_segments = zeros(num_rows * segment_size, num_cols * segment_size);

for i=1:num_segments
	rows = (1 + (mod(i - 1, num_rows)) * segment_size):((mod(i - 1, num_rows) + 1) * segment_size);
	cols = (1 + floor((i - 1) / num_rows) * segment_size):(floor((i - 1) / num_rows + 1) * segment_size);
	tiled_segments(rows, cols) = shell_segments{i};
end

end
