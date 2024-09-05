function [fr_1 fr_2 Q_fr_1 Q_fr_2] = Simulation_Plot(coeff_filename, f_start_end_stepsize, eps_start_end_stepsize, tloss_start_end_stepsize, doPlot)
	f_start = f_start_end_stepsize(1); %1e9; % 1GHz
	f_end = f_start_end_stepsize(2); %3.2e9; % 3.2GHz
	f_step_size = f_start_end_stepsize(3); %2.2e6; % frequency step size 0.5MHz

	f_range = f_start:f_step_size:f_end;

	% eps_sample sweep
	eps_sample_start = eps_start_end_stepsize(1); %1;
	eps_sample_end = eps_start_end_stepsize(2); %2;
	eps_sample_step_size = eps_start_end_stepsize(3); %0.01;

	eps_sample = eps_sample_start:eps_sample_step_size:eps_sample_end;

	%eps_sample = 1.02;


	% tan_loss_sample sweep
	tan_loss_sample_start = tloss_start_end_stepsize(1);%0;
	tan_loss_sample_end = tloss_start_end_stepsize(2);%3e-2;
	tan_loss_sample_step_size = tloss_start_end_stepsize(3);%3e-4;

	tan_loss_sample = tan_loss_sample_start:tan_loss_sample_step_size:tan_loss_sample_end;

	%tan_loss_sample = 0;

	% grid work
%	S21q = cell(length(eps_sample), length(tan_loss_sample));
%	legend_par_q = {};
%	for j = 1:length(eps_sample)
%		tStart = tic;
%		for i = 1:length(tan_loss_sample)
%			legend_par_q(i) = strcat("tan(\delta) = ", num2str(tan_loss_sample(i)));
%			printf('eps_r = %.2f tan(d) = %.4f\n',eps_sample(j), tan_loss_sample(i));
%			S21q{j,i} = SuspendedRingResonator(f_range, eps_sample(j), tan_loss_sample(i));  % eps_r 1.02 val can be changed
%		end
%		tElapsed = toc(tStart);
%		printf('Elapsed Time to Create S21q for eps_r = %.2f: %.2f\n\n', eps_sample(j), tElapsed);
%	end

	% save the S21 parameters
%	save('S21_course_grid.mat', 'S21q');
%	disp('S21 params saved.');

%	eps_sample = 1; % OVERRIDE DUE TO GRID RUN

	% for frequency shift
	S21f = cell(1, length(eps_sample));
	legend_par_f = {};
	tStart = tic;
	for i = 1:length(eps_sample)
		legend_par_f(i) = strcat("eps_r = ", num2str(eps_sample(i)));
		printf('eps_r = %.2f\n', eps_sample(i));
		S21f{i} = SuspendedRingResonator(f_range, eps_sample(i), 0);
	end
	tElapsed = toc(tStart);
	printf('Elapsed Time to Create S21f: %.2f\n\n', tElapsed);

	% for q factor shift
	S21q = cell(1, length(tan_loss_sample));
	legend_par_q = {};
	tStart = tic;
	for i = 1:length(tan_loss_sample)
		legend_par_q(i) = strcat("tan(\delta) = ", num2str(tan_loss_sample(i)));
		printf('tan(delta) = %.4f\n', tan_loss_sample(i));
		S21q{i} = SuspendedRingResonator(f_range, 1, tan_loss_sample(i));  % eps_r 1.0 val can be changed
	end
	tElapsed = toc(tStart);
	printf('Elapsed Time to Create S21q: %.2f\n\n', tElapsed);


	% find resonance frequencies
	resonance_freqs = zeros(length(eps_sample), 2);

	for i = 1:length(eps_sample)
		resonance_freqs(i,:) = PeakFinder(S21f{i}, f_range, 2e8);
	end

	% find Q factor
	qFactors = zeros(length(tan_loss_sample), 2);

	for i = 1:length(tan_loss_sample)
		q_resonance_freqs = PeakFinder(S21q{i}, f_range, 2e8);
		qFactors(i,:) = QFactorFinder_v2(20*log10(abs(S21q{i})), q_resonance_freqs, f_range);
	end

	if doPlot
		% in dB scale S21f
		figure;
		for i = 1:length(eps_sample)
			plot(f_range/1e9, 20*log10(abs(S21f{i})))
			hold on;
		end
		title('S_{21}f dB vs. Frequency')
		xlabel('Frequency (GHz)')
		ylabel('S_{21}f dB')
		xlim([f_start/1e9, f_end/1e9])
		xticks(f_start/1e9:(f_end/1e9-f_start/1e9)/8:f_end/1e9)
		legend(legend_par_f)
		grid on;

		% in dB scale S21q
		figure;
		for i = 1:length(tan_loss_sample)
			plot(f_range/1e9, 20*log10(abs(S21q{i})))
			hold on;
		end
		title('S_{21}q dB vs. Frequency')
		xlabel('Frequency (GHz)')
		ylabel('S_{21}q dB')
		xlim([f_start/1e9, f_end/1e9])
		xticks(f_start/1e9:(f_end/1e9-f_start/1e9)/8:f_end/1e9)
		legend(legend_par_q)
		grid on;
	end

	% freq shift
	resonance_freq_shift = resonance_freqs(1,:) - resonance_freqs;

	if doPlot
		% freq shift first resonance
		figure;
		plot(resonance_freq_shift(:,1)/1e6, eps_sample)
		title('\epsilon_{r} vs Shift in First Resonance')
		xlabel('Frequency (MHz)')
		ylabel('\epsilon_{r}')
		%xlim([f_start/1e9, f_end/1e9])
		%xticks(f_start/1e9:(f_end/1e9-f_start/1e9)/8:f_end/1e9)
		grid on;

		% freq shift second resonance
		figure;
		plot(resonance_freq_shift(:,2)/1e6, eps_sample)
		title('\epsilon_{r} vs Shift in Second Resonance')
		xlabel('Frequency (MHz)')
		ylabel('\epsilon_{r}')
		%xlim([f_start/1e9, f_end/1e9])
		%xticks(f_start/1e9:(f_end/1e9-f_start/1e9)/8:f_end/1e9)
		grid on;
	end

	% Q factor shift
	qFactor_shift = qFactors(1,:) - qFactors;

	if doPlot
		% Q factor shift first resonance
		figure;
		plot(qFactor_shift(:,1), tan_loss_sample)
		title('tan(\delta) vs Shift in Q Factor')
		xlabel('Q Shift')
		ylabel('tan(\delta)')
		grid on;

		% Q factor shift second resonance
		figure;
		plot(qFactor_shift(:,2), tan_loss_sample)
		title('tan(\delta) vs Shift in Q Factor')
		xlabel('Q Shift')
		ylabel('tan(\delta)')
		grid on;
	end


