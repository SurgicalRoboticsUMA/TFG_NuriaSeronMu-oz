%rosinit
pub = rospublisher("/UR3_1/inputs/speed_pose");
msg = rosmessage("std_msgs/Float64MultiArray");
velreal = rossubscriber("/UR3_1/outputs/velocity");

pubpos = rospublisher("/UR3_1/inputs/move_pose");
msgpos = rosmessage("std_msgs/Float64MultiArray");

% Definir las carácterísticas de los elementos del sistema:
Pbase=[0 0 0];
lm_x=0.155;  % Longitud de visión en el eje x de la imagen en metros.
ang=67; % Ángulo de visión de la cámara.
[z,Pixelm,lm_y] = area_de_vision(lm_x,ang);
bTc= [-1  0  0  0.1783; 0  1  0  0.2849; 0  0 -1  z; 0  0  0 1];
 % Posición y rotación del tumor con respecto a la cámara:
 cTim=[-1  0  0   lm_x/2; 0 -1  0   lm_y/2; 0  0  1 z; 0  0  0 1];
bTim=bTc*cTim;   

% Dibujar el entorno de trabajo:
f1=figure;
delta=0.05; % Longitud de los ejes
entorno_quirurgico(Pbase,delta,bTc,cTim)
pos = rossubscriber("/UR3_1/outputs/pose","std_msgs/Float64MultiArray",@callbackposition);

%% Observar el número total de tumores:
  % Se cargan las imagenes de las que se disponen:
load imagenes.mat;
whos -file imagenes.mat;
tam_imagenes=size(imagenes);
num_imagenes=tam_imagenes(2);

for j = 1:num_imagenes
  eval(['im',num2str(j),'= imagenes{1,',num2str(j),'};']); 
end  
 % Se elije la imagen a analizar:
im=im1;
 % Ejecuto la funcion realimentacion_visual:
f2=figure;
[num_tum,imPt,area]= realimentacion_visual(im,f2);
  
%% Eliminar todos los tumores:
im_etquit=0;
num_tum_quit=0;
quit=0;
for i=1:num_tum
% ------------ REALIMENTACION VISUAL----------------:
figure(f2);
[num_tum,imPt,area, im_et]= realimentacion_visual(im,f2,quit,im_etquit,num_tum_quit);
im_etquit=im_et;  
quit=1; 

%---------- PLANIFICACION DE TRAYECTORIA-------------:
bPef= pos.LatestMessage.Data;
[bPt_cer, num_tum_quit] = planificacion_de_trayectoria(bPef,imPt,num_tum,Pixelm,bTim);

%----------- GENERACION DE TRAYECTORIA----------------:
% Primero desde el efector final al tumor:
n=50;
vk=0.03;
pt=0.3;
figure(f1);
[Pdestino, vel, acel,k,dist,distacel,distvel,ptau,pTtau,T,a]=gen_trayec(bPef,bPt_cer,n,vk,pt,f1);
vel(:,end)=vel(:,end-1);
vel(:,1)=vel(:,2);
enviar_datos_gen_trayec(Pdestino,bPef,bPef,vel,n,msg,pub,pos)
pause(1.5);

Porigen=pos.LatestMessage.Data;
% Luego del tumor al efector final:
vel=[];
[Pdestino, vel, acel,k,dist,distacel,distvel,ptau,pTtau,T,a]=gen_trayec(bPt_cer,bPef,n,vk,pt,f1);
vel(:,end)=vel(:,end-1);
vel(:,1)=vel(:,2);
enviar_datos_gen_trayec(Pdestino,Porigen,bPef,vel,n,msg,pub,pos)

pause(1);
Porigen=pos.LatestMessage.Data;
%---------------- DEPOSITAR EL TUMOR-----------------:
Pintermedio =[  0.2515   0.225    0.1677   -0.0012    3.1163   0.0389]';
msgpos.Data = Pintermedio;
send(pubpos,msgpos);
fin_movimiento(Pintermedio,Porigen,pos)
pause(0.5);
Porigen=pos.LatestMessage.Data;

Psoltar_arriba =[  0.2515   -0.2173    0.1677   -0.0012    3.1163   0.0389]';
msgpos.Data = Psoltar_arriba;
send(pubpos,msgpos);
fin_movimiento(Psoltar_arriba,Porigen,pos)
pause(0.5);
Porigen=pos.LatestMessage.Data;

Psoltar =[0.2515 -0.2173 0.0697 -0.0012   3.1163 0.0389]';
msgpos.Data = Psoltar;
send(pubpos,msgpos);
fin_movimiento(Psoltar,Porigen,pos)
pause(0.5);
Porigen=pos.LatestMessage.Data;

Psoltar_arriba =[  0.2515   -0.2173    0.1677   -0.0012    3.1163   0.0389]';
msgpos.Data = Psoltar_arriba;
send(pubpos,msgpos);
fin_movimiento(Psoltar_arriba,Porigen,pos)
pause(0.5);
Porigen=pos.LatestMessage.Data;

Pintermedio =[  0.2515   0.225    0.1677   -0.0012    3.1163   0.0389]';
msgpos.Data = Pintermedio;
send(pubpos,msgpos);
fin_movimiento(Pintermedio,Porigen,pos)
pause(0.5);
Porigen=pos.LatestMessage.Data;

msgpos.Data = bPef;
send(pubpos,msgpos);
fin_movimiento(bPef,Porigen,pos)
pause(0.5);
end

clear pos