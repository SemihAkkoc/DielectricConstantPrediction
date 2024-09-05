warning('off')
%load('S21_course_grid.mat', 'S21q');
%S21 = S21q;

% Set global font size and line width
fntSize = 20;
lineWid = 3;

eps_sample = 1:0.1:5;
tan_loss_sample = 0:8e-4:3e-2;
f_range = 1e9:1.1e6:3.2e9;
S21f = cell(1,length(eps_sample));
S21q = cell(1,length(tan_loss_sample));
order_till = 5;
doSave = true;
doPlot = true;

legend_par_f = {};
for i=1:41
	S21f{i} = S21{i,1};
	legend_par_f(i) = strcat("e_r = ", num2str(eps_sample(i)));
end


legend_par_q = {};
for i=1:38
	S21q{i} = S21{1,i};
	legend_par_q(i) = strcat("tanD = ", num2str(tan_loss_sample(i)));
end



resonance_freqs = zeros(length(eps_sample), 2);
for i = 1:length(eps_sample)
	resonance_freqs(i,:) = PeakFinder_v2(S21f{i}, f_range, 2e8);
end
qFactors = zeros(length(tan_loss_sample), 2);
for i = 1:length(tan_loss_sample)
	q_resonance_freqs = PeakFinder_v2(S21q{i}, f_range, 2e8);
	qFactors(i,:) = QFactorFinder_v3(20*log10(abs(S21q{i})), q_resonance_freqs, f_range);
end

resonance_freq_shift = resonance_freqs(1,:) - resonance_freqs;
qFactor_shift = qFactors(1,:) - qFactors;

if doPlot
	figure('position', [0,-30,1920,1080]);
	for i = 1:length(eps_sample)
		plot(f_range/1e9, 20*log10(abs(S21f{i})), 'LineWidth', lineWid)
		hold on;
	end
	title('S_{21}f dB vs. Frequency', 'FontSize', fntSize)
	xlabel('Frequency (GHz)', 'FontSize', fntSize)
	ylabel('S_{21}f dB', 'FontSize', fntSize)
	legend(legend_par_f, 'FontSize', fntSize, 'Location', 'Best')
	grid on;
	set(gca, 'FontSize', fntSize);
	saveas(gcf, 'eps_sweep.png')


	figure('position', [0,-30,1920,1080]);
	for i = 1:length(tan_loss_sample)
		plot(f_range/1e9, 20*log10(abs(S21q{i})), 'LineWidth', lineWid)
		hold on;
	end
	title('S_{21}q dB vs. Frequency', 'FontSize', fntSize)
	xlabel('Frequency (GHz)', 'FontSize', fntSize)
	ylabel('S_{21}q dB', 'FontSize', fntSize)
	legend(legend_par_q, 'FontSize', fntSize, 'Location', 'Best')
	grid on;
	set(gca, 'FontSize', fntSize);
	saveas(gcf, 'tan_sweep.png')

	figure('position', [0,-30,1920,1080]);
	plot(resonance_freq_shift(:,1)/1e6, eps_sample, 'LineWidth', lineWid)
	title('\epsilon_{r} vs Shift in First Resonance', 'FontSize', fntSize)
	xlabel('Frequency (MHz)', 'FontSize', fntSize)
	ylabel('\epsilon_{r}', 'FontSize', fntSize)
	grid on;
	set(gca, 'FontSize', fntSize)
	saveas(gcf, 'f_shift1.png')


	figure('position', [0,-30,1920,1080]);
	plot(resonance_freq_shift(:,2)/1e6, eps_sample, 'LineWidth', lineWid)
	title('\epsilon_{r} vs Shift in Second Resonance', 'FontSize', fntSize)
	xlabel('Frequency (MHz)', 'FontSize', fntSize)
	ylabel('\epsilon_{r}', 'FontSize', fntSize)
	grid on;
	set(gca, 'FontSize', fntSize);
	saveas(gcf, 'f_shift2.png')

	figure('position', [0,-30,1920,1080]);
	plot(qFactor_shift(:,1), tan_loss_sample, 'LineWidth', lineWid)
	title('tan(\delta) vs Shift in Q Factor', 'FontSize', fntSize)
	xlabel('Q Shift', 'FontSize', fntSize)
	ylabel('tan(\delta)', 'FontSize', fntSize)
	grid on;
	set(gca, 'FontSize', fntSize);
	saveas(gcf, 'q_shift1.png')

	figure('position', [0,-30,1920,1080]);
	plot(qFactor_shift(:,2), tan_loss_sample, 'LineWidth', lineWid)
	title('tan(\delta) vs Shift in Q Factor', 'FontSize', fntSize)
	xlabel('Q Shift', 'FontSize', fntSize)
	ylabel('tan(\delta)', 'FontSize', fntSize)
	grid on;
	set(gca, 'FontSize', fntSize);
	saveas(gcf, 'q_shift2.png')

end

