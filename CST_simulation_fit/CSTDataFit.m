warning('off')

coeff_filename = 'cst_coeff.mat';
order_till = 5; % until (order_till)th polynomial fit
doPlot = true;

fixed_tan_loss = 0; % for eps sweep data
fixed_eps = 1; % for tan_loss sweep data

%[S21 f_range] = ReadCSTData('cstsample.txt');
%load('cstdata.mat', 'S21', 'f_range');

S21f = {};
S21q = {};
eps_sample = [];
tan_loss_sample = [];

legend_par_f = {};
legend_par_q = {};

countf = 1;
countq = 1;
for i=1:(size(S21))(1)
	for j=1:(size(S21))(2)
		% for eps sweep
		if S21{i,j}{2}(2) == fixed_tan_loss
			S21f(countf) = S21{i,j}(1);
			eps_sample(countf) = S21{i,j}{2}(1);
			legend_par_f(countf) = strcat("e_r = ", num2str(eps_sample(countf)));
			countf = countf + 1;
		end
		% for tanD sweep
		if S21{i,j}{2}(1) == fixed_eps
			S21q(countq) = S21{i,j}(1);
			tan_loss_sample(countq) = S21{i,j}{2}(2);
			legend_par_q(countq) = strcat("tanD = ", num2str(tan_loss_sample(countq)));
			countq = countq + 1;
		end
	end
end

resonance_freqs = zeros(length(S21f), 2);
for i = 1:length(S21f)
	resonance_freqs(i,:) = PeakFinder(S21f{i}, f_range, 2e8);
end

qFactors = zeros(length(S21q), 2);
for i = 1:length(S21q)
	q_resonance_freqs = PeakFinder(S21q{i}, f_range, 2e8);
	qFactors(i,:) = QFactorFinder_v2(S21q{i}, q_resonance_freqs, f_range);
end

resonance_freq_shift = resonance_freqs(1,:) - resonance_freqs;
qFactor_shift = qFactors(1,:) - qFactors;

q_fs = cell(order_till,2);
f_fs = cell(order_till,2);
for i=1:order_till
	for j=1:2
		f_fs(i,j) = polyfit(resonance_freq_shift(:,j),eps_sample,i);% resonance fit
		q_fs(i,j) = polyfit(qFactor_shift(:,j),tan_loss_sample,i);% q factor fit
	end
end
save(coeff_filename, 'f_fs', 'q_fs');
disp('CST data coeffs has been saved.')

if doPlot
	figure;
	for i = 1:length(S21f)
		plot(f_range/1e9, S21f{i})
		hold on;
	end
	title('S_{21}f dB vs. Frequency')
	xlabel('Frequency (GHz)')
	ylabel('S_{21}f dB')
	legend(legend_par_f)
	grid on;


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
	plot(resonance_freq_shift(:,1)/1e6, eps_sample)
	title('\epsilon_{r} vs Shift in First Resonance')
	xlabel('Frequency (MHz)')
	ylabel('\epsilon_{r}')
	grid on;

	figure;
	plot(resonance_freq_shift(:,2)/1e6, eps_sample)
	title('\epsilon_{r} vs Shift in Second Resonance')
	xlabel('Frequency (MHz)')
	ylabel('\epsilon_{r}')
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
