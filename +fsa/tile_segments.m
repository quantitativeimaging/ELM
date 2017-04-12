function tiled_segments = tile_segments(shell_segments)

num_segments = length(shell_segments);
num_rows = floor(sqrt(num_segments));
num_cols = ceil(num_segments / num_rows);
% 2017_04_09 fix for avoiding problems if not candidates are found:
if(num_segments>0)
  segment_size = size(shell_segments{1}, 1);
else
	segment_size = 1; % this should stay empty but prevent index errors
	num_rows = 1;
	num_cols = 1;
end
	
tiled_segments = zeros(num_rows * segment_size, num_cols * segment_size);

for i=1:num_segments
	rows = (1 + (mod(i - 1, num_rows)) * segment_size):((mod(i - 1, num_rows) + 1) * segment_size);
	cols = (1 + floor((i - 1) / num_rows) * segment_size):(floor((i - 1) / num_rows + 1) * segment_size);
	tiled_segments(rows, cols) = shell_segments{i};
end

end
