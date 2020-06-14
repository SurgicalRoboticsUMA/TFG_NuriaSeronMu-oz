function [Pdestino, vel, acel,k,dist,distacel,distvel,ptau,pTtau,T,a]=gen_trayec(bPef,bPdestino,n,vk,pt,fig_puntos,fig_vel,fig_acel)
% Esta función genera una trayectoria cartesiana con un perfil de velocidad
% trapezoidal. 
% Recibe como parametros de entrada dos puntos del espacio tridimensional,
% y el número de puntos que se desea que contenga la trayectoria; y delvuelve tres
% matrices: una con las tres coordenadas de cada uno de los puntos que
% conforman la trayectoria, otras dos con el perfil de velocidad y aceleracion 
% en x,y,z y su norma.
switch nargin 
    case 5
        fig_puntos=0;fig_vel=0;fig_acel=0;
    case 6
        fig_vel=0;fig_acel=0;
    case 7
        fig_acel=0;
end

p0=(bPef(1:3,1));
p1=(bPdestino(1:3,1));

% Definir valores para la generación de puntos:
v0=0;    % Velocidad inicial 
k=round(pt*n);
dif=p1-p0;
dist=sqrt(dif(1)^2+dif(2)^2+dif(3)^2);
T=dist/(vk*(1-pt));
tau=T*pt;
tiempo=[];
for s=0:n-1
tiempo=[tiempo T/(n-1)*s];
end


a=vk/tau;
kc=n-2*k;  % Kc tiene que ser mayor que 1!

% Punto de transición de acelerado a velocidad constante:
xptau=1/(2*dist)*a*tau^2*dif(1)+p0(1);
yptau=1/(2*dist)*a*tau^2*dif(2)+p0(2);
zptau=1/(2*dist)*a*tau^2*dif(3)+p0(3);
ptau=[xptau yptau zptau]';

% Punto de transición de velocidad constante a desacelerado:
xpTtau=vk*(T-2*tau)/dist*dif(1)+xptau;
ypTtau=vk*(T-2*tau)/dist*dif(2)+yptau;
zpTtau=vk*(T-2*tau)/dist*dif(3)+zptau;
pTtau=[xpTtau ypTtau zpTtau]';

% ------------------ PRIMER SEGMENTO -----------------------
difacel=ptau-p0;
distacel=sqrt(difacel(1)^2+difacel(2)^2+difacel(3)^2);
Tseg1=2*distacel/(vk+v0);
a=(vk-v0)/Tseg1;

c=Tseg1/k;
tkseg1=[];
for i=0:k
tkseg1=[tkseg1 c*i];
end

xseg1=1/(2*distacel)*(a*tkseg1(1:k).^2+v0*tkseg1(1:k))*difacel(1)+p0(1);
yseg1=1/(2*distacel)*(a*tkseg1(1:k).^2+v0*tkseg1(1:k))*difacel(2)+p0(2);
zseg1=1/(2*distacel)*(a*tkseg1(1:k).^2+v0*tkseg1(1:k))*difacel(3)+p0(3);

Pseg1=[xseg1;yseg1;zseg1];
[fseg1,cseg1]=size(Pseg1);

vx=[];vy=[];vz=[];vel=[];
ax=[]; ay=[]; az=[];acel=[];
for l=1:cseg1
 eval(['P',num2str(l),'=Pseg1(:,l);']);
 vx1=1/(distacel)*a*tiempo(l)*difacel(1);
 vy1=1/(distacel)*a*tiempo(l)*difacel(2);
 vz1=1/(distacel)*a*tiempo(l)*difacel(3);
 v=sqrt(vx1^2+vy1^2+vz1^2);
 ax1=1/(distacel)*a*difacel(1);
 ay1=1/(distacel)*a*difacel(2);
 az1=1/(distacel)*a*difacel(3);
 ac=sqrt(ax1^2+ay1^2+az1^2);
 vx=[vx vx1];vy=[vy vy1];vz=[vz vz1];vel=[vel v];
 ax=[ax ax1];ay=[ay ay1];az=[az az1];acel=[acel ac];
end

% ------------------- SEGUNDO SEGMENTO -----------------------
difvel=pTtau-ptau;
distvel=sqrt(difvel(1)^2+difvel(2)^2+difvel(3)^2);
Tseg2=distvel/vk;

tkseg2=[];
for j=0:kc-1
tkseg2=[tkseg2 j/(kc-1)];
end

xseg2=tkseg2*difvel(1)+ptau(1);
yseg2=tkseg2*difvel(2)+ptau(2);
zseg2=tkseg2*difvel(3)+ptau(3);

Pseg2=[xseg2;yseg2;zseg2];
[fseg2,cseg2]=size(Pseg2);

 vx2=vk*difvel(1)/distvel;
 vy2=vk*difvel(2)/distvel;
 vz2=vk*difvel(3)/distvel;
 v=sqrt(vx2^2+vy2^2+vz2^2);
 ax2=0; ay2=0;az2=0;ac=0;
for m=1:cseg2
 eval(['P',num2str(m+cseg1),'=Pseg2(:,m);']);
 vx=[vx vx2];vy=[vy vy2];vz=[vz vz2];vel=[vel v];
 ax=[ax ax2];ay=[ay ay2];az=[az az2];acel=[acel ac];
