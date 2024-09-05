function [f_range S21] = ReadTouchstone(filename)
	% f s11 p s12 p s21 p s22
	fileID = fopen(filename);
	format_spec = '%f %f %f %f %f %f %f %f %f';

	fileContent = reshape(fscanf(fileID, format_spec), 9, []).';
	fclose(fileID);

	f_range = fileContent(:,1).';
	S21 = fileContent(:,6).';
