function [QFactor] = QFactorFinder_v2(S21, center_freqs, f_range)

	% assumption: there are only two peaks
	try
		center_freq_inds = zeros(1, length(center_freqs));
		S21_3dBs = zeros(1, length(center_freqs));
		for i=1:length(center_freqs)
			center_freq_inds(i) = find(f_range == center_freqs(i));
			S21_3dBs(i) = S21(center_freq_inds(i))-3.0103;
		end

		S21_3dB_freq = zeros(2, 2);

		S21_3dB_freq(1, 1) = interp1(S21(1:center_freq_inds(1)), f_range(1:center_freq_inds(1)), S21_3dBs(1));
		S21_3dB_freq(1, 2) = interp1(S21(center_freq_inds(1):floor(mean(center_freq_inds))), f_range(center_freq_inds(1):floor(mean(center_freq_inds))), S21_3dBs(1));
		S21_3dB_freq(2, 1) = interp1(S21(floor(mean(center_freq_inds)):center_freq_inds(2)), f_range(floor(mean(center_freq_inds)):center_freq_inds(2)), S21_3dBs(2));
		S21_3dB_freq(2, 2) = interp1(S21(center_freq_inds(2):end), f_range(center_freq_inds(2):end), S21_3dBs(2));

		QFactor = [center_freqs(1)/(S21_3dB_freq(1,2)-S21_3dB_freq(1,1)) center_freqs(2)/(S21_3dB_freq(2,2)-S21_3dB_freq(2,1))];

%		figure;
%		plot(f_range, S21)
%		hold on;
%		plot([S21_3dB_freq(1, 1) S21_3dB_freq(1, 2) S21_3dB_freq(2, 1) S21_3dB_freq(2, 2)], [S21_3dBs(1) S21_3dBs(1) S21_3dBs(2) S21_3dBs(2)], 'x')
%		grid on;
	catch
		disp(lasterror.message);
		error('There must be only two resonance frequencies. Please finish the generalized version of the code to run for multiple peaks.');
	end

%	WORK IN PROGRESS
%	finds Q factor for any number of peaks

%	center_freqs = [f_range(1) center_freqs f_range(end)];
%	center_freq_inds = zeros(1, length(center_freqs));
%	S21_3dBs = zeros(1, length(center_freqs));
%	for i=1:length(center_freqs)
%		center_freq_inds(i) = find(f_range == center_freqs);
%		S21_3dBs(i) = S21(center_freq_inds(i))-3.0103;
%	end
%
%	S21_3dB_freq = zeros(length(center_freqs(2:end-1)), 2)
%	for i=1:length(center_freqs(2:end-1))*2
%		S21_3dB_freq(i, 1) = interp1(f_range(center_freq_inds(i)), S21(:), S21_3dBs(i));
%		S21_3dB_freq(i, 2) = interp1(f_range(), S21(:), S21_3dBs(i));
%	end

