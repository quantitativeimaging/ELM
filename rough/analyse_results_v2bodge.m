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
%  Shell not too huge (e.g. > 700 nm radius)
%  Shell not too small (e.g. < 300 nm radius)
%  Shell not too blurred (which often means > 1 spore, or a bad fit).
%
% OUTPUT
%  'listFilenames' - the first 16 characters of each filename
%  'listCroppedEquivRads' - the mean radius after quality control

% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_IIB_Yao_Annie\2016_11_28_results_try2\';
% myFolder = 'D:\EJR\Projects\2016_IIB_spores\2017_02_08_filter_test\results\';
% myFolder = 'D:\data\2B_spores\results_2017_02_09\';

% myFolder = 'D:\data\2B_spores\results_2017_02_15\';

% 2017: March, Driks, exosporium and PS (polysaccharide):
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_Driks\2017_03_14_data\R_G_output\';

% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_03_20_output\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_Driks\2017_03_09_data\output\'
% 2017 April Abhi Ghosh, cereus:
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_06_output\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_03_20_output_spherical\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_10_output\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_11_output\';

% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_12_output_B\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_11_output_B\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_10_output_B\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_03_20_output_B\';
myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_06_output_B\';

% Bailey spores June 2017:
%myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_Spores_Dave_Bailey\2017_06_26_full_output\';

% Doerte 2-colour
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_Doerte_spores\Exo_and_PS_results\';

listMats = dir([myFolder, '*.mat']); % in current directory

number_of_results = length(listMats);

listMeanEquivRad     = -ones(number_of_results, 1);  
listMedianVar        = -ones(number_of_results, 1);
listCroppedEquivRads = -ones(number_of_results, 1);
listQualityCheckFirst = zeros(number_of_results, 1);
listNumberAccepted   = zeros(number_of_results, 1);
listCroppedPercentResidual =zeros(number_of_results, 1);

for lp = 1:number_of_results
	lp
	load([myFolder, listMats(lp).name]);
	
	% % fitData should load OK - if not, read from fits cellarray
	%   fitData = fits(2:end); % fitData should now just be loaded. 
	%   fitData = cell2mat(fitData);
	equiv_rads = (fitData(:,6).*((1+fitData(:,9)).^(1/3)))*74;
	
	% listMedianEquivRad(lp) = median(equiv_rads);
	% listMedianEquivVar(lp) = median(fitData(:,7));

	filename= listMats(lp).name;
	if(length(filename) >=16 )
  	filename_stem = filename(1:16);
		listFilenames(lp,1:16) = filename_stem;
	else
		filename_stem = 'sample';
		listFilenames(lp,1) = 'a';
	end

qualityCheck = ones(size(fitData,1), 1);
qualityCheck( (fitData(:,7)>10) ) = 0; % Fails check if fit too blurred 
qualityCheck( equiv_rads < 300 ) = 0; % Fails check if fit is too small
qualityCheck( equiv_rads > 700 ) = 0; % Fails check if fit is too large


  % figure(2)
	% crop_equiv_rads = equiv_rads;
	% crop_equiv_rads(fitData(:,7)>12)=[]; % Remove poor (too blurred) fits
	% crop_equiv_rads(crop_equiv_rads<300)=[]; % Remove implausibly small fits
	% crop_equiv_rads(crop_equiv_rads>700)=[]; % Remove implausibly large fits
	listCroppedEquivRads(lp) = mean(equiv_rads(qualityCheck==1));
	listNumberAccepted(lp) = sum(qualityCheck);
	  
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

	%pause
end

figure(8)
bar(listCroppedEquivRads)
cellNames = cellstr(listFilenames(:,(end):end));
set(gca, 'XTick', 1:length(cellNames), 'XTickLabel', cellNames);
ylim([470 570])
ylabel('equivalent radius / nm')
xlabel('Protein')
set(gca, 'fontSize', 14);


