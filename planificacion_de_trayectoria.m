function [bPt_cer, num_tum_cercano] = planificacion_de_trayectoria(bPef,imPt,num_tum,Pixelm,bTim)
% Transformar la posición de los tumores dada en píxeles, en metros:
imPt=(imPt.*Pixelm);

% Para cada tumor:
for k=1:num_tum
    % Convertir la posición 2D en coordenadas homogeneas:
    Pt=[imPt(:,k) ; 0; 1];
    % Transformar la posición del tumor que viene dada respecto de la imagen, a respecto la base: 
    bPt(:,k)=bTim*Pt;
    % Calcular la distancia entre el efector final y el tumor:
    d(1,k)=sqrt((bPt(1,k)-bPef(1))^2+(bPt(2,k)-bPef(2))^2+(bPt(3,k)-bPef(3))^2);
end 

% Obtener la distancia mínima y la posición del array que ocupa, siendo esta
% la correspondiente al tumor numerado en la función de realimentacion visual:
[dmin pos]=min(d);
% Enviar la posición del tumor más cercano con respecto de la base:
bPt_cer=bPt((1:3),pos);
num_tum_cercano=pos;
end

