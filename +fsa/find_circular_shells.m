function [centres, radii, metric] = find_circular_shells(image_data, radius_lower, radius_upper, segment_half_size, edge_border, ShowPlot);

[centres, radii, metric] = imfindcircles(image_data, [radius_lower radius_upper]);


% Remove candidates near edge
A = [centres, radii, metric];
A(A(:, 1) < segment_half_size + edge_border + 1, :) = [];
A(A(:, 1) > size(image_data, 2) - (segment_half_size + edge_border) - 1, :) = [];
A(A(:, 2) < segment_half_size + edge_border + 1, :) = [];
A(A(:, 2) > size(image_data, 1) - (segment_half_size + edge_border) - 1, :) = [];


% Anti-collision filtering
centres = A(:, 1:2);
[index, distance] = rangesearch(centres, centres, 2 * segment_half_size);

[dummy, Index] = sort(cellfun('size', index, 2), 'descend');
old_index = index;
index = index(Index);

% indices_remove = [];
% for (i=1:length(index))
% 	curr_indices = setdiff(index{i}, i);
% 	curr_indices = find(old_index == curr_indices);
% 	for(j=1:length(curr_indices))
% 		index{curr_indices(j)} = index{curr_indices(j)}(index{curr_indices(j)} ~= i);
% 	end
% 	indices_remove = [indices_remove, curr_indices];
% end
% A(indices_remove, :) = [];

centres = A(:, 1:2);
radii   = A(:, 3);
metric  = A(:, 4);

if (ShowPlot)
	imshow(image_data, []);
	colormap(gray)
	truesize;
	% hold on
	% scatter(centres(:,1),centres(:,2), pi * radii.^2, 'co', 'lineWidth', 2)
	hold on
	for (i=1:size(centres, 1))
		x = centres(i, 1) - segment_half_size;
		y = centres(i, 2) - segment_half_size;
		rectangle('Position', [x, y, segment_half_size*2, segment_half_size*2], 'EdgeColor', 'r')
	end
	hold on
	rectangle('Position', [edge_border, edge_border, size(image_data, 2) - 2*edge_border, size(image_data, 1) - 2*edge_border], 'EdgeColor', 'g')
	axis equal
	hold off
end

end
