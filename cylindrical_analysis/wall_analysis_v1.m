% Image analysis of cylindrical bacteria walls
%   Start with fluorescence microscopy image data
%   Fit model parameters for thin fluorescent cylindrical shells
%
%   1st step: Image segmentation (manual quadrilateral selection)
%             Make some very arbitrary choices about approximate size
%   2nd step: Fit model of thin shell to image data
%             Display output
%
% Licence: CC-By 4+
% Website: https://github.com/quantitativeimaging/ELM
%
% Please reference:   (see github reference)
%
%
% Notes
%

% Good data for illustrations:
% fileIn = ['C:\Users\user\Documents\Projects\2014_Spores\testSTORM\sum\' ,...
%      '9_spores_test_image 2_Recon 1_sum_sc.tif']; %


% 0. SETUP
% fileIn = ['C:\Users\user\Documents\Projects\2014_Spores\2015_BobTurner\' ,...
%      'B_subtilis168_HADA.tif']; %
fileIn = 'B_subtilis168_HADA.tif';

flagShowModelImages = 1;

flagGetCalled = 1;  % = 1 means this script is called externally
                    %   in which case input file name is overwritten
                    %   and an externally-selected region is analysed


% 1. INPUT
%    Read a frame of fluorescence microscopy data
%
if(flagGetCalled)
    % Allow another script to call this one and overwrite file input etc.
    fileIn = suppliedFileIn;
end

imDat   = imread(fileIn);
imDatCp  = mean(imDat,3); % Make a grey copy for analysis

figure(1)
  imagesc(imDatCp);
  colormap(gray);


% 2. ANALYSIS
%    Segment the frame of image data
%    Fit a model to each segment

% MANUALLY CHOOSE ONE BACTERIA POSITION. CHOOSE AN ISOLATED ONE!
% [uiX, uiY] = getpts(1); % From image, uiX is col, uiY is row.
% uiX = floor(uiX);
% uiY = floor(uiY);

% Identify a region containing the mid-section of one bacteria
if(flagGetCalled)
   % Look up the region of interest
   myMask = suppliedMask;

   [XX,YY] = meshgrid(1:size(imDatCp,2), 1:size(imDatCp,1) );
   listX = XX(myMask);
   listY = YY(myMask);

   % Just for figure plotting purposes:
   myBox = [min(listX), min(listY), max(listX)-min(listX), max(listY)-min(listY)];
   myROI      = imcrop(imDatCp, myBox );
   background = median(myROI(myROI<mean(myROI(:))));
   maskBact   = (myROI>mean(myROI(:)));
   mySig      = myROI - background;

   listX = listX + 1 - min(listX(:));
   listY = listY + 1 - min(listY(:));

   listI = imDatCp(myMask);
   % background = median(myROI(myROI<mean(myROI(:))));
   background = min(myROI(:));
   listI = listI - background;

   hold on
   for lp = 1:numberRegions
     c = int2str(lp);
     text(max(listXi(:,lp))+dx, max(listYi(:,lp))+dy, c, ...
          'color', 'g','fontSize',14);
     plot(listXi(:,lp), listYi(:,lp), 'g');
   end
   hold off
else
   % Manually select a rectangular region of interest
   myBox = getrect(1);
   myBox = floor(myBox);

   [XX,YY] = meshgrid(1:(myBox(3)+1), 1:(myBox(4)+1));
   listX = XX(:);
   listY = YY(:);

   myROI = imcrop(imDatCp, myBox );
   % Estimate bacteria position by estimating bright fluorescence position:
   background = median(myROI(myROI<mean(myROI(:))));
   maskBact   = (myROI>mean(myROI(:)));

   mySig      = myROI - background;
   listI      = mySig(:); % Should be catenated columns
end


X       = [listX, listY];
maxdiag = sqrt(max(listX)-min(listX)^2 + (max(listY)-min(listY))^2);

% % myROI is image data in region of interest
% myROI = imcrop(imDatCp, myBox );
%
% % Estimate bacteria position by estimating bright fluorescence position:
% background = median(myROI(myROI<mean(myROI(:))));
% maskBact   = (myROI>mean(myROI(:)));
%
% mySig      = myROI - background;
% listI      = mySig(:); % Should be catenated columns


figure(2)
  imagesc(mySig);
  colormap(gray);
  title('Region of image data')
  if(flagGetCalled)
    hold on
    plot(xi - min(xi), yi - min(yi), 'g');
    hold off
  end
figure(3)
  imagesc(maskBact)
  title('Mask of approximate bacteria location')

% Obtain first guess of bacteria position and orientation from mask
stats = regionprops(maskBact,'Area','Orientation','Centroid');
  areas       = cat(1, stats.Area);
  orientations= cat(1, stats.Orientation);
  centroids   = cat(1, stats.Centroid); % X or col, Y or row

guessX      = centroids(1,1);
guessY      = centroids(1,2);
guessR      = sqrt(areas(1))/2;
guessVar    = 5;
guessHeight = max(mySig(:));
guessPsi    = orientations(1)*(pi/180); % radians

% Assemble the 1st-guess cylinder shell parameters for fitting
b0 = [guessX, guessY, guessR, guessVar, guessHeight, guessPsi];

% CALL ITERATIVE FITTING METHOD
% Fit cylinder parameters by inverse modelling:
beta = fitCylWallParams(X, listI, b0(1:6)); % Heuristic least square


% READ OUT SPORE PARAMETERS
mdlXCen =  beta(1);
mdlYCen =  beta(2);
mdlRad  =  beta(3);
mdlVar  =  beta(4);
mdlMax  =  beta(5);
mdlPsi  =  beta(6);


% 3. OUTPUT

%    Show observed and fitted pixel values in cross section.
%


if(flagShowModelImages)
  %  betaRecon = beta;
  %  betaRecon(4)=1;
  I = image_cylWall_Monte(beta, X);
  im = zeros(myBox(4), myBox(3));
  for lp = 1:length(I)
    im(X(lp,2),X(lp,1)) = I(lp);
  end
  figure(10)
  imagesc(im); % Note transpose for image orientation!
  colormap(gray)
  % figure(10)
  % scatter3(surfX, surfY, surfZ)
end
