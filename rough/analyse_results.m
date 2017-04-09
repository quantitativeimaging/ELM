% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_IIB_Yao_Annie\2016_11_28_results_try2\';
% myFolder = 'D:\EJR\Projects\2016_IIB_spores\2017_02_08_filter_test\results\';
% myFolder = 'D:\data\2B_spores\results_2017_02_09\';

% myFolder = 'D:\data\2B_spores\results_2017_02_15\';

% 2017: March, Driks:
myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_Driks\2017_03_14_data\R_G_output\';

% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_03_20_output\';
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2016_Driks\2017_03_09_data\output\'
% 2017 April Abhi:
% myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_04_06_output\';
myFolder = 'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_GerP\2017_03_20_output_spherical\';

listMats = dir([myFolder, '*.mat']); % in current directory

number_of_results = length(listMats);

listMeanEquivRad     = -ones(number_of_results, 1);
listMedianVar        = -ones(number_of_results, 1);
listCroppedEquivRads = -ones(number_of_results, 1);
listQualityCheckFirst = zeros(number_of_results, 1);
listNumberAccepted   = zeros(number_of_results, 1);

for lp = 1:number_of_results
	load([myFolder, listMats(lp).name]);
	
	% fitData = fits(2:end); % fitData should now just be loaded. 
	% fitData = cell2mat(fitData);
	equiv_rads = (fitData(:,6).*((1+fitData(:,9)).^(1/3)))*74;
	
	listMeanEquivRad(lp) = median(equiv_rads);
	listMeanEquivVar(lp) = median(fitData(:,7));

	filename= listMats(lp).name;
	if(length(filename) >=16 )
  	filename_stem = filename(1:16);
		listFilenames(lp,1:16) = filename_stem;
	else
		filename_stem = 'sample';
		listFilenames(lp,1) = 'a';
	end
% 	figure(1)
% 	scatter(fit_data(:,11), equiv_rads)
% 	title(filename_stem)
% 	ylim([350 600])
% 	xlim([0 300000])
% 	hold on
% 	 plot([0 30000], [listMeanEquivRad(lp), listMeanEquivRad(lp)], 'r')
% 	hold off

qualityCheck = ones(size(fitData,1), 1);
qualityCheck( (fitData(:,7)>10) ) = 0; % Fails check if fit too blurred 
qualityCheck( equiv_rads < 300 ) = 0; % Fails check if fit is too small
qualityCheck( equiv_rads > 700 ) = 0; % Fails check if fit is too large

tiled_assessed_segments = tile_assessed_segments(shell_segments, qualityCheck);

% listQualityCheckFirst(lp) = qualityCheck(1); % For one spore per frame

  figure(2)
	crop_equiv_rads = equiv_rads;
	crop_equiv_rads(fitData(:,7)>10)=[]; % Remove poor (too blurred) fits
	crop_equiv_rads(crop_equiv_rads<300)=[]; % Remove implausibly small fits
	crop_equiv_rads(crop_equiv_rads>700)=[]; % Remove implausibly large fits
	listCroppedEquivRads(lp) = mean(crop_equiv_rads);
	listNumberAccepted(lp) = sum(qualityCheck);
	
 	hist(crop_equiv_rads, [300:5:700]);
 	title(filename_stem)
	xlabel('Equivalent radius / nm')
	ylabel('number')
	set(gca, 'fontSize', 14)

	
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

	
%   figure (9)
%   scatter(equiv_rads, fit_data(:,7));
%   title(filename_stem)
% 	ylim([350 600])
%   xlim([0 16])
% 	hold on
%    plot([0 16], [listMeanEquivRad(lp), listMeanEquivRad(lp)], 'r')
%   hold off
% 		hold on
%    plot([mean(fit_data(:,7)) mean(fit_data(:,7))], [350, 600], 'r')
%   hold off
% 	set(gca, 'fontSize', 14)
% 	xlabel('r_{equivalent} / nm')
% 	ylabel('PSF blur variance')

% % For YAo + Annie:
% equiv_rads = (fit_data(:,6).*((1+fit_data(:,9)).^(1/3)))*74;
% crop_equiv_rads = equiv_rads;
% crop_equiv_rads(fit_data(:,7)>9)=[]; % Remove poor (too blurred) fits
% crop_equiv_rads(crop_equiv_rads<380)=[]; % Remove implausibly small fits
% crop_equiv_rads(crop_equiv_rads>700)=[]; % Remove implausibly large fits
% listCroppedEquivRads(lp) = mean(crop_equiv_rads)
	
	drawnow;
	% pause
end

figure(8)
bar(listCroppedEquivRads)
cellNames = cellstr(listFilenames(:,(end):end));
set(gca, 'XTick', 1:length(cellNames), 'XTickLabel', cellNames);
ylim([470 570])
ylabel('equivalent radius / nm')
xlabel('Protein')
set(gca, 'fontSize', 14);


