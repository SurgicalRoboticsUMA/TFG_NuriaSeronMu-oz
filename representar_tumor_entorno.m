function representar_tumor_entorno(Pt,bTim,fig)

bPt=bTim*Pt;
a=size(Pt);
b=a(2);
for i=1:b
    hold on
    plot3(bPt(1,i),bPt(2,i), bPt(3,i), '*r')
    text(bPt(1,i)+0.01,bPt(2,i), sprintf('%d',i),'Fontsize',10,'Color', 'red');
end

end

