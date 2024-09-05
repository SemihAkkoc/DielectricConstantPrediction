% Analytical Integration

z = 1:-0.01:0.01;

Pio_ui=1;
Pio=1/2;

lip = sqrt(3)/2;
lin = -lip;

Rio = @(z) sqrt(1/4 + z.^2);
Ripn = @(z) sqrt(1+z.^2);

I = @(z) 3*(Pio_ui*Pio*log((Ripn(z)+lip)./(Ripn(z)+lin))-abs(z).*(3*Pio_ui*(atan(Pio*lip./(Rio(z).^2+abs(z).*Ripn(z)))-atan(Pio*lin./(Rio(z).^2+abs(z).*Ripn(z))))));

I_a = I(z);

figure;
plot(z,I_a)
title('Analytical Integration')
xlabel('z')