end

% --------------------TERCER SEGMENTO-----------------------------
difter=p1-pTtau;
distter=sqrt(difter(1)^2+difter(2)^2+difter(3)^2);
xseg3=1/distter*(-1/2*a*tkseg1(2:k+1).^2+vk*tkseg1(2:k+1))*difter(1)+pTtau(1);
yseg3=1/distter*(-1/2*a*tkseg1(2:k+1).^2+vk*tkseg1(2:k+1))*difter(2)+pTtau(2);
zseg3=1/distter*(-1/2*a*tkseg1(2:k+1).^2+vk*tkseg1(2:k+1))*difter(3)+pTtau(3);

Pseg3=[xseg3;yseg3;zseg3];
[fseg3,cseg3]=size(Pseg3);

for r=1:cseg3
  eval(['P',num2str(r+cseg1+cseg2),'=Pseg3(:,r);']);
  vx3=difter(1)/distter*(-a*(tiempo(cseg1+cseg2+r)-T+tau)+vk);
  vy3=difter(2)/distter*(-a*(tiempo(cseg1+cseg2+r)-T+tau)+vk);
  vz3=difter(3)/distter*(-a*(tiempo(cseg1+cseg2+r)-T+tau)+vk);
  v=sqrt(vx3^2+vy3^2+vz3^2);
  ax3=difter(1)/distter*(-a);
  ay3=difter(2)/distter*(-a);
  az3=difter(3)/distter*(-a);
  ac=sqrt(ax3^2+ay3^2+az3^2);
  vx=[vx vx3];vy=[vy vy3];vz=[vz vz3];vel=[vel v];
  ax=[ax ax3];ay=[ay ay3];az=[az az3];acel=[acel ac];
end

vel=[vel ; vx; vy; vz];
acel=[acel; ax; ay; az];
Pdestino=[];
for s=1:n
      eval(['Pdestino=[Pdestino,P',num2str(s),'];']);
end

if fig_puntos~=0
figure(fig_puntos);
hold on
plot3([Pdestino(1,1);Pdestino(1,n)],[Pdestino(2,1);Pdestino(2,n)],[Pdestino(3,1);Pdestino(3,n)],'Color', [0.5 0.5 0.5]);
plot3(Pdestino(1,(1:k)),Pdestino(2,(1:k)),Pdestino(3,(1:k)),'.y');
plot3(Pdestino(1,(k+1:n-k)),Pdestino(2,(k+1:n-k)),Pdestino(3,(k+1:n-k)),'.g');
plot3(Pdestino(1,(n-k+1:n)),Pdestino(2,(n-k+1:n)),Pdestino(3,(n-k+1:n)),'.b');
plot3(p1(1),p1(2),p1(3),'or')
text(p1(1)+0.005,p1(2)+0.005 ,p1(3)+0.005, 'p1','Fontsize',12);
plot3(p0(1),p0(2),p0(3),'or')
text(p0(1)+0.005,p0(2) +0.005,p0(3)+0.005, 'p0','Fontsize',12);
title('Trayectoria cartesiana en línea recta');
xlabel('x(m)');ylabel('y(m)');zlabel('z(m)');

end

if fig_vel~=0
figure(fig_vel)
subplot(2,2,1)
plot(tiempo,vel(2,:),'Color', [0.5 0.5 0.5]); hold on; plot(tiempo,vel(2,:),'.r');xlim([0, T]);grid on;title('a)Velocidad en X'); xlabel('t(s)');ylabel('vx(m/s)');
subplot(2,2,2)
plot(tiempo,vel(3,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,vel(3,:),'.g');xlim([0, T]);grid on;title('b)Velocidad en Y');xlabel('t(s)');ylabel('vy(m/s)');
subplot(2,2,3)
plot(tiempo,vel(4,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,vel(4,:),'.c');xlim([0, T]);grid on;title('c)Velocidad en Z'); xlabel('t(s)');ylabel('vz(m/s)');
subplot(2,2,4)
plot(tiempo,vel(1,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,vel(1,:),'.m');xlim([0, T]);grid on;title('d)Norma de la velocidad'); xlabel('t(s)');ylabel('v(m/s)');
end

if fig_acel~=0
figure(fig_acel)
subplot(2,2,1)
plot(tiempo,acel(2,:),'Color', [0.5 0.5 0.5]); hold on; plot(tiempo,acel(2,:),'.r');xlim([0, T]);grid on;title('a)Aceleración en X');xlabel('t(s)');ylabel('ax(m/s^2)');
subplot(2,2,2)
plot(tiempo,acel(3,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,acel(3,:),'.g');xlim([0, T]);grid on;title('b)Aceleración en Y');xlabel('t(s)');ylabel('ay(m/s^2)');
subplot(2,2,3)
plot(tiempo,acel(4,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,acel(4,:),'.c');xlim([0, T]);grid on;title('c)Aceleración en Z');xlabel('t(s)');ylabel('az(m/s^2)');
subplot(2,2,4)
plot(tiempo,acel(1,:),'Color', [0.5 0.5 0.5]);hold on;plot(tiempo,acel(1,:),'.m');xlim([0, T]);grid on;title('d)Norma de la aceleración');xlabel('t(s)');ylabel('a(m/s^2)');
end

end



