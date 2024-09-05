function [Eeff Z0] = MicrostripImpedance(W, h, Er)

	mu0 = pi*4e-7;
	eps0 = 8.85418782e-12;
	c = 1/sqrt(mu0*eps0);

	Zf = sqrt(mu0/eps0);

	if W<h
		Eeff = (Er+1)/2 + (Er-1)*((1+12*h/W)^-0.5 + 0.04*(1-W/h)^2)/2;
		Z0 = Zf*log(8*h/W + W/(4*h))/(2*pi*sqrt(Eeff));
	elseif W>=h
		Eeff = (Er+1)/2 + (Er-1)*(1+12*h/W)^-0.5/2;
		Z0 = Zf/(sqrt(Eeff)*(1.393 + W/h + 2*log(W/h + 1.444)/3));
	end
	% Vp = c/sqrt(Eeff);
	% take Z0 = 50
