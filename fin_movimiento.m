function fin_movimiento(Pdestino,Porigen,subpos)
    d_des=sqrt((Porigen(1)-Pdestino(1))^2+(Porigen(2)-Pdestino(2))^2+(Porigen(3)-Pdestino(3))^2);
    d_real=0;
    % Comparar que la distancia al punto inicial actual es menor a la
    % deseada:
    while round(d_real,3)<round(d_des,3)
       lec = subpos.LatestMessage.Data;  
       pause(0.008);         
       d_real=sqrt((Porigen(1)-lec(1))^2+(Porigen(2)-lec(2))^2+(Porigen(3)-lec(3))^2);
    end
end

