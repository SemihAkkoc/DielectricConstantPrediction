function [eps tan_loss] = Compare_v3(S21c_filename, S21r_filename, coeffs_filename, order, doPlot)
	[f_range_ref S21_ref] = ReadTouchstone(S21r_filename);
	[f_range_comp S21_comp] = ReadTouchstone(S21c_filename);

	[f_eps_1 f_eps_2 f_tloss_1 f_tloss_2] = ReadCoeffs_v2(coeffs_filename, order);

	f_range_ref = f_range_ref*1e9;
	f_range_comp = f_range_comp*1e9;

	if doPlot
		fntSize = 20;
		lineWid = 3;
		figure;
		plot(f_range_ref/1e9, S21_ref, 'LineWidth', lineWid)
		hold on;
		plot(f_range_comp/1e9, S21_comp, 'LineWidth', lineWid)
		title('S_{21} dB vs. Frequency', 'FontSize', fntSize)
		xlabel('Frequency (GHz)', 'FontSize', fntSize)
		ylabel('S_{21} dB', 'FontSize', fntSize)
		legend({'Reference S21', 'Compared S21'}, 'FontSize', fntSize)
		grid on;
	end

	resonance_freqs = zeros(3,2);
	resonance_freqs(1,:) = PeakFinder(S21_ref, f_range_ref, 2e8);
	resonance_freqs(2,:) = PeakFinder(S21_comp, f_range_comp, 2e8);

	resonance_freq_shift = resonance_freqs(1,:) - resonance_freqs(2,:);
	eps = [f_eps_1(resonance_freq_shift(1)) f_eps_2(resonance_freq_shift(2))];

	fixed_eps = round(mean(eps)*10)/10;

	[S21_ref_q f_range_ref_q] = CST_simulation_fit.CSTDataExtract(fixed_eps, order, false);

	[f_tloss_1 f_tloss_2] = ReadCoeffs_v3(order);

	resonance_freqs(3,:) = PeakFinder(S21_ref_q, f_range_ref_q, 2e8);

	q_factors = zeros(2,2);

	q_factors(1, :) = QFactorFinder_v2(S21_ref_q, resonance_freqs(3,:), f_range_ref_q);
	q_factors(2, :) = QFactorFinder_v2(S21_comp, resonance_freqs(2,:), f_range_comp);

	q_factor_shift = q_factors(1,:) - q_factors(2,:);

	tan_loss = [f_tloss_1(q_factor_shift(1)) f_tloss_2(q_factor_shift(2))];
