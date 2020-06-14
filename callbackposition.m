function callbackposition(srv,msg)

global pRec

pRec(:,end+1) = msg.Data;
msg.Data;
plot3(msg.Data(1),msg.Data(2),msg.Data(3),'*r'); hold on
