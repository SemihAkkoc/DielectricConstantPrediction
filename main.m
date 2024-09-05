clear all;

% RUN TO TRAIN THE MODEL

% 'S21_course_grid.mat' is the weekend run S21q params not in dB
%coeff_filename = 'long_weekend_run.mat';
%f_start_end_stepsize = [1e9 3.2e9 1.1e6];
%eps_start_end_stepsize = [1 5 0.1];
%tloss_start_end_stepsize= [0 3e-2 8e-4];
%doPlot = true;
%
%Simulation_Plot(coeff_filename, f_start_end_stepsize, eps_start_end_stepsize, tloss_start_end_stepsize, doPlot);


% RUN TO TEST THE MODEL with Compare_v2

%ref_filename = 's21_reference_mat_thic_1p5mm.s2p';
%comp_filename = {'s21_high_eps_low_tan_loss_mat_thic_1p5mm.s2p' 's21_high_eps_high_tan_loss_mat_thic_1p5mm.s2p'};
%coeff_filename =  'cst_coeff.mat';
%doPlot = false;
%order = 5;
%
%eps = cell(1,length(comp_filename));
%tan_loss = cell(1,length(comp_filename));
%
%for i=1:length(comp_filename)
%	[eps(i) tan_loss(i)] = Compare_v2(comp_filename{i}, ref_filename, coeff_filename, order, doPlot);
%end
%
%for i=1:length(comp_filename)
%	eps(i) = [eps{i} mean(eps{i})];
%	tan_loss(i) = [tan_loss{i} mean(tan_loss{i})];
%end
%disp(eps)
%disp(tan_loss)


% RUN TO TEST THE MODEL with Compare_v3

ref_filename = 'CSTDataThick1p5\s21_reference_mat_thic_1p5mm.s2p';
comp_filename = {'CSTDataThick1p5\s21_high_eps_low_tan_loss_mat_thic_1p5mm.s2p' 'CSTDataThick1p5\s21_high_eps_high_tan_loss_mat_thic_1p5mm.s2p'};
coeff_filename =  'Coefficients\cst_coeff.mat';
doPlot = true;
order = 5;

eps = cell(1,length(comp_filename));
tan_loss = cell(1,length(comp_filename));

for i=1:length(comp_filename)
	[eps(i) tan_loss(i)] = Compare_v3(comp_filename{i}, ref_filename, coeff_filename, order, doPlot);
end

for i=1:length(comp_filename)
	eps(i) = [eps{i} mean(eps{i})];
	tan_loss(i) = [tan_loss{i} mean(tan_loss{i})];
end
disp(eps)
disp(tan_loss)

