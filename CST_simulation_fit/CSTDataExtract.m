function [S21q_ref f_range] = CSTDataExtract(fixed_eps, order_till, doPlot)

	coeff_filename = 'cst_coeff_q.mat';

	fixed_tan_loss = 0; % for eps sweep data

	load('cstdata.mat', 'S21', 'f_range');

	S21q = {};
	tan_loss_sample = [];

	legend_par_q = {};

	countq = 1;
	for i=1:(size(S21))(1)
		for j=1:(size(S21))(2)
			% for tanD sweep
			if S21{i,j}{2}(1) == fixed_eps
				S21q(countq) = S21{i,j}(1);
				tan_loss_sample(countq) = S21{i,j}{2}(2);
				legend_par_q(countq) = strcat("tanD = ", num2str(tan_loss_sample(countq)));
				countq = countq + 1;
			end
		end
	end

	qFactors = zeros(length(S21q), 2);
	for i = 1:length(S21q)
		q_resonance_freqs = PeakFinder(S21q{i}, f_range, 2e8);
		qFactors(i,:) = QFactorFinder_v2(S21q{i}, q_resonance_freqs, f_range);
	end

	qFactor_shift = qFactors(1,:) - qFactors;

	q_fs = cell(order_till,2);
	for i=1:order_till
		for j=1:2
			q_fs(i,j) = polyfit(qFactor_shift(:,j),tan_loss_sample,i);% q factor fit
		end
	end
	save(coeff_filename, 'q_fs');
%	disp('CST data coeffs for tangent loss have been saved.')

	if doPlot
		figure;
		for i = 1:length(S21q)
			plot(f_range/1e9, S21q{i})
			hold on;
		end
		title('S_{21}q dB vs. Frequency')
		xlabel('Frequency (GHz)')
		ylabel('S_{21}q dB')
		legend(legend_par_q)
		grid on;

		figure;
		plot(qFactor_shift(:,1), tan_loss_sample)
		title('tan(\delta) vs Shift in Q Factor')
		xlabel('Q Shift')
		ylabel('tan(\delta)')
		grid on;

		figure;
		plot(qFactor_shift(:,2), tan_loss_sample)
		title('tan(\delta) vs Shift in Q Factor')
		xlabel('Q Shift')
		ylabel('tan(\delta)')
		grid on;
	end

	S21q_ref = S21q{1};
