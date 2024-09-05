function [f_eps_1 f_eps_2 f_tloss_1 f_tloss_2] = ReadCoeffs_v2(filename, order)
	% only works with .mat files or files that have been saved with save command
	load(filename, 'f_fs', 'q_fs');

	f_eps_1 = @(f) sum(f_fs{order,1}.*(f.^(order:-1:0)));
	f_eps_2 = @(f) sum(f_fs{order,2}.*(f.^(order:-1:0)));
	f_tloss_1 = @(q) sum(q_fs{order,1}.*(q.^(order:-1:0)));
	f_tloss_2 = @(q) sum(q_fs{order,2}.*(q.^(order:-1:0)));


