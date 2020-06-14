function enviar_datos_gen_trayec(Pdestino,Porigen,bPef,vel,n,msg,pub,pos)
vdes=[];
Pdes=[];
for j=1:n
    Pdes(1:3,1) = Pdestino(:,j);
    Pdes(4:6,1)=bPef(4:6);
    vdes(1:3,1) = vel(2:4,j);
    vdes(4:6,1)=[0 0 0]';
    d_des=sqrt((Porigen(1)-Pdes(1))^2+(Porigen(2)-Pdes(2))^2+(Porigen(3)-Pdes(3))^2);
    d_real=0;
    % Comparar que la distancia al punto inicial actual es menor a la
    % deseada:
    while d_real<d_des
       msg.Data = vdes;
       send(pub,msg); 
       lec = pos.LatestMessage.Data;  
       pause(0.008);         
       d_real=sqrt((Porigen(1)-lec(1))^2+(Porigen(2)-lec(2))^2+(Porigen(3)-lec(3))^2);
    end
end
end

