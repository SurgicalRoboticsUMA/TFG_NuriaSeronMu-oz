function entorno_quirurgico(Pbase,delta,bTc,cTt)
%Función que dibuja un sistema de referencia, cuyos ejes tienen una longitud
%delta.
bPc=bTc(1:3,4);
cTt=cTt(1:3,4);

 hold on
%-------------Sistema de referencia de la base-----------------------:
% Eje X:
line('XData', [Pbase(1) Pbase(1)+delta], 'YData', [Pbase(2) Pbase(2)],...
    'ZData', [Pbase(3) Pbase(3)], 'Color','r','LineWidth',1);
% Eje Y:
line('XData', [Pbase(1) Pbase(1)], 'YData', [Pbase(2) Pbase(2)+delta],...
    'ZData', [Pbase(3) Pbase(3)], 'Color','g','LineWidth',1);
% Eje Z:
line('XData', [Pbase(1) Pbase(1)], 'YData', [Pbase(2) Pbase(2)],...
    'ZData', [Pbase(3) Pbase(3)+delta], 'Color','b','LineWidth',1);
    text(Pbase(1),Pbase(2)-0.03 ,Pbase(3), 'B','Fontsize',10);
    
%---------------Sujección de la cámara------------------------------:
line('XData', [bPc(1) bPc(1)], 'YData', [ bPc(2)+0.1 bPc(2)+0.1],...
    'ZData', [0 bPc(3)], 'Color','k','LineWidth',3);
line('XData', [bPc(1) bPc(1)], 'YData', [ bPc(2) bPc(2)+0.1],...
    'ZData', [bPc(3) bPc(3)], 'Color','k','LineWidth',3);

%-------------Sistema de referencia de la cámara-----------------------:
line('XData', [bPc(1) bPc(1)-delta], 'YData', [bPc(2) bPc(2)],...
    'ZData', [bPc(3) bPc(3)], 'Color','r','LineWidth',1);
% Eje Y:
line('XData', [bPc(1) bPc(1)], 'YData', [bPc(2) bPc(2)+delta],...
    'ZData', [bPc(3) bPc(3)], 'Color','g','LineWidth',1);
% Eje Z:
line('XData', [bPc(1) bPc(1)], 'YData', [bPc(2) bPc(2)],...
    'ZData', [bPc(3) bPc(3)-delta], 'Color','b','LineWidth',1);
text(bPc(1)-0.005,bPc(2)-0.005 ,bPc(3), 'C','Fontsize',10);
%-----------------Area de visión de la cámara-------------------------:
a=cTt(1);
b=cTt(2);
plot3([bPc(1)-a;bPc(1)+a],[bPc(2)+b;bPc(2)+b],[0;0],'Color',[0.5 0.5 0.5])
plot3([bPc(1)-a;bPc(1)+a],[bPc(2)-b;bPc(2)-b],[0;0],'Color',[0.5 0.5 0.5])
plot3([bPc(1)+a;bPc(1)+a],[bPc(2)-b;bPc(2)+b],[0;0],'Color',[0.5 0.5 0.5])
plot3([bPc(1)-a;bPc(1)-a],[bPc(2)-b;bPc(2)+b],[0;0],'Color',[0.5 0.5 0.5])
text(bPc(1),bPc(2)-b+0.01 ,0, 'Área de visión','Fontsize',7);

%-------------Sistema de referencia de la imagen-----------------------:
% Eje X:
line('XData', [bPc(1)-a bPc(1)-a+delta], 'YData', [ bPc(2)+b bPc(2)+b],...
    'ZData', [0 0], 'Color','r','LineWidth',1);
% Eje Y:
line('XData', [bPc(1)-a bPc(1)-a], 'YData', [bPc(2)+b bPc(2)+b-delta],...
    'ZData', [0 0], 'Color','g','LineWidth',1);
% Eje Z:
line('XData', [bPc(1)-a bPc(1)-a], 'YData', [bPc(2)+b bPc(2)+b],...
    'ZData', [0 0-delta], 'Color','b','LineWidth',1);
    text(bPc(1)-a-0.009 ,bPc(2)+b,0, 'Im','Fontsize',10);

xlim([-0.05 0.3])
ylim([-0.25 0.4])
zlim([-0.1 0.3])

xlabel('x(m)');ylabel('y(m)');zlabel('z(m)')
%title('Entorno de simulación')
end
