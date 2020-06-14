function [z,Pixelm,lm_y] = calibracion(lm_x,ang)
c=lm_x/2;
ang=ang/2*pi/180;
h=c/sin(ang);
z=cos(ang)*h;
Pixelm=lm_x/640;
lm_y=480*Pixelm;
end

