function [freqs] = PeakFinder_v2(S21, f_range, dist)
	% assumption there are only two peaks
	S21_search = S21;
	not_found = true;

	while not_found
		[_, f_index] = max(S21_search);
		if f_range(f_index) < 2.6e9
			s_peak = f_range(f_index);
			not_found = false;
		end
		S21_search(f_index) = [];
	end

	not_found = true;

	while not_found
		[_, f_index] = max(S21);
		if abs(f_range(f_index)-s_peak) > dist && f_range(f_index) < 2.6e9
			f_peak = f_range(f_index);
			not_found = false;
		end
		S21(f_index) = [];
	end

	if f_peak < s_peak
		freqs = [f_peak, s_peak];
	else
		freqs = [s_peak, f_peak];
	end


