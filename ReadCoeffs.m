function [f_eps_1 f_eps_2 f_tloss_1 f_tloss_2] = ReadCoeffs(filename)
	% only works with .mat files or files that have been saved with save command
	load(filename, 'first_resonance_coeff', 'second_resonance_coeff', 'first_resonance_coeff_qFactor', 'second_resonance_coeff_qFactor');

	f_eps_1 = @(f) sum(first_resonance_coeff.*[f^3 f^2 f 1]);
	f_eps_2 = @(f) sum(second_resonance_coeff.*[f^3 f^2 f 1]);
	f_tloss_1 = @(q) sum(first_resonance_coeff_qFactor.*[q^3 q^2 q 1]);
	f_tloss_2 = @(q) sum(second_resonance_coeff_qFactor.*[q^3 q^2 q 1]);

