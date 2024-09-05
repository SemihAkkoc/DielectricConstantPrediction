% TODO : CHANGE THIS TO dB scale 3dB search
% Done

function [QFactor] = QFactorFinder(S21, center_freq, f_range, tol)

	state = [-1 1];

	center_freq_ind = find(f_range == center_freq);
	S21_3dB = S21(center_freq_ind)-3.0103;

%%	not fully thought out better handling can be done
%	if length(center_freq_ind) ~= 1
%		ind = center_freq_ind(1);
%	end

	not_found = [true true];
	ind = [center_freq_ind center_freq_ind];
	not_exact = [false false];

%	find lower then upper 3dB freq

	for i = 1:2
		while not_found(i)
			ind(i) = ind(i) + state(i);
			% if 3dB freq exist
			try
				if S21(ind(i)) == S21_3dB
					not_found(i) = false;
				end
			% do tolerance search since 3dB freq does not exist
			catch
				not_exact(i) = true;
				break;
			end
		end
	end

	for i = 1:2
		if not_found(i)
			ind(i) = center_freq_ind;
		end
	end

	for i = 1:2
		while not_exact(i) && not_found(i)
			ind(i) = ind(i) + state(i);
			try
%				disp(printf(' lb: %f \n val: %f \n ub: %f \n', S21_3dB-tol, S21(ind(i)), S21_3dB+tol));
				if  S21_3dB - tol < S21(ind(i)) &&  S21(ind(i)) < S21_3dB + tol
					not_found(i) = false;
				end
			% do tolerance search since 3dB freq does not exist
			catch
%				disp(lasterror.message);
				warning("Couldn't find 3dB frequency with given tolerance scaled version will be tried.")
				break;
			end
		end
	end

	for s = 1.1:0.1:5
		for i = 1:2
			if not_found(i)
				ind(i) = center_freq_ind;
			end
		end

		for i = 1:2
			while not_exact(i) && not_found(i)
				ind(i) = ind(i) + state(i);
				try
	%				disp(printf(' lb: %f \n val: %f \n ub: %f \n', S21_3dB-s*tol, S21(ind(i)), S21_3dB+s*tol));
					if  S21_3dB - s*tol < S21(ind(i)) &&  S21(ind(i)) < S21_3dB + s*tol
						not_found(i) = false;
					end
				% do tolerance search since 3dB freq does not exist
				catch
	%				disp(lasterror.message);
					warning("Couldn't find 3dB frequency with given tol.");
					break;
				end
			end
		end
	end

	try
		for i=1:2
			f_range(ind(i));
		end
	catch
		error('out of bounds wrong Q factor calculation.');
	end

	QFactor = center_freq/(f_range(ind(2))-f_range(ind(1)));

