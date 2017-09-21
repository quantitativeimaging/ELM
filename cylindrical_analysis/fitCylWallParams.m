function beta = fitCylWallParams(X, listI, b0)

maxVar        = 16; % Prevent PSF width getting stuck at high values.
flagFixedBlur = 0;  % Or set to 1 to disallow PSF width from varying. 
flagGraph     = 2;  % Which fit graph to plot.

radX   = 0.5;       % X-centre parameter adjustments to consider
radY   = 0.5;
radR   = 0.2*b0(3); % S.L.R. of ellipse
radVar = 0.30*b0(4);
radHt  = 0.1*b0(5);
% radEl  = 0.1;       % ellipticity, meaning shape factor - 1, (c/a - 1)
radPsi = 0.20;      % azimuthal orientation, radians

% b0(5) = max(listI); % 
% b0(6) = 0.20        % Force initial ellipticity to promote angle finding
% b0(7) = 0.850;

numberIts = 30;
shift     = 0.95;     % The range 0.9 to 0.95 seems reasonable
shiftCoarse = 0.975;
listParams= zeros(numberIts*2,6);


for lpIts = 1:numberIts
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);       % Quantifies misfit at initial guess

    % Check for sphere radius improvement
    IradHi = image_cylWall_Monte(b0 + [0,0,radR,0,0,0], X);
    IradLo = image_cylWall_Monte(b0 - [0,0,radR,0,0,0], X);
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
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IvarHi = image_cylWall_Monte(b0 + [0,0,0,radVar,0,0], X);
    IvarLo = image_cylWall_Monte(b0 - [0,0,0,radVar,0,0], X);
    ssVarH = sum((IvarHi - listI).^2);
    ssVarL = sum((IvarLo - listI).^2);
    if(ssVarH < sumSq && ssVarH < ssVarL)
       b0(4) = b0(4) + radVar*0.75;
    elseif(ssVarL < sumSq && ssVarL < ssVarH)
       b0(4) = abs( b0(4) - radVar*0.75 ); % Don't allow -ve (but would be ok)
    end
    radVar = shift*radVar;
    b0(4) = min([b0(4), maxVar]);
    end
    
    % Check for brightness (signal height) improvement 
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IhtHi = image_cylWall_Monte(b0 + [0,0,0,0,radHt,0], X);
    IhtLo = image_cylWall_Monte(b0 - [0,0,0,0,radHt,0], X);
    ssHtH = sum((IhtHi - listI).^2);
    ssHtL = sum((IhtLo - listI).^2);
    if(ssHtH < sumSq && ssHtH < ssHtL)
        b0(5) = b0(5) + radHt/2;
    elseif(ssHtL < sumSq && ssHtL < ssHtH)
         b0(5) = b0(5) - radHt/2;
    end
    radHt = radHt*shift;
    
    % Check for centre co-ordinate improvement (X-direction)
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IxcHi = image_cylWall_Monte(b0 + [radX,0,0,0,0,0], X);
    IxcLo = image_cylWall_Monte(b0 - [radX,0,0,0,0,0], X);
    ssXcH = sum((IxcHi - listI).^2);
    ssXcL = sum((IxcLo - listI).^2);
    if(ssXcH < sumSq && ssXcH < ssXcL)
        b0(1) = b0(1) + radX/2;
    elseif(ssXcL < sumSq && ssXcL < ssXcH)
         b0(1) = b0(1) - radX/2;
    end
    radX = radX*shiftCoarse;

    % Check for centre co-ordinate improvement (Y-direction)
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IycHi = image_cylWall_Monte(b0 + [0,radY,0,0,0,0], X);
    IycLo = image_cylWall_Monte(b0 - [0,radY,0,0,0,0], X);
    ssYcH = sum((IycHi - listI).^2);
    ssYcL = sum((IycLo - listI).^2);
    if(ssYcH < sumSq && ssYcH < ssYcL)
        b0(2) = b0(2) + radY/2;
    elseif(ssYcL < sumSq && ssYcL < ssYcH)
         b0(2) = b0(2) - radX/2;
    end
    radY = radY*shiftCoarse;
    
    % Check for azimuthal angle improvement
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IazHi = image_cylWall_Monte(b0 + [0,0,0,0,0,radPsi], X);
    IazLo = image_cylWall_Monte(b0 - [0,0,0,0,0,radPsi], X);
    ssAzH = sum((IazHi - listI).^2);
    ssAzL = sum((IazLo - listI).^2);
    if(ssAzH < sumSq && ssAzH < ssAzL)
        b0(6) = b0(6) + radPsi/2;
    elseif(ssAzL < sumSq && ssAzL < ssAzH)
         b0(6) = b0(6) - radPsi/2;
    end
    radPsi = radPsi*shift;
    
    
    listParams(lpIts,:) = b0;
    
    if(flagGraph == 1)
     figure(7)
     rr = sqrt((X(:,1)-b0(1)).^2 + (X(:,2)-b0(2)).^2);
     plot(rr, listI)
     hold on
       plot(rr,I,'g')
     hold off
     legend('Data','Fit');
    elseif(flagGraph == 2)
     % PLOT INTENSITY vs CROSS SECTION POSITION
     figure(7)
     rr = sqrt((X(:,1)-b0(1)).^2 + (X(:,2)-b0(2)).^2);
     rVecX = (X(:,1)-b0(1));
     rVecY = (X(:,2)-b0(2));
     angle = atan(rVecY./rVecX);
     t = angle + b0(6);
     
     t(t>(pi/2)) = t(t>(pi/2)) - pi;
     t(t<(-pi/2)) = t(t<(-pi/2)) + pi;
     ySec = rr.*sin(t);
     
     scatter(ySec, listI, 'bo');
     hold on
       plot(ySec,I,'gx')
     hold off
     xlabel('cross section')
     ylabel('pixel value')
     drawnow;
     
     figure(8)
     scatter(angle, t)
    end
