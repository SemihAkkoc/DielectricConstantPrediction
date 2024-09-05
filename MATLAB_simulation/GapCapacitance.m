function [Cp Cg] = GapCapacitance(w, h, s, Er)

	m_0 = (w/h)*(0.619*log10(w/h)-0.3853);
	k_0 = 4.26-1.453*log10(w/h);
	C_odd96 = w*((s/w)^m_0)*exp(k_0);

	C_even96 = 0;

	if 0.1 < s/w & s/w < 0.5
		m_e = 0.8675;
		k_e = 2.043*((w/h)^0.12);
		C_even96 = 12*w*((s/w)^m_e)*exp(k_e);
	elseif 0.5<= s/w & s/w <= 1
		m_e = 1.565/((w/h)^0.16)-1;
		k_e = 1.97-0.03/(w/h);
		C_even96 = 12*w*((s/w)^m_e)*exp(k_e);
	else
		error('s/w must be between 0.1 and 1');
	end

	C_even = 1.167*C_even96*((Er/9.6)^0.9);
	C_odd = 1.1*C_odd96*((Er/9.6)^0.8);

	Cp = (C_even/2)*1e-12;
	Cg = ((2*C_odd-C_even)/4)*1e-12;
