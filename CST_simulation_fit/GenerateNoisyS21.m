function [f_range noisy_S21] = GenerateNoisyS21(filename, sigma)

	[f_range S21] = ReadTouchstone(filename);

%	noisy_S21 = zeros(1, length(f_range));
%	for i=1:length(S21)
%		noisy_S21(i) = 20*log10(sigma*randn + power(10, S21(i)/20));
%	end

	noisy_S21 = 20*log10(sigma*randn(1,length(S21))+power(10, S21./20));

	w = zeros(length(f_range),9);
	for i = 1:length(f_range)
		for j = 1:9
			w(i,j) = noisy_S21(i);
			if j==1
				w(i,j) = f_range(i);
			end
		end
	end
	noisy_filename = strcat(filename(1:end-4), '_noisy.s2p');
	fileID = fopen(noisy_filename, 'w');
	for i = 1:length(f_range)
		fprintf(fileID, '%f %f %f %f %f %f %f %f %f\n', w(i,:));
	end
	fclose(fileID);

