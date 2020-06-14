%% EXPERIMENTO 1.1.
% Comprueba que realiza bien la transformación de la posición de los tumores
% respecto a la imagen, dada por la función de realimentación visual en píxeles, a
% respecto la base del robot.
% ----------CARACTERISTICAS DEL SISTEMA---------------:
Pbase=[0 0 0];
lm_x=0.155;  % Longitud de visión en el eje x de la imagen en metros.
ang=67; % Ángulo de visión de la cámara.
[z,Pixelm,lm_y] = area_de_vision(lm_x,ang);
bTc= [-1  0  0  0.1783; 0  1  0  0.2849; 0  0 -1  z; 0  0  0 1];
 % Posición y rotación del tumor con respecto a la cámara:
 cTim=[-1  0  0   lm_x/2; 0 -1  0   lm_y/2; 0  0  1 z; 0  0  0 1];
bTim=bTc*cTim; 

%--------------REPRESENTAR EL ENTORNO-----------------:
f1=figure;
subplot(1,2,1); hold on;
title('a) Tumores en el entorno de simulación','Fontsize',10)
delta=0.05; % Longitud de los ejes
entorno_quirurgico(Pbase,delta,bTc,cTim);

% --------------REALIMENTACION VISUAL----------------:
load imagenes.mat;
whos -file imagenes.mat;
tam_imagenes=size(imagenes);
num_imagenes=tam_imagenes(2);

for j = 1:num_imagenes
  eval(['im',num2str(j),'= imagenes{1,',num2str(j),'};']); 
end  
im=im1;
subplot(1,2,2); hold on;
title('b)Tumores en la imagen ','Fontsize',10)
[num_tum,centroides,area, im_et]= realimentacion_visual(im,f1);
hold on;
plot(320,240,'*b');
text(320+5,240, 'C','Fontsize',10,'Color', 'black' );
hold off;
imPt=(centroides.*Pixelm);
bPt=[];
for k=1:num_tum
bPt(:,k)=[imPt(:,k) ; 0; 1];
end
subplot(1,2,1); hold on;
representar_tumor_entorno(bPt,bTim,f1);
xlim([0.05 0.3]);ylim([0.15 0.4])


