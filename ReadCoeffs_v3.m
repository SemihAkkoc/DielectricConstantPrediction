function [f_tloss_1 f_tloss_2] = ReadCoeffs_v3(order)
	% only works with .mat files or files that have been saved with save command
	load('cst_coeff_q.mat', 'q_fs');
	f_tloss_1 = @(q) sum(q_fs{order,1}.*(q.^(order:-1:0)));
	f_tloss_2 = @(q) sum(q_fs{order,2}.*(q.^(order:-1:0)));