%	% polynomial fit needs to be checked
%	first_resonance_coeff = polyfit(resonance_freq_shift(:,1),eps_sample,3);% first resonance fit
%	second_resonance_coeff = polyfit(resonance_freq_shift(:,2),eps_sample,3); % second resonance fit
%
%	fr_1 = @(f) sum(first_resonance_coeff.*[f^3 f^2 f 1]);
%	fr_2 = @(f) sum(second_resonance_coeff.*[f^3 f^2 f 1]);
%
%
%	% polynomial fit needs to be checked
%	first_resonance_coeff_qFactor = polyfit(qFactor_shift(:,1),tan_loss_sample,3);% first resonance fit
%	second_resonance_coeff_qFactor = polyfit(qFactor_shift(:,2),tan_loss_sample,3); % second resonance fit
%
%	Q_fr_1 = @(qF) sum(first_resonance_coeff_qFactor.*[qF^3 qF^2 qF 1]);
%	Q_fr_2 = @(qF) sum(second_resonance_coeff_qFactor.*[qF^3 qF^2 qF 1]);


%	save(coeff_filename, 'first_resonance_coeff', 'second_resonance_coeff', 'first_resonance_coeff_qFactor', 'second_resonance_coeff_qFactor');
%	disp('Data has been saved.')

	order = 7;
	long = true; % may add as a function input
	if long
		q_fs = cell(order,2);
		f_fs = cell(order,2);
		for i=1:order
			for j=1:2
				f_fs(i,j) = polyfit(resonance_freq_shift(:,j),eps_sample,i);% resonance fit
				q_fs(i,j) = polyfit(qFactor_shift(:,j),tan_loss_sample,i);% q factor fit
			end
		end
		save('long_run.mat', 'f_fs', 'q_fs');
		disp('Long data coeffs has been saved.')
	end


%	fileID = fopen(coeff_filename,'w');
%	for i=1:4
%		fprintf(fileID, '%f ', first_resonance_coeff_qFactor(i));
%	end
%	fprintf(fileID, '\n');
%	for i=1:4
%		fprintf(fileID, '%f ', second_resonance_coeff_qFactor(i));
%	end
%	fprintf(fileID, '\n');
%	for i=1:4
%		fprintf(fileID, '%f ', first_resonance_coeff(i));
%	end
%	fprintf(fileID, '\n');
%	for i=1:4
%		fprintf(fileID, '%f ', second_resonance_coeff(i));
%	end
%	fclose(fileID);

	%% DO CHANGE THIS PART WITH TOL
	%[uQFactor_shift_fr ind_fr _] = unique(qFactor_shift(:,1));
	%[uQFactor_shift_sr ind_sr _] = unique(qFactor_shift(:,2));
	%
	%figure;
	%plot(uQFactor_shift_fr, tan_loss_sample(ind_fr))
	%title('tan(\delta) vs Shift in First Resonance')
	%xlabel('Q Shift')
	%ylabel('tan(\delta)')
	%grid on;
	%
	%% Q factor shift second resonance
	%figure;
	%plot(uQFactor_shift_sr, tan_loss_sample(ind_sr))
	%title('tan(\delta) vs Shift in Second Resonance')
	%xlabel('Q Shift')
	%ylabel('tan(\delta)')
	%grid on;
	%
	%% polynomial fit needs to be checked
	%first_resonance_coeff_qFactor = polyfit(uQFactor_shift_fr,tan_loss_sample(ind_fr),3);% first resonance fit
	%second_resonance_coeff_qFactor = polyfit(uQFactor_shift_sr,tan_loss_sample(ind_sr),3); % second resonance fit
	%
	%Q_fr_1 = @(qF) sum(first_resonance_coeff_qFactor.*[qF^3 qF^2 qF 1]);
	%Q_fr_2 = @(qF) sum(second_resonance_coeff_qFactor.*[qF^3 qF^2 qF 1]);


