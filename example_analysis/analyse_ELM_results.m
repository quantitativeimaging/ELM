% Script to post-process data from the 'output' folder of ELM software
% 
% Eric Rees, 2017, Licence: CC-BY
%
% NOTES
% 1. The ELM software produces a folder with pictures and a MAT file for each
% input image file.
% 2. This script reads each MAT file in the target folder. Fitted spore
% candidates that pass a quality control check are used to report results.
% 3. The results for all the files are saved as CSVs (openable in Excel)
% 4. Pixel width is requested so results are written in nm. Default: 74 nm

% HOW TO USE THIS SCRIPT
% 1. First, run the ELM software for spherical or ellipsoidal analysis
% 2. That software will produce a results folder
% 3. Run this script and select the results folder using the dialog window
% 4. Use the dialog box to specify quality control parameters for
%    accepting / rejecting the results fitted to each image candidate, 
%    and also to specify the width (in nanometers, nm) of the pixels.
% 
% QUALITY CONTROL CRITERIA
% The following quality control criteria must all be successful for the
% parameters fitted to a candidate image to be accepted:
% 1.  Shell not implausibly large (e.g. > 700 nm radius)
% 2.  Shell not implausibly small (e.g. < 300 nm radius)
% 3.  Shell not too blurred (which often means > 1 spore, or a bad fit).
% 4.  Blur 'radius' limit thresholds the variance of the fitted Gaussian 
%    P.S.F. so a limit of 10 means sqrt(10) pixels of standard deviation
%    which at 74 nm/pixel is 234 nm (i.e. quite blurred, in practice).
%
% In practice, the size-limit quality control step should be used to remove
% obvious outliers, and most of the quality control work is done by
% checking that the fitted blur radius is below the threshold specified
% here
%
% OUTPUT - the following key data is produced in the base matlab workspace
%  'listFilenames'              the first 16 characters of filename if poss
%  'listCroppedEquivRads'       the mean radius after quality control
%  'listCroppedPercentResidual' characterises error of the fit
%
% OUTPUT - the following CSV spreadsheets are added to the folder 
% containing the results from the accepted candidate images
%
%  'Z_all_accepted_radii.csv' - a single column containing all the accepted
%   radius values from all candidate images in a folder. Useful for
%   producing a histogram of spore sizes with large amounts of data.
%
%  'Z_summary.csv' - a spreadsheet containing the mean radius and the
%  standard deviation of radii accepted candidates in each image file, 
%  together with the number of accepted and rejected candidates and the 
%  error of the fitting process for the accepted images, expressed as a 
%  percentage of the image data. In practice, errors smaller
%  than about 5% seem to be 'of good quality' in our experiments. 

% 1. INPUT
% Specify folder containing MAT files of ELM results to process
myFolder = uigetdir('../example_output','Select folder for analysis');

% 1.1 Get pixel width and quality control criteria
prompt = {'Pixel width in nm (e.g. 74)', ...
	        'Blur radius limit (as variance, e.g. 10 or 9.9)', ...
	        'Minimum radius in nm (e.g. 300)', ...
					'Maximum radius in nm (e.g. 700)',...
					'Pause after each frame ( 1 =yes)',...
					'Write output to csv spreadsheet (1 = yes)',...
				  'Save quality control figures (1=yes)' };
