% make2ColorRecon
% EJR, Jan 2019
% cc-by 4.0
% 
% Purpose of this script
%
% This script takes processed ELM data for one TIF of microscopy data, and
% combines this ELM data with raw image data from a second, user-defined
% color (colour) channel to produce reconsructions which allow the position 
% of features in the two channels to be compared.
% It is expected that the first colour channel contains ellipsoid images
% that can be super-resolved, and the second channel contains general
% features such as germinosomes (that are not improved by ELM).
%
% Notes: 
% 1. In ELM parameters, should save box size for future reference
% 2. I'm assuming we've fitted the biased ellipsoid model, so use the table
% of fitted parameters from that analysis.
% 3. To do: add quality control.


% 1. INPUT

% 1.1 Get pixel width and quality control criteria for the ELM data
prompt = {'Pixel width in nm (e.g. 117)', ...
	        'Blur radius limit (as variance, e.g. 10 or 9.9)', ...
	        'Minimum radius in nm (e.g. 300)', ...
					'Maximum radius in nm (e.g. 700)',...
					'Reconstruction scale factor (integers preferred)',...
					'Reconstruction blur radius (camera pixels)',...
					'fluorophores (e.g. 3000' ,...
					'seed (arbitrary number, e.g. 1066)',...
					'Pause after each frame ( 0 = no, 1 = yes)',...
					'Write output to csv spreadsheet (0 = no, 1 = yes)',...
				  'Save tiled figures (0 = no, 1 = yes)' };
dlg_title = 'Analysis settings';
num_lines = 1;
defaultans = {'117','9.9','300', '700','1.0','1', '3000','1066', '0','0','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

pixel_width_nm = str2num(answer{1});
threshold_blur = str2num(answer{2});
min_radius     = str2num(answer{3});
max_radius     = str2num(answer{4});
reconstr_SF    = str2num(answer{5});
recon_blur_rad = str2num(answer{6});
fluorophores   = str2num(answer{7});
seed           = str2num(answer{8});
pause_framewise= str2num(answer{9});
flag_write_csvs= str2num(answer{10});
flag_save_tiles= str2num(answer{11});

% Get user-specified file inputs
%   Get file containing MAT files of ELM results to process
[FileName_ELM_params,PathName_ELM_params,FilterIndex_ELM_param] = uigetfile('*.mat','Select MAT file of ELM results');
%   Get file containing the second colour channel
[FileName_image_channel2,PathName_image_channel2,FilterIndex_image_channel2] = uigetfile('*.tif','Select MAT file of ELM results');

% Load data:
load([PathName_ELM_params,'\', FileName_ELM_params]);
im_data_channel_2 = imread([PathName_image_channel2,'\', FileName_image_channel2]);

% For development: a folder of data:
% D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2018_Spore_Protein_Maps\cereus\data\20190115_Bcereus10876_Ger-tdTomato_SleL-GFP\2018_11_30_Pedro_Amin_BacillusCereus10876\output_ELM_20190108

% Get size of image data segemnts:
im_candidate_1 = shell_segments{1};
radius_segment = (size(im_candidate_1,1) -1) /2;  % NB it's square.
% figure(1)
% imagesc(im_candidate_1)

% Make an empty cell array to store the channel-2 segments and other output
im_channel_2_segments        = cell(size(shell_segments));
sr_segments                  = cell(length(shell_segments));
sr_segments_scaled           = cell(length(shell_segments));
im_channel_2_segments_scaled = cell(size(shell_segments));



% 2. ANALYSIS
% For each candidate, get the channel-2 image data, 
% And make the ELM reconstuction
for lp = 1:size(fitData,1)

	x_centre_segment = floor(fitData(lp, 1));
	y_centre_segment = floor(fitData(lp, 2));

	rows = (y_centre_segment - radius_segment):(y_centre_segment + radius_segment);
	cols = (x_centre_segment - radius_segment):(x_centre_segment + radius_segment);
	
	chan_2_image = im_data_channel_2(rows,cols);
	im_channel_2_segments{lp} = chan_2_image; % Store channel 2 segment
	% figure(3)
	% imagesc(chan_2_image)
	chan_2_image_scaled = imresize(chan_2_image, reconstr_SF);
	im_channel_2_segments_scaled{lp} = chan_2_image_scaled;
	% imagesc(chan_2_image_scaled)

	% Super-resolution reconstruction with 1:1 scale
	fit = fitData(lp,:);
	sr_image = fsa.image_ellipsoid_biased(fit(3), fit(4), fit(5), fit(6), recon_blur_rad, fit(8), fit(9), fit(10), shell_segments{lp}, fluorophores, seed);
	sr_segments{lp} = sr_image;
	% figure(4)
	% imagesc(sr_image)
	RSF = reconstr_SF;
	% Reference:    % function I = image_ellipsoid_biased(x_shift, y_shift, orientation, semiminor_axis, psf_variance, height, eccentricity, equatoriality, imagemat, fluorophores, seed)
	sr_image_scaled = fsa.image_ellipsoid_biased(fit(3)*RSF, fit(4)*RSF, fit(5), fit(6)*RSF, recon_blur_rad*RSF, fit(8), fit(9), fit(10), zeros( size(shell_segments{lp})*RSF ), fluorophores, seed);
	sr_segments_scaled{lp} = sr_image_scaled;
	% figure(5)
	% imagesc(sr_image_scaled)
	
end

% TEST RECONSTRUCTION: 
% recon(:,:,1) = double( im_channel_2_segments_scaled{7} );
% recon(:,:,1) = 0.5*recon(:,:,1)./(max(max( recon(:,:,1))) );
% recon(:,:,2) = double( sr_segments_scaled{7} );
% recon(:,:,2) = recon(:,:,2)./(max(max( recon(:,:,2))));
% recon(:,:,3) = zeros(size(recon(:,:,1)));
% % figure(7)
% % imagesc(recon)

im_channel_2_segments        = cell(size(shell_segments));
sr_segments                  = cell(length(shell_segments));
sr_segments_scaled           = cell(length(shell_segments));
im_channel_2_segments_scaled = cell(size(shell_segments));

% Tiled visualisation
sr_tiles               = fsa.tile_segments(sr_segments);
sr_tiles_scaled        = fsa.tile_segments(sr_segments_scaled);
im_tiles_chan2         = fsa.tile_segments(im_channel_2_segments);
im_tiles_chan2_scaled  = fsa.tile_segments(im_channel_2_segments_scaled);

sr_tiles              = sr_tiles./max(sr_tiles(:));
sr_tiles_scaled       = sr_tiles_scaled./max(sr_tiles_scaled(:));
im_tiles_chan2        = im_tiles_chan2./max(im_tiles_chan2(:));
im_tiles_chan2_scaled = im_tiles_chan2_scaled./max(im_tiles_chan2_scaled(:));


if(flag_save_tiles)
	saveFolder = uigetdir;
	imwrite(sr_tiles_scaled,       [saveFolder,filesep,'ELM_tiles_scaled.png']);
	imwrite(im_tiles_chan2_scaled, [saveFolder,filesep,'Channel_2_tiles_scaled.png']);
end
