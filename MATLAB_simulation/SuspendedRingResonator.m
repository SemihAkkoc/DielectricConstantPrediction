function [S21] = SuspendedRingResonator(f_range, eps_sample, tan_loss_sample)

	% Function Input:
	% f_range -> the frequency range that S21 will be computed
	% eps_sample -> dielectric constant of sample
	% tan_loss_sample -> tangent loss of sample
	%
	% Function Output:
	% S21 -> scattering parameter of suspended ring resonator
	%        computed at frequencies that f_range encompases

	eps_air = 1.00059;
	tan_loss_air = 0;
	eps_material = 4.25;
	tan_loss_material = 0.016;
	mu0 = pi*4e-7;
	eps0 = 8.85418782e-12;

	w = 2.2e-3; % feed lines microstip ring width
	s = 2.5e-4; % gap between ring and feed line for C
	r = 25.9e-3; % ring resonator radius
	len = pi*r; % L is PI*Rm used in S21
	t = 1.5e-3; % thickness of sample layer
	gap = 0.75e-3; % thickness of air gap layer
	t_material = 62*2.54e-5; % thickness of material

	m = 2; % indicates which layer ring osc. is at DO NOT change it

	T = [t_material t gap t_material]; % thicknesses of layers, mat., sample, gap, mat.
	E = [eps_material eps_sample eps_air eps_material eps_air]; % dielectric constants of material FR-4 and air
	D = [tan_loss_material tan_loss_sample tan_loss_air tan_loss_material tan_loss_air]; % tangential losses of material and air

	% calculation of impedances Z0 and Z_ring
	%[line_Eeff line_Z0] = MicrostripImpedance(w, T(1), E(1)*(1-j*D(1))); % if we were to calculate strip's empedance
	[ring_Eeff ring_Z0] = MicrostripRingImpedance(w, m, T, E.*(1-j*D));

	line_Z0 = 50; % reference impedance

	[Cp Cg] = GapCapacitance(w, T(1), s, E(1));

	omega = 2*pi*f_range;
	R = zeros(1, length(f_range));

	for i = 1:length(f_range)
		R(i) = RingRadiationM(real(ring_Eeff), E, T, len, line_Z0, f_range(i));
	end


	w = omega;
	Z0 = line_Z0;
	Z_ring = ring_Z0;
	L = len;

	y = j*omega.*sqrt(mu0*eps0*ring_Eeff) + R;

%	Z0 = 50;
%	Z_ring = 61.34;
%	Cp = 9.266e-15;
%	Cg = 82.90e-15;
%	Eeff = 3.103;


	PSI = 4*(exp(-2*y.*L)-1) ...
	+ j*4*w.*(2*Z0.*Cp.*exp(-2*y.*L) + 2*Z0.*Cg.*exp(-2*y.*L) - Z_ring.*Cg.*exp(-2*y.*L) - Z_ring.*Cg - 2*Z0.*Cg - 2*Z0.*Cp) ...
	+(w.^2).*(4*(Z0.^2).*Cp.^2 + 8*(Z0.^2).*Cg.*Cp + (Z_ring.^2).*Cg.^2 + 8*Z0*Z_ring*Cg*Cp + 4*(Z0^2)*(Cg^2)+ 4*Z0.*Z_ring.*Cg.^2 ...
	- 8*(Z0.^2).*Cg.*Cp.*exp(-2*y.*L) + 8*Z0.*Z_ring.*Cg.*Cp.*exp(-2*y.*L) ...
	+ 4*Z0.*Z_ring.*(Cg^2).*exp(-2*y.*L)-4*(Z0^2).*(Cg^2).*exp(-2*y.*L) ...
	- 4*(Z0.^2).*(Cp.^2).*exp(-2*y.*L) - (Z_ring.^2).*(Cg.^2).*exp(-2*y.*L)) ...
	+(j*2*w.^3).*(2*Z0.*Z_ring.*(Cg^2).*Cp + 2*(Z0.^2).*Z_ring.*Cg.*Cp.^2 ...
	+ Z0.*(Z_ring.^2).*(Cg.^2).*Cp +2*(Z0.^2).*Z_ring.*Cg.*(Cp.^2).*exp(-2*y.*L) ...
	+ 2*(Z0.^2).*Z_ring.*(Cg.^2)*Cp.*exp(-2*y.*L) -Z0.*(Z_ring^2).*(Cg^2).*Cp.*exp(-2*y.*L)) ...
	+(w.^4).*(Z0^2).*(Z_ring.^2).*(Cg.^2).*(Cp.^2).*(exp(-2*y.*L)-1);

	S21 = 8*Z0.*Z_ring.*(Cg.^2)*exp(-y.*L).*(w.^2)./PSI;