dlg_title = 'Analysis settings';
num_lines = 1;
defaultans = {'74','9.9','300', '700','0','1','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

pixel_width_nm = str2num(answer{1});
threshold_blur = str2num(answer{2});
min_radius     = str2num(answer{3});
max_radius     = str2num(answer{4});
pause_framewise= str2num(answer{5});
flag_write_csvs= str2num(answer{6});
flag_save_quals= str2num(answer{7});


listMats = dir([myFolder, '\*.mat']); % in the chosen directory

number_of_results = length(listMats);

listMeanEquivRad     = -ones(number_of_results, 1);  
listMedianVar        = -ones(number_of_results, 1);
listCroppedEquivRads = -ones(number_of_results, 1);
listCroppedEquivRadsStdev = -ones(number_of_results, 1);
listQualityCheckFirst = zeros(number_of_results, 1);
listNumberAccepted   = zeros(number_of_results, 1);
listNumberRejected   = zeros(number_of_results, 1);
listCroppedPercentResidual =zeros(number_of_results, 1);

output_list_accepted_radii_nm = []; % To store a long list of results

% 2. ANALYSIS
% Pull out the fitted parameters which pass quality control
% in the results for each input frame of image data.
for lp = 1:number_of_results
	lp
	load([myFolder,'\', listMats(lp).name]);
	
	% Evaluate equivalent radius of all ellipsoids
	equiv_rads = (fitData(:,6).*((1+fitData(:,9)).^(1/3)))*pixel_width_nm;

	filename= listMats(lp).name;
	if(length(filename) >=16 )
  	filename_stem = filename(1:16);
		listFilenames(lp,1:16) = filename_stem;
	else
		filename_stem = 'sample';
		listFilenames(lp,1:6) = 'sample';
	end

  qualityCheck = ones(size(fitData,1), 1);
  qualityCheck( (fitData(:,7)>threshold_blur) ) = 0; % Fails check if fit too blurred 
  qualityCheck( equiv_rads < min_radius ) = 0; % Fails check if fit is too small
  qualityCheck( equiv_rads > max_radius ) = 0; % Fails check if fit is too large


  % Record parameters to summarise the results from this image file
	listCroppedEquivRads(lp)      = mean(equiv_rads(qualityCheck==1));
	listCroppedEquivRadsStdev(lp) = std(equiv_rads(qualityCheck==1));
	listNumberAccepted(lp) = sum(qualityCheck);
	listNumberRejected(lp) = size(fitData,1) - listNumberAccepted(lp);
	  
	% Plot the fitted radius and blur of accepted + rejected candidates
	figure(6)	
	scatter(equiv_rads, fitData(:,7), 'r')
	hold on
	 scatter(equiv_rads(find(qualityCheck)), fitData(find(qualityCheck),7), 'b')
	hold off
	xlabel('r_{equivalent} / nm')
 	ylabel('PSF blur variance')
	legend('rejected', 'accepted')
	title(filename_stem)
	xlim([200 800])
	ylim([4 16])
	
	% Calculate the residual as a percentage of the 'signal'
	if(size(fitData,2)>=12) % If the 'sum of square signal' column exists
		percentResidual = fitData(:,11)./fitData(:,12);
		listCroppedPercentResidual(lp) = mean(percentResidual(qualityCheck==1));
	end

	accepted_radii = equiv_rads(qualityCheck==1);
	output_list_accepted_radii_nm = [output_list_accepted_radii_nm; accepted_radii];
	
	% Show assessed fits. This is hard-coded to produce figure '7'
	tile_assessed_segments(shell_segments, qualityCheck); 
	if(pause_framewise)
		pause
	end
	if(flag_save_quals) 
		% Save picture of visual quality check for later visual assessment
		figure(7)
		axis tight
		myIm = getframe(7);
		myFig = myIm.cdata;
		myFullFilenameFig = [myFolder,'\', listMats(lp).name];
		myFullFilenameFig(end-2:end) = [];
		myFullFilenameFig = [myFullFilenameFig,'_quality_check.png']
		imwrite(myFig, myFullFilenameFig)
	end
	
end

% OUTPUT
% Plot a graph and save results in CSV spreadsheets
figure(8)
bar(listCroppedEquivRads)
cellNames = cellstr(listFilenames(:,(1):end));
set(gca, 'XTick', 1:length(cellNames), 'XTickLabel', cellNames);
% ylim([470 570])
ylabel('equivalent radius / nm')
xlabel('Protein')
set(gca, 'fontSize', 14);

if(flag_write_csvs)
% Write all the accepted radii into a CSV file in a long list
% csvwrite(fullfile(myFolder, ['Z_all_accepted_radii.csv']), output_list_accepted_radii_nm);
fid =fopen(fullfile(myFolder, ['Z_all_accepted_radii.csv']),'wt');
  myHeader = 'Accepted radius / nm';
  fprintf(fid, [myHeader '\n']); % Write headers into what will be a csv
fclose(fid);
dlmwrite(fullfile(myFolder, ['Z_all_accepted_radii.csv']), output_list_accepted_radii_nm, '-append' )

% Write a summary of the parameters fitted to accepted spores in each TIFF input file
output_data = [listCroppedEquivRads,listCroppedEquivRadsStdev, listNumberAccepted, listNumberRejected, listCroppedPercentResidual*100];
output_files  = struct2cell(listMats);
output_filenames = output_files(1,:);
output_filenames(:) = strrep(output_filenames(:), ',', ''); % Remove the commas which someone puts into their filenames (!)

output_cell_array = cell(length(listMats), 6);
  output_cell_array(:,1)   = output_filenames;
	output_cell_array(:,2:6) = num2cell(output_data);

fid =fopen(fullfile(myFolder, ['Z_summary.csv']),'wt');
  myHeader = 'filename, mean accepted radius / nm, Standard deviation of accepted radius, number accepted, number rejected, percent residual';
  fprintf(fid, [myHeader '\n']); % Write headers into what will be a csv
  formatSpec = '%s, %d, %d, %d, %d, %d\n';
  [nrows,ncols] = size(output_cell_array);
  for row = 1:nrows
    fprintf(fid,formatSpec,output_cell_array{row,:});
  end
fclose(fid);

end