% batch_cylWall
%  A script to process several user-selected regions of cylindrical shells
%
% Eric Rees 2015
% Cylindrical fluorescent shell analysis
% Quthor: Eric Rees, 2017
% License: CC-BY 4.0

% INSTRUCTIONS:
% 
%  Ensure the scripts (wall_analysis_v1, image_cylWall_Monte 
%  and fitCylWallMonte) are on the Matlab path (e.g. in the same folder as
%  this script, and use this script as the working folder).
%
% 1. In wall_analysis_v1.m make sure flagGetCalled = 1; is set
% 2. In this script, batch_cylWall.m, name the input file, including .tif
% 3. In this script, set a suitable number of regions to process
% 4. Run this script
% 5. When Figure 1 appears, use the cursor to select regions of interest
%     Regions of interest should have 4 corners (any more will be ignored)
%     Choose straight, cylindrical segments of specimens
%     Select the feature and some surrounding dark space
%     Try to select a region with greater length along the specimen than
%     its width, otherwise the auto-initial guess of orientation may be bad
% 6. Wait for the inverse modelling to process (may take 30 s per segment)
% 7. Multiply listRads by pixel width to get physical cylinder radius
% 8. A quality control step may be needed to reject misfitted regions. 
%     


% 1. INPUT
% 1.1 Specify image file to process
[filename, pathname] = uigetfile({'*.tif'},'Select input image','../example_images/cylinders/');
suppliedFileIn = [pathname, filename];
% 1.1.1 Specify output folder
folder_output_name = uigetdir('../example_output','Select folder for output');

% 1.2 Preview file and get user to specify how many candidate areas they
% will select (default is one).
imDat    = imread(suppliedFileIn);
imDatCp  = mean(imDat,3); % Make a grey copy for analysis
figure(1)
  imagesc(imDatCp);
  colormap(gray);
answer = inputdlg('How many regions of interest?','user region of interest selection',1,{'1'});
numberRegions = str2num(answer{1});

% 2. ESTABLISH WHICH REGIONS TO PROCESS
% Allocate arrays to store selected regions, and their fitted parameters 
listMasks = false([size(imDatCp),numberRegions]); %
listXi    = zeros(5, numberRegions);
listYi    = zeros(5, numberRegions);
listRad   = zeros(numberRegions, 1);
listXCen  = zeros(numberRegions, 1);
listYCen  = zeros(numberRegions, 1);
listVar   = zeros(numberRegions, 1);
listMax   = zeros(numberRegions, 1);
listPsi   = zeros(numberRegions, 1);
listDiags = zeros(numberRegions, 1); % Long diagonal length of box
listInd   = zeros(numberRegions, 1); % Index (in case of later deletions)

dx = 4; 
dy = 1; % Displacement so the text labels do not overlay the data points

% Obtain the required number of regions from user input
for lpUser = 1:numberRegions
    [aMask, xi, yi] = roipoly;
    listMasks(:,:,lpUser) = aMask;
    if(length(xi)>=5) % If a quadrilateral or higher is chosen
      listXi(:,lpUser)     = xi(1:5); % record 4 vertices. 
      listYi(:,lpUser)     = yi(1:5);
    end
    figure(1)
    hold on
     c = int2str(lpUser);
     text(max(xi)+dx, max(yi)+dy, c, 'color', 'g','fontSize',14);
     plot(xi, yi, 'g')
    hold off  
end

% 3. CALL WALL ANALYSIS AND SAVE FITTED PARAMETERS
for lpBatch = 1:numberRegions
 
    % suppliedMask = listMasks(:,:,lpBatch); 
    xi = listXi(:,lpBatch);
    yi = listYi(:,lpBatch);
    suppliedMask = poly2mask(xi, yi, size(imDatCp,1), size(imDatCp,2));
    
    wall_analysis_v1; % Fit cylinder parameters to this segment
    
		% Store fitted parameters
    listRad(lpBatch)  = mdlRad;
    listXCen(lpBatch) = mdlXCen + min(listXi(:,lpBatch));
    listYCen(lpBatch) = mdlYCen + min(listYi(:,lpBatch));
    listVar(lpBatch)  = mdlVar;
    listMax(lpBatch)  = mdlMax;
    listPsi(lpBatch)  = mdlPsi;
    listDiags(lpBatch)= maxdiag;
    listInd(lpBatch)  = lpBatch;
  
end

% 4. GENERATE A RECONSTRUCTED IMAGE
sim_all_cylinders

% 5. WRITE OVERLAY IMAGE INTO OUTPUT FOLDER
imwrite(imOver./max(imOver(:)), [folder_output_name,'\',filename,'.png' ]);