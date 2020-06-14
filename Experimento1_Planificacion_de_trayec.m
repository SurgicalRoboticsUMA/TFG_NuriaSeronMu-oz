%% EXPERIMENTO 1.2.
% Este experimento consiste en validad la función de Planificación de
% trayectorias. Para ello, se sitúa el efector final en dos posiciones
% diferentes, cada una de ellas más cerca a uno de los tumores. 
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

% --------------ANALIZAR EL ENTORNO----------------:
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

im_etquit=0;
num_tum_quit=0;
quit=0;
for i=1:num_tum
% -------------REALIMENTACION VISUAL---------------:
subplot(1,2,2); hold on;
[num_tum,centroides,area, im_et]= realimentacion_visual(im,f1,quit,im_etquit,num_tum_quit);
im_etquit=im_et;  
quit=1; 

%bPef=[ 0.1  0.2   0.2   -0.0012  3.1163 0.0389]';   % EF más cerca del tumor de mayor tamaño
bPef=[ 0.18  0.2   0.2   -0.0012  3.1163 0.0389]';   % EF más cerca del tumor de menor tamaño

[bPt_cer, num_tum_quit] = planificacion_de_trayectoria(bPef,centroides,num_tum,Pixelm,bTim);
subplot(1,2,1); hold on;
imPt=(centroides.*Pixelm);
bPt=[];
for k=1:num_tum
bPt(:,k)=[imPt(:,k) ; 0; 1];
end
representar_tumor_entorno(bPt,bTim,f1);
plot3(bPt_cer(1),bPt_cer(2),bPt_cer(3),'*b');

% -------------GENERACION DE TRAYECTORIA---------------:
n=9;
vk=0.03;
pt=0.3;
[Pdestino, vel, acel,k,dist,distacel,distvel,ptau,pTtau,T]=gen_trayec(bPef,bPt_cer,n,vk,pt,f1);
xlim([0.05 0.3]);ylim([0.15 0.4])
pause(3)
end