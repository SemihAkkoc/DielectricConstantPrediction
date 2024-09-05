function [EffRad] = RingRadiation(Eeff, E, T, L, Z0, f)

	% I0=1 has been assumed
	I0 = 1;
	mu0 = pi*4e-7;
	eps0 = 8.85418782e-12;
	n0 = sqrt(mu0./eps0);
	c0 = 1./sqrt(mu0.*eps0);

	w = 2*pi*f;
	k = w.*sqrt(mu0.*eps0);
	ke = k.*sqrt(Eeff);

	h = sum(T(1:3)); % height of the ring above the ground plane
	Esr = sum(E(1:4).*T(1:4))/h;
	v = sqrt(Esr-1);

	A = @(theta, phi) sin((ke - k.*sin(theta).*cos(phi)).*L./2)/((ke - k.*sin(theta).*cos(phi)).*L./2);

	Rv = @(theta) ((Esr.*cos(theta))-j.*v.*tan(k.*v.*h))./((Esr.*cos(theta))+j.*v.*tan(k.*v.*h));
	Rh = @(theta) (cos(theta)+j.*v.*cot(k.*v.*h))./(cos(theta)-j.*v.*cot(k.*v.*h));

	F = @(theta, phi) j.*2.*sin((ke-k.*sin(theta).*cos(phi)).*L./2);
	r = 10.*c0./f; % we are calculating at 10*lambda

	E_theta = @(theta, phi) j.*w.*mu0.*I0.*L.*A(theta,phi).*(Rv(theta)-1).*cos(theta).*cos(phi).*exp(-j.*k.*r)./(4.*pi.*r) ...
	+j.*w.*mu0.*I0.*F(theta, phi).*(Rv(theta)+1).*tan(k.*v.*h).*sin(theta).*exp(-j.*k.*r)./(8.*pi.*Esr.*k.*v.*r);
	% implemented 1/2 in the second term due to current being shared between the two
	% halves of the ring

	E_phi = @(theta, phi) j.*w.*mu0.*I0.*L.*A(theta,phi).*(Rh(theta)+1).*sin(phi).*exp(-j*k*r)./(4.*pi.*r);

	P = @(theta, phi) (abs(E_theta(theta, phi)).^2+abs(E_phi(theta,phi)).^2).*sin(theta)./n0;

	disp(P(pi/2, pi/4))
	error('STOP');
	P_rad = integral2(P, 0, pi/2, 0, 2*pi);
	P_inc = abs(I0).^2.*Z0;

	E_rad = P_rad./P_inc;

	EffRad = E_rad./(2.*L); % i.e. R = E_rad/(2*L)

