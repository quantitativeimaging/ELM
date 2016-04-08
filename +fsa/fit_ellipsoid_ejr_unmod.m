function [x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality] = fit_ellipsoid_ejr_unmod(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, actual_image, ~)

maxVar        = 9; % Prevent PSF width getting stuck at high values.
flagFixedBlur = 0;  % Or set to 1 to disallow PSF width from varying.

b0 = [x_shift, y_shift, semiminor_axis, psf_variance, height, eccentricity, orientation, equatoriality];
listI = actual_image(:);

image_width = size(actual_image, 2);
image_height = size(actual_image, 1);
image_centre_x = image_width / 2;
image_centre_y = image_height / 2;

x = (1:image_width) - image_centre_x;
y = -(1:image_height) + image_centre_y;

[x, y] = meshgrid(x, y);
X = [x(:), y(:)];

radX   = 0.75;
radY   = 0.75;
radR   = 0.2 * b0(3);
radVar = 0.5 * b0(4);
radHt  = 0.1 * b0(5);
radEl  = 0.1;
radPsi = 0.20;
radEq  = 0.05;

numberIts = 30;
shift = 0.95; % The range 0.9 to 0.95 seems reasonable
shiftCoarse = 0.975;
listParams = zeros(numberIts * 2, 8);



for lpIts = 1:numberIts
    % I     = image_biasEl_Monte(b0, X);
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);       % Quantifies misfit at initial guess

    % Check for sphere radius improvement
		b0mod = b0 + [0,0,radR,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IradHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    b0mod = b0 - [0,0,radR,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IradLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssRadH = sum((IradHi - listI).^2);
    ssRadL = sum((IradLo - listI).^2);
    if(ssRadH < sumSq && ssRadH < ssRadL)
        b0(3) = b0(3) + radR/2;
    elseif(ssRadL < sumSq && ssRadL < ssRadH)
        b0(3) = b0(3) - radR/2;
    end
    radR = shift*radR;

    % Check for blur radius (point spread function) improvement
    if(flagFixedBlur ==0) % Skip this is a fixed blur width is being used.
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);
		b0mod = b0 + [0,0,0,radVar,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IvarHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [0,0,0,radVar,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IvarLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssVarH = sum((IvarHi - listI).^2);
    ssVarL = sum((IvarLo - listI).^2);
    if(ssVarH < sumSq && ssVarH < ssVarL)
       b0(4) = b0(4) + radVar/2;
    elseif(ssVarL < sumSq && ssVarL < ssVarH)
       b0(4) = abs( b0(4) - radVar/2 ); % Don't allow -ve (but would be ok)
    end
    radVar = shift*radVar;
    b0(4) = min([b0(4), maxVar]);
    end

    % Check for brightness (signal height) improvement
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);
		b0mod = b0 + [0,0,0,0,radHt,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IhtHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [0,0,0,0,radHt,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IhtLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssHtH = sum((IhtHi - listI).^2);
    ssHtL = sum((IhtLo - listI).^2);
    if(ssHtH < sumSq && ssHtH < ssHtL)
        b0(5) = b0(5) + radHt/2;
    elseif(ssHtL < sumSq && ssHtL < ssHtH)
         b0(5) = b0(5) - radHt/2;
    end
    radHt = radHt*shift;

    % Check for centre co-ordinate improvement (X-direction)
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);
		b0mod = b0 + [radX,0,0,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IxcHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [radX,0,0,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IxcLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssXcH = sum((IxcHi - listI).^2);
    ssXcL = sum((IxcLo - listI).^2);
    if(ssXcH < sumSq && ssXcH < ssXcL)
        b0(1) = b0(1) + radX/2;
    elseif(ssXcL < sumSq && ssXcL < ssXcH)
         b0(1) = b0(1) - radX/2;
    end
    radX = radX*shiftCoarse;

    % Check for centre co-ordinate improvement (Y-direction)
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		sumSq = sum((I - listI).^2);
		b0mod = b0 + [0,radY,0,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IycHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [0,radY,0,0,0,0,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IycLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssYcH = sum((IycHi - listI).^2);
    ssYcL = sum((IycLo - listI).^2);
    if(ssYcH < sumSq && ssYcH < ssYcL)
        b0(2) = b0(2) + radY/2;
    elseif(ssYcL < sumSq && ssYcL < ssYcH)
         b0(2) = b0(2) - radX/2;
    end
    radY = radY*shiftCoarse;

    % Check for azimuthal angle improvement
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);
		b0mod = b0 + [0,0,0,0,0,0,radPsi,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IazHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [0,0,0,0,0,0,radPsi,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IazLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssAzH = sum((IazHi - listI).^2);
    ssAzL = sum((IazLo - listI).^2);
    if(ssAzH < sumSq && ssAzH < ssAzL)
        b0(7) = b0(7) + radPsi/2;
    elseif(ssAzL < sumSq && ssAzL < ssAzH)
         b0(7) = b0(7) - radPsi/2;
    end
    radPsi = radPsi*shift;

    % Check for ellipticity improvement
		b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
		I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    sumSq = sum((I - listI).^2);
		b0mod = b0 + [0,0,0,0,0,radEl,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IelHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
		b0mod = b0 - [0,0,0,0,0,radEl,0,0];
		b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
		IelLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
    ssElH = sum((IelHi - listI).^2);
    ssElL = sum((IelLo - listI).^2);
    if(ssElH < sumSq && ssElH < ssElL)
        b0(6) = b0(6) + radEl*3/4;
    elseif(ssElL < sumSq && ssElL < ssElH)
         b0(6) = b0(6) - radEl*3/4; % Don't allow -ve ellipticity
    end
    radEl = radEl*shift;

    listParams(lpIts,:) = b0;
end

% Further iterature to refine radius.
for lpIts = (numberIts+1): (2*numberIts)
	b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
	I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	sumSq = sum((I - listI).^2);       % Quantifies misfit at initial guess

	% Check for sphere radius improvement
	b0mod = b0 + [0,0,radR,0,0,0,0,0];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IradHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	b0mod = b0 - [0,0,radR,0,0,0,0,0];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IradLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	ssRadH = sum((IradHi - listI).^2);
	ssRadL = sum((IradLo - listI).^2);
	if(ssRadH < sumSq && ssRadH < ssRadL)
			b0(3) = b0(3) + radR/2;
	elseif(ssRadL < sumSq && ssRadL < ssRadH)
			b0(3) = b0(3) - radR/2;
	end
	radR = shift*radR;



	b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
	I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	sumSq = sum((I - listI).^2);       % Quantifies misfit at initial guess

	% Check for equatoriality improvement
	b0mod = b0 + [0,0,0,0,0,0,0,radEq];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IeqHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	b0mod = b0 - [0,0,0,0,0,0,0,radEq];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IeqLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	ssEqH = sum((IeqHi - listI).^2);
	ssEqL = sum((IeqLo - listI).^2);
	if(ssEqH < sumSq && ssEqH < ssEqL)
			b0(8) = b0(8) + radEq*0.75;
	elseif(ssEqL < sumSq && ssEqL < ssRadH)
			b0(8) = b0(8) - radEq*0.75;
	end
	radEq = shift*radEq;



	% Check for brightness (signal height) improvement
	b1 = [b0(1), b0(2), b0(7), b0(3), b0(4), b0(5), b0(6), b0(8)];
	I = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	sumSq = sum((I - listI).^2);
	b0mod = b0 + [0,0,0,0,radHt,0,0,0];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IhtHi = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	b0mod = b0 - [0,0,0,0,radHt,0,0,0];
	b1 = [b0mod(1), b0mod(2), b0mod(7), b0mod(3), b0mod(4), b0mod(5), b0mod(6), b0mod(8)];
	IhtLo = fsa.cross_section_ellipsoid_biased(b1(1), b1(2), b1(3), b1(4), b1(5), b1(6), b1(7), b1(8), X);
	ssHtH = sum((IhtHi - listI).^2);
	ssHtL = sum((IhtLo - listI).^2);
	if(ssHtH < sumSq && ssHtH < ssHtL)
			b0(5) = b0(5) + radHt/2;
	elseif(ssHtL < sumSq && ssHtL < ssHtH)
			 b0(5) = b0(5) - radHt/2;
	end
	radHt = radHt*shift;

    listParams(lpIts,:) = b0;
end

x_shift = b0(1);
y_shift = b0(2);
semiminor_axis = b0(3);
psf_variance = b0(4);
height = b0(5);
eccentricity = b0(6);
orientation = b0(7);
equatoriality = b0(8);

figure(8)
plot(listParams(:,3), 'b');
hold on
 plot(listParams(:,4), 'g');
 %plot(listParams(:,5)), 'r';
 plot(listParams(:,1), 'r');
 plot(listParams(:,2), 'k');
 plot(listParams(:,6), 'k--');
 plot(listParams(:,7), 'r--');
 plot(listParams(:,8), 'm');
hold off
legend('radius', 'var', 'xCen', 'yCen', 'Ellip', 'Azimuth','Equatoriality')
xlabel('fit iterations')

end
