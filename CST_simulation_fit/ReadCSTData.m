function [S21 f_range] = ReadCSTData(filename)
	% first disregard 3 lines then read 1001, repeat until -1
	% enter the range of eps and stepsize, tanD range and stepsize

	% S21{i,j} has two enteries [[ith e_r, jth tanD] ,S21]
	% f_range in GHz

	eps_start = 1;
	eps_end = 5;
	eps_stepsize = 0.1;
	eps_sample = eps_start:eps_stepsize:eps_end;

	tanD_start = 0;
	tanD_end = 0.03;
	tanD_stepsize = 0.001;
	tanD_sample = tanD_start:tanD_stepsize:tanD_end;

	S21 = cell(length(eps_sample), length(tanD_sample), 2);
	S21_sub = [];
	f_range = [];

	count_eps = 1;
	count_tanD = 1;
	count_f = 1;
	count_non = 0;

	fileID = fopen(filename);

	line = fgetl(fileID);
	while line ~= -1
		if line(1) == '#'
			count_non = count_non + 1;
			if count_f ~= 1
				disp(sprintf('%d %d \n', count_eps, count_tanD));
				S21{count_eps, count_tanD} = {S21_sub, [eps_sample(count_eps) tanD_sample(count_tanD)]};
				% S21{i,j}(1) = S21
				% S21{i,j}(2) = [ith e_r, jth tanD]
				count_eps = count_eps + 1;
				count_f = 1;
				if count_eps == length(eps_sample) + 1
					count_tanD = count_tanD + 1;
					count_eps = 1;
				end
			end
		elseif (count_non == 3 || count_non == 0)
			count_non = 0;
			sp = strsplit(line);
			f_range(count_f) = str2double(sp(1));
			S21_sub(count_f) = str2double(sp(2));
			count_f = count_f + 1;
		end
		line = fgetl(fileID);
	end
	f_range = f_range*1e9; % conversion to GHz (BE CAREFUL WITH THE TXT file has inside)
	fclose(fileID);
	save('cstdata.mat', 'S21', 'f_range');
	disp('cstdata.mat has been saved.')
