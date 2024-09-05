function [eps tan_loss] = Compare_v2(S21c_filename, S21r_filename, coeffs_filename, order, doPlot)

	[f_range_ref S21_ref] = ReadTouchstone(S21r_filename);
	[f_range_comp S21_comp] = ReadTouchstone(S21c_filename);

	[f_eps_1 f_eps_2 f_tloss_1 f_tloss_2] = ReadCoeffs_v2(coeffs_filename, order);

	f_range_ref = f_range_ref*1e9;
	f_range_comp = f_range_comp*1e9;

	if doPlot
		figure;
		plot(f_range_ref/1e9, S21_ref)
		hold on;
		plot(f_range_comp/1e9, S21_comp)
		title('S_{21} dB vs. Frequency')
		xlabel('Frequency (GHz)')
		ylabel('S_{21} dB')
		grid on;
	end

	resonance_freqs = zeros(2,2);
	resonance_freqs(1,:) = PeakFinder(S21_ref, f_range_ref, 2e8);
	resonance_freqs(2,:) = PeakFinder(S21_comp, f_range_comp, 2e8);

	q_factors = zeros(2,2);

	q_factors(1, :) = QFactorFinder_v2(S21_ref, resonance_freqs(1,:), f_range_ref);
	q_factors(2, :) = QFactorFinder_v2(S21_comp, resonance_freqs(2,:), f_range_comp);

	resonance_freq_shift = resonance_freqs(1,:) - resonance_freqs(2,:);
	q_factor_shift = q_factors(1,:) - q_factors(2,:);

	eps = [f_eps_1(resonance_freq_shift(1)) f_eps_2(resonance_freq_shift(2))];
	tan_loss = [f_tloss_1(q_factor_shift(1)) f_tloss_2(q_factor_shift(2))];

