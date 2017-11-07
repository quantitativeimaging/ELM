% Script to post-process data from the 'output' folder of ELM software
% Eric Rees, 2017 CC-BY
%
% NOTES
% 1. The ELM software produces a folder with pictures and a MAT file for each
% input image file.
% 2. This script reads each MAT file in the target folder. Fitted spore
% candidates that pass quality control are used to get a results.
% 3. The results for all the files can then be copy-pasted to Excel
% 4. A hard-coded pixel width is set in this script (default: 74 nm)

% QUALITY CONTROL CRITERIA
%  Shell not implausibly large (e.g. > 700 nm radius)
%  Shell not implausibly small (e.g. < 300 nm radius)
%  Shell not too blurred (which often means > 1 spore, or a bad fit).
%
% OUTPUT - written to base matlab workspace
%  'listFilenames'              the first 16 characters of filename if poss
%  'listCroppedEquivRads'       the mean radius after quality control
%  'listCroppedPercentResidual' characterises error of the fit

% 1. INPUT
% Specify folder containing MAT files of ELM results to process
myFolder = uigetdir('../example_output','Select folder for analysis');

% 1.1 Get pixel width and quality control criteria
prompt = {'Pixel width in nm (e.g. 74)', ...
	        'Blur radius limit (e.g. 10)', ...
	        'Minimum radius in nm', ...
					'Maximum radius in nm'};
dlg_title = 'Analysis settings';
num_lines = 1;
defaultans = {'74','10','300', '700'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

pixel_width_nm = str2num(answer{1});
threshold_blur = str2num(answer{2});
min_radius     = str2num(answer{3});
max_radius     = str2num(answer{4});


listMats = dir([myFolder, '\*.mat']); % in current directory

number_of_results = length(listMats);

listMeanEquivRad     = -ones(number_of_results, 1);  
listMedianVar        = -ones(number_of_results, 1);
listCroppedEquivRads = -ones(number_of_results, 1);
listCroppedEquivRadsStdev = -ones(number_of_results, 1);
listQualityCheckFirst = zeros(number_of_results, 1);
listNumberAccepted   = zeros(number_of_results, 1);
listNumberRejected   = zeros(number_of_results, 1);
listCroppedPercentResidual =zeros(number_of_results, 1);

output_list_accepted_radii_nm = [];
% output_list_filenames        = [];

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
		listFilenames(lp,1) = 'a';
	end

qualityCheck = ones(size(fitData,1), 1);
qualityCheck( (fitData(:,7)>threshold_blur) ) = 0; % Fails check if fit too blurred 
qualityCheck( equiv_rads < min_radius ) = 0; % Fails check if fit is too small
qualityCheck( equiv_rads > max_radius ) = 0; % Fails check if fit is too large


  % figure(2)
	listCroppedEquivRads(lp)      = mean(equiv_rads(qualityCheck==1));
	listCroppedEquivRadsStdev(lp) = std(equiv_rads(qualityCheck==1));
	listNumberAccepted(lp) = sum(qualityCheck);
	listNumberRejected(lp) = size(fitData,1) - listNumberAccepted(lp);
	  
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
	
	% get residual as a % of 'signal energy'
	if(size(fitData,2)>=12) % If the 'sum of square signal' column exists
		percentResidual = fitData(:,11)./fitData(:,12);
		listCroppedPercentResidual(lp) = mean(percentResidual(qualityCheck==1));
	end

	accepted_radii = equiv_rads(qualityCheck==1);
	output_list_accepted_radii_nm = [output_list_accepted_radii_nm; accepted_radii];
	%pause
end

figure(8)
bar(listCroppedEquivRads)
cellNames = cellstr(listFilenames(:,(1):end));
set(gca, 'XTick', 1:length(cellNames), 'XTickLabel', cellNames);
% ylim([470 570])
ylabel('equivalent radius / nm')
xlabel('Protein')
set(gca, 'fontSize', 14);

% Write all the accepted radii into a CSV file in a big list
% csvwrite(fullfile(myFolder, ['Z_all_accepted_radii.csv']), output_list_accepted_radii_nm);
fid =fopen(fullfile(myFolder, ['Z_all_accepted_radii.csv']),'wt');
  myHeader = 'Accepted radius / nm';
  fprintf(fid, [myHeader '\n']); % Write headers into what will be a csv
fclose(fid);
dlmwrite(fullfile(myFolder, ['Z_all_accepted_radii.csv']), output_list_accepted_radii_nm, '-append' )

% csvwrite(fullfile(myFolder, ['Z_summary_of_tiffs.csv']), 1);
fid =fopen(fullfile(myFolder, ['Z_summary.csv']),'wt');
  myHeader = 'mean accepted radius / nm, Standard deviation of accepted radius, number accepted, number rejected, percent residual';
  fprintf(fid, [myHeader '\n']); % Write headers into what will be a csv
fclose(fid);
  output_data = [listCroppedEquivRads,listCroppedEquivRadsStdev, listNumberAccepted, listNumberRejected, listCroppedPercentResidual];
dlmwrite(fullfile(myFolder, ['Z_summary.csv'] ), output_data, '-append' )