if doSave
	q_fs = cell(order_till,2);
	f_fs = cell(order_till,2);
	for i=1:order_till
		for j=1:2
			f_fs(i,j) = polyfit(resonance_freq_shift(:,j),eps_sample,i);% resonance fit
			q_fs(i,j) = polyfit(qFactor_shift(:,j),tan_loss_sample,i);% q factor fit
		end
	end
	save('from_long_run.mat', 'f_fs', 'q_fs');
	disp('Long data coeffs has been saved.')
	if doPlot
		resolution = 100;

		figure('position', [0,-30,1920,1080]);
		plot(resonance_freq_shift(:,1)/1e6, eps_sample, 'x', 'LineWidth', lineWid);
		hold on;
		legend_par = {'Original Line'};
		r_max = max(resonance_freq_shift(:,1));
		r_min = min(resonance_freq_shift(:,1));
		r_range = r_min:(r_max-r_min)/resolution:r_max;
		for i = 1:order_till
			func = @(f) sum(f_fs{i,1}.*(f.^(i:-1:0)));
			r_range_func = zeros(1, length(r_range));
			for j = 1:length(r_range)
				r_range_func(j) = func(r_range(j));
			end
			plot(r_range/1e6, r_range_func, 'LineWidth', lineWid);
			legend_par(i+1) = strcat("n = ", num2str(i));
			hold on;
		end
		legend(legend_par, 'FontSize', fntSize, 'Location', 'Best')
		title('\epsilon_{r} vs Shift in First Resonance Fit', 'FontSize', fntSize)
		xlabel('Frequency (MHz)', 'FontSize', fntSize)
		ylabel('\epsilon_{r}', 'FontSize', fntSize)
		grid on;
		set(gca, 'FontSize', fntSize);
		saveas(gcf, 'fit1.png')


		figure('position', [0,-30,1920,1080]);
		plot(resonance_freq_shift(:,2)/1e6, eps_sample, 'x', 'LineWidth', lineWid);
		hold on;
		legend_par = {'Original Line'};
		r_max = max(resonance_freq_shift(:,2));
		r_min = min(resonance_freq_shift(:,2));
		r_range = r_min:(r_max-r_min)/resolution:r_max;
		for i = 1:order_till
			func = @(f) sum(f_fs{i,2}.*(f.^(i:-1:0)));
			r_range_func = zeros(1, length(r_range));
			for j = 1:length(r_range)
				r_range_func(j) = func(r_range(j));
			end
			plot(r_range/1e6, r_range_func, 'LineWidth', lineWid);
			legend_par(i+1) = strcat("n = ", num2str(i));
			hold on;
		end
		legend(legend_par, 'FontSize', fntSize, 'Location', 'Best')
		title('\epsilon_{r} vs Shift in Second Resonance Fit', 'FontSize', fntSize)
		xlabel('Frequency (MHz)', 'FontSize', fntSize)
		ylabel('\epsilon_{r}', 'FontSize', fntSize)
		grid on;
		set(gca, 'FontSize', fntSize);
		saveas(gcf, 'fit2.png')


		figure('position', [0,-30,1920,1080]);
		plot(qFactor_shift(:,1), tan_loss_sample,'x', 'LineWidth', lineWid);
		hold on;
		legend_par = {'Original Line'};
		r_max = max(qFactor_shift(:,1));
		r_min = min(qFactor_shift(:,1));
		r_range = r_min:(r_max-r_min)/resolution:r_max;
		for i = 1:order_till
			func = @(f) sum(q_fs{i,1}.*(f.^(i:-1:0)));
			r_range_func = zeros(1, length(r_range));
			for j = 1:length(r_range)
				r_range_func(j) = func(r_range(j));
			end
			plot(r_range, r_range_func, 'LineWidth', lineWid);
			legend_par(i+1) = strcat("n = ", num2str(i));
			hold on;
		end
		legend(legend_par, 'FontSize', fntSize, 'Location', 'Best')
		title('tan(\delta) vs Shift in Q Factor Fit', 'FontSize', fntSize)
		xlabel('Q Shift', 'FontSize', fntSize)
		ylabel('tan(\delta)', 'FontSize', fntSize)
		grid on;
		set(gca, 'FontSize', fntSize);
		saveas(gcf, 'fit3.png')


		figure('position', [0,-30,1920,1080]);
		plot(qFactor_shift(:,2), tan_loss_sample,'x', 'LineWidth', lineWid);
		hold on;
		legend_par = {'Original Line'};
		r_max = max(qFactor_shift(:,2));
		r_min = min(qFactor_shift(:,2));
		r_range = r_min:(r_max-r_min)/resolution:r_max;
		for i = 1:order_till
			func = @(f) sum(q_fs{i,2}.*(f.^(i:-1:0)));
			r_range_func = zeros(1, length(r_range));
			for j = 1:length(r_range)
				r_range_func(j) = func(r_range(j));
			end
			plot(r_range, r_range_func, 'LineWidth', lineWid);
			legend_par(i+1) = strcat("n = ", num2str(i));
			hold on;
		end
		legend(legend_par, 'FontSize', fntSize, 'Location', 'Best')
		title('tan(\delta) vs Shift in Q Factor Fit', 'FontSize', fntSize)
		xlabel('Q Shift', 'FontSize', fntSize)
		ylabel('tan(\delta)', 'FontSize', fntSize)
		grid on;
		set(gca, 'FontSize', fntSize);
		saveas(gcf, 'fit4.png')

	end
end
close all;
