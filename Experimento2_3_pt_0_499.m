%% EXPERIMENTO 2.3.
% Genera una trayectoria con el perfil de velocidad trapezoidal, y se la
% envía al robot. Al mismo tiempo realiza una lectura en tiempo real de su
% posición y velocidad real.
% Los valores utilizados para generar la trayectoria han sido: n=50,
% vmax=0.03, pt=0.499.

pub = rospublisher("/UR3_1/inputs/speed_pose");
msg = rosmessage("std_msgs/Float64MultiArray");

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

% --------------REALIMENTACION VISUAL----------------:
load imagenes.mat;
whos -file imagenes.mat;
tam_imagenes=size(imagenes);
num_imagenes=tam_imagenes(2);
for j = 1:1
  eval(['im',num2str(j),'= imagenes{1,',num2str(j),'};']); 
end  
im=im1;
[num_tum,imPt,area]= realimentacion_visual(im);
  
%---------- PLANIFICACION DE TRAYECTORIA-------------:
bPef= [ 0.17   0.2   0.1438   -0.0012  3.1163 0.0389]';    % Efector final más cerca del tumor 2
%bPef= [ 0.13   0.2   0.1438   -0.0012  3.1163 0.0389]';    % Efector final más cerca del tumor 1
msgpos.Data = bPef;
send(pubpos,msgpos);
[bPt_cer, num_tum_quit] = planificacion_de_trayectoria(bPef,imPt,num_tum,Pixelm,bTim);
num_tum_quit
%----------- GENERACION DE TRAYECTORIA----------------:
n=50;        % Muestras
vk=0.03;    % Velocidad máxima
pt=0.4999;
fig_pos=figure; hold on;
fig_vel=figure; hold on;
fig_acel=figure; hold on;
[Pdestino, vel, acel,k,dist,distacel,distvel,ptau,pTtau,T]=gen_trayec(bPef,bPt_cer,n,vk,pt,fig_pos,fig_vel,fig_acel);

vel(:,end)=vel(:,end-1);

global pRec
pRec = zeros(6,1);
figure(fig_pos);
pos = rossubscriber("/UR3_1/outputs/pose","std_msgs/Float64MultiArray",@callbackposition);

global vreal
vreal = zeros(6,1);
velreal = rossubscriber("/UR3_1/outputs/velocity","std_msgs/Float64MultiArray",@callbackvelocity);

vdes=[];
Pdes=[];
for j=1:n
    Pdes(1:3,1) = Pdestino(:,j);
    Pdes(4:6,1)=bPef(4:6);
    vdes(1:3,1) = vel(2:4,j);
    vdes(4:6,1)=[0 0 0]';
    d_des=sqrt((bPef(1)-Pdes(1))^2+(bPef(2)-Pdes(2))^2+(bPef(3)-Pdes(3))^2);
    d_real=0;
    % Comparar que la distancia al punto inicial actual es menor a la
    % deseada:
    while d_real<d_des
       msg.Data = vdes;
       send(pub,msg); 
       lec = pos.LatestMessage.Data;  
       pause(0.008);         
       d_real=sqrt((bPef(1)-lec(1))^2+(bPef(2)-lec(2))^2+(bPef(3)-lec(3))^2);
    end
end

clear velreal
clear acelreal
% Error del punto destino deseado con el alcanzado por el robot:
posf= pos.LatestMessage.Data;
error_posicion= bPt_cer(1:3)-posf(1:3)
clear pos

% Representar la velocidad real sobre la deseada:
figure(fig_vel)
x=linspace(0,T,length(vreal));
subplot(2,2,1);plot(x,vreal(1,:),'*'); hold on;
subplot(2,2,2);plot(x,vreal(2,:),'*'); hold on;
subplot(2,2,3);plot(x,vreal(3,:),'*'); hold on;
vnorma=[];
for i=1:length(vreal)
   vnorma(1,i)=sqrt(vreal(1,i)^2+vreal(2,i)^2+vreal(3,i)^2);
end
subplot(2,2,4);plot(x,vnorma,'*'); hold on;

% Error velocidad deseada con la obtenida en algunos puntos:
tiempo=[];
for s=0:n-1
tiempo=[tiempo T/(n-1)*s];
end
t_e=linspace(0.01,T,7);
error_vel=[];
for k=1:length(t_e)
vreal_e=interp1(x,vnorma,t_e(k));
vel_e=interp1(tiempo,vel(1,:),t_e(k));
error_vel(1,k)=abs(vreal_e-vel_e);
end
error_max_vel=max(error_vel)