end

% Further iterature to refine radius.
for lpIts = (numberIts+1): (2*numberIts)
    
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);       % Quantifies misfit at initial guess

    % Check for sphere radius improvement
    IradHi = image_cylWall_Monte(b0 + [0,0,radR,0,0,0], X);
    IradLo = image_cylWall_Monte(b0 - [0,0,radR,0,0,0], X);
    ssRadH = sum((IradHi - listI).^2);
    ssRadL = sum((IradLo - listI).^2);
    if(ssRadH < sumSq && ssRadH < ssRadL)
        b0(3) = b0(3) + radR/2;
    elseif(ssRadL < sumSq && ssRadL < ssRadH)
        b0(3) = b0(3) - radR/2;
    end
    radR = shift*radR;
    
    
    % Check for brightness (signal height) improvement 
    I     = image_cylWall_Monte(b0, X);
    sumSq = sum((I - listI).^2);
    IhtHi = image_cylWall_Monte(b0 + [0,0,0,0,radHt,0], X);
    IhtLo = image_cylWall_Monte(b0 - [0,0,0,0,radHt,0], X);
    ssHtH = sum((IhtHi - listI).^2);
    ssHtL = sum((IhtLo - listI).^2);
    if(ssHtH < sumSq && ssHtH < ssHtL)
        b0(5) = b0(5) + radHt/2;
    elseif(ssHtL < sumSq && ssHtL < ssHtH)
         b0(5) = b0(5) - radHt/2;
    end
    radHt = radHt*shift;
    
    listParams(lpIts,:) = b0;
    
    if(flagGraph == 1)
     figure(7)
     rr = sqrt((X(:,1)-b0(1)).^2 + (X(:,2)-b0(2)).^2);
     plot(rr, listI)
     hold on
       plot(rr,I,'g')
     hold off
     legend('Data','Fit');
    elseif(flagGraph == 2)
     % PLOT INTENSITY vs CROSS SECTION POSITION
     figure(7)
     rr = sqrt((X(:,1)-b0(1)).^2 + (X(:,2)-b0(2)).^2);
     rVecX = (X(:,1)-b0(1));
     rVecY = (X(:,2)-b0(2));
     angle = atan(rVecY./rVecX);
     t = angle + b0(6);
     
     t(t>(pi/2)) = t(t>(pi/2)) - pi;
     t(t<(-pi/2)) = t(t<(-pi/2)) + pi;
     ySec = rr.*sin(t);
     
     scatter(ySec, listI, 'bo');
     hold on
       plot(ySec,I,'rx')
     hold off
     xlabel('Cross section, px', 'fontSize', 16)
     ylabel('Pixel value', 'fontSize', 16)
     legend('Image data','Model fit')
     drawnow;
    end
end

assignin('base', 'ySec', ySec);
assignin('base', 'Ifitted', I);

beta = b0;

end
