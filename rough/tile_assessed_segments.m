% Generates tiled segments and indicates which pass quality control
% This method assumes square segments
function tiled_assessed_segments = tile_assessed_segments(shell_segments, qualityCheck)

num_segments = length(shell_segments);
num_rows = floor(sqrt(num_segments));
num_cols = ceil(num_segments / num_rows);
segment_size = size(shell_segments{1}, 1);

tiled_assessed_segments = zeros(num_rows * segment_size, num_cols * segment_size);

for i=1:num_segments
	rows = (1 + (mod(i - 1, num_rows)) * segment_size):((mod(i - 1, num_rows) + 1) * segment_size);
	cols = (1 + floor((i - 1) / num_rows) * segment_size):(floor((i - 1) / num_rows + 1) * segment_size);
	tiled_assessed_segments(rows, cols) = shell_segments{i};
end

figure(7)
imagesc(tiled_assessed_segments)
colormap(gray)
hold on
for i=1:num_segments
	positRow = (1 + (mod(i - 1, num_rows) + 0.5)*segment_size);
	positCol = (1 + (floor((i-1)/num_rows) + 0.5)*segment_size);
	if(qualityCheck(i)==1)
		scatter(positCol, positRow, 'go')
	else
		scatter(positCol, positRow, 'rx')
	end
end
hold off

end