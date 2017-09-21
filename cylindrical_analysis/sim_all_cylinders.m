% sim_all_cylinders
% 
% Generates a reconstructed image of several cylindrical fluorescent shells
% Based on parameters that are obtained by the cylindrical shell analysis
% 
% Notes
%
%
% To use this script:
%  1. First, run the analysis script, batch_cylWall.m, on sample data 
%     such as testData_Bsubtilis168_HADA_cylinders.tif
%  2. Then run this script, which will read parameters from the base 
%     workspace.


% 0. SETUP
flagSaveImage           = 0;
flagCaptureListedParams = 1;
% flagQualControl       = 1; % Apply some quality control step?
%   cutVar              = 30;
% modelType             = 1;   % Select image model. I've 1 cylinder model.
flagLimitReconToBoxes   = 1;
flagOverlay             = 1;

% Parameters for reconstruction
fitrad                  = 24;  % 
% nPoints            = 10000;  % Cylinder wall model lacks this input
scaleFc                 = 2;   % Pixel scale factor for reconstruction

% 1. INPUT
imSim      = zeros(size(imDatCp) * scaleFc ); % Empty image reconstr.n

% Put a simple quality control step here if needed

numberCyls = numberRegions;    % In case quality control voids some regions

if(flagOverlay)
   imOver = imresize(imDatCp, scaleFc, 'nearest');
end

% 2. RECONSTRUCTION
for lpCy = 1:numberCyls
 indexParams = listInd(lpCy); % Some may have been deleted by qual. contr.

 sRow = floor(listYCen(listInd == indexParams)); % Really?
 sCol = floor(listXCen(listInd == indexParams));
 
 params = [listXCen(listInd == indexParams), ... 
           listYCen(listInd == indexParams), ...
           listRad(listInd == indexParams), ...
           0.15, ... % Variance = applied PSF-like blur
           listMax(listInd == indexParams), ...
           listPsi(listInd == indexParams), ...
           ];
    
 paramsScaled = [params(1:4)*scaleFc, params(5:end)];
 
 maxdiag = listDiags( listInd==indexParams );
 fitrad  = ceil(maxdiag)*1.0;
 
 % Generate the local meshgrid of pixel co-ordinates in the reconstruction
 [XX,YY] = meshgrid( (sCol*scaleFc-fitrad):(sCol*scaleFc+fitrad),...
                    (sRow*scaleFc-fitrad):(sRow*scaleFc+fitrad) );
                
 % Hence produce a list of (x,y) co-ordinates:
 if(flagLimitReconToBoxes  == 1)
   [XXX,YYY] = meshgrid(1:size(imDatCp,2)*scaleFc, 1:size(imDatCp,1)*scaleFc);
   
   xip = listXi(:,lpCy)*scaleFc;
   yip = listYi(:,lpCy)*scaleFc;
   sz1 = size(imDatCp,2)*scaleFc;
   sz2 = size(imDatCp,1)*scaleFc;
   
   bMask = poly2mask(xip, yip, size(imDatCp,1)*scaleFc, size(imDatCp,2)*scaleFc);

   listX = XXX(bMask);
   listY = YYY(bMask);
 else
   listX = XX(:);
   listY = YY(:);
 end
 X = [listX,listY];
 
 % Simulate pixel values from image model
 I = image_cylWall_Monte(paramsScaled, X);
 
 % Add pixel values to reconstuction
 for lp = 1:length(I)
   imSim(X(lp,2),X(lp,1)) = imSim(X(lp,2),X(lp,1)) + I(lp);
 end

 if(flagOverlay)
   for lp = 1:length(I)
   % imOver = imresize(imDatCp, scaleFc, 'nearest');
   imOver(X(lp,2)-1,X(lp,1)-1) = I(lp); % offset to match resize method?
   end
 end
 
end
    
% 3. OUTPUT
figure(10)
imagesc(imSim)
colormap(gray)
axis equal
%  hold on
%    scatter(listXCen*scaleFc,listYCen*scaleFc,'r+')
%  hold off

%    For image-saving convenience:
if(flagSaveImage)
     imwrite(imSim./max(imSim(:)), 'simIm.png')
end

if(flagOverlay)
   figure(11)
   imagesc(imOver)
   colormap(gray)
   imwrite(imOver./max(imSim(:)), 'simOverlay.png')
end
