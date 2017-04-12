function [centres, radii, metric] = find_circular_shells(image_data, radius_lower, radius_upper, segment_half_size, edge_border, hough_sensitivity, ShowPlot);

flagExcludeAll = 1; % If 1, exclude collisions strictly to counter clumps

[centres, radii, metric] = imfindcircles(image_data, [radius_lower radius_upper], 'Sensitivity', hough_sensitivity);

% Remove candidates near edge
A = [centres, radii, metric];
if(size(A, 2) > 1)
    A(A(:, 1) < segment_half_size + edge_border + 1, :) = [];
    A(A(:, 1) > size(image_data, 2) - (segment_half_size + edge_border) - 1, :) = [];
    A(A(:, 2) < segment_half_size + edge_border + 1, :) = [];
    A(A(:, 2) > size(image_data, 1) - (segment_half_size + edge_border) - 1, :) = [];
end

% Anti-collision filtering: removes double-detections of ellipsoids
if(size(A, 2) > 1)
	centres = A(:,1:2);
	radii   = A(:,3);
	metric  = A(:,4);
	collisionRadius = segment_half_size * 1.3; % *1.3 is arbitary
	lp = 1;
	while lp < length(radii) % For each candidate
		dists = sqrt((centres(:,1)-centres(lp,1)).^2 + (centres(:,2)-centres(lp,2)).^2 );
		dists(lp) = collisionRadius + 100; % Don't exlcude the candidate due to itself
		minDist = min(dists);
		
		if(flagExcludeAll == 1) % To exlude all candidates in clumps of 3+
		  indexOfClumpers = find((dists < collisionRadius));
			if( length(indexOfClumpers) > 1 ) % group of 2 = 1 clash = ellipsoid
				indexOfClumpers = [indexOfClumpers;lp];
				centres(indexOfClumpers,:) = [];
				radii(indexOfClumpers) = [];
				metric(indexOfClumpers) = [];
			end
		end
		
		if(minDist<collisionRadius) % Exclude candidate if one other is nearby
			centres(lp,:) = [];
			radii(lp) = [];
			metric(lp) = [];
			continue; % Allow list to shorten onto current lp index
		else
			lp = lp + 1;  % Move to next canditate
		end
	end
end

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
		dx = 5; 
    dy = -1; % displacement so the text does not overlay the data points
    text(centres(i,1)+dx, centres(i,2)+dy, int2str(i), 'color','g','fontSize',12);
	end
	hold on
	rectangle('Position', [edge_border, edge_border, size(image_data, 2) - 2*edge_border, size(image_data, 1) - 2*edge_border], 'EdgeColor', 'g')
	axis equal
	hold off
end

end
