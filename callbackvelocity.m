function callbackvelocity(srv,msg)
global vreal

vreal(:,end+1) = msg.Data;
msg.Data;
vreal;