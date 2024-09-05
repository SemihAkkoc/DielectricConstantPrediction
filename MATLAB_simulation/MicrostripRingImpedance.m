function [Eeff Z_ring] = MicrostripRingImpedance(W, m, t, Er)

	q = zeros(1,5);

	h = sum(t(1:5-m)); % height of the ring above the ground plane
	H = zeros(1,4);

	Z_ring = 0;

	for i = 1:4
		H(i) = sum(t(1:i))/h;
	end

	if W>=h
		We = W+(2*h/pi)*log(17.08*(W/(2*h)+0.92));
		V4 = (2/pi)*atan(pi*(H(4)-1)/(pi*We/(2*h)-2));

		q(1) = (H(1)/2)*(1+pi/4-(h/We)*log(2*We*sin(pi*H(1)/2)/(h*H(1))+cos(pi*H(1)/2)));
		q(2) = (H(2)/2)*(1+pi/4-(h/We)*log(2*We*sin(pi*H(2)/2)/(h*H(2))+cos(pi*H(2)/2))) - q(1);
		q(3) = 1-(h/(2*We))*log(pi*We/h-1) - q(2);
		q(4) = (h/(2*We))*(log(pi*We/h-1)-(1+V4)*log(2*We*cos(pi*V4/2)/(h*(2*H(4)+V4-1))+sin(pi*V4/2)));
		q(5) = 1 - sum(q(1:4));
	elseif W<h
		A = zeros(1,4);
		B = zeros(1,4);
		index = [1 2 4];
		for i = 1:3
			A(index(i)) = (1+H(index(i)))/(1-H(index(i))+W/(4*h));
			B(index(i)) = (1+H(index(i)))/(H(index(i))+W/(4*h)-1);
		end

		q(1) = log(A(1))*(1+pi/4-acos(W*sqrt(A(1))/(8*h*H(1)))/2)/(2*log(8*h/W));
		q(2) = log(A(2))*(1+pi/4-acos(W*sqrt(A(2))/(8*h*H(2)))/2)/(2*log(8*h/W)) - q(1);
		q(3) = 1/2 + 0.9/(pi*log(8*h/W)) - q(2);
		q(4) = 1/2 - (0.9+(pi/4)*log(B(4))*acos(sqrt(B(4))*(1-(1-W/(8*h))/H(4))))/(pi*log(8*h/W));
		q(5) = 1 - sum(q(1:4));
	end


	Eeff = (sum(q(1:5-m))^2)/(sum(q(1:5-m)./Er(1:5-m))) + (sum(q(5-m+1:5))^2)/(sum(q(5-m+1:5)./Er(5-m+1:5)));

	if W>=h
		Z_ring = 120*pi*h/(sqrt(Eeff)*We);
	elseif W<h
		Z_ring = 60*log(8*h/W)/sqrt(Eeff);
	end
	% Vp = c/sqrt(Eeff);
