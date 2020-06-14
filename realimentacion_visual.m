function [num_tum,centroides,area, im_et]= realimentacion_visual(im,fig,quit,im_etquit,num_tum_quit)
% Esta funcion realiza el procesamiento de la imagen capturada por la
% camara con la finalidad de obtener la posicion del tumor respecto de la
% imagen en pixeles. Como no se dispone de la camara a tiempo real, se ha
% simulado con imagenes capturadas a partir de ella.
% Recibe como parametros de entrada la imagen, y tres variables: quit,
% ime_raquit y num_tum_quit que permiten eliminar el tumor extraido en la
% fase anterior segun los criterios de planificacion de trayectoria. 
switch nargin 
    case 1
        fig=0;
        quit=0;
    case 2
        quit=0;
end
% --------PREPROCESAMIENTO-------:
% Se mejora el contraste de la imagen de entrada:
im_pre=imadjust(im, [0 0.1 0.2;1 1 1],[0 0 0; 1 1 1],[2 2 2]);  
% Para visualizar el efecto descomentar lo siguiente:
% figure
% subplot(1,2,1)
% imshow(im);grid on; title('a) Imagen original')
% subplot(1,2,2)
% imshow(im_pre);grid on; title('b) Imagen original contrastada')

% --------SEGMENTACION-------:
% Primero se descompone la imagen contrastada en cada una de sus
% componentes HSV:
rgbImage = im_pre;
hsvImage = rgb2hsv(rgbImage);
hImage = hsvImage(:, :, 1);
sImage = hsvImage(:, :, 2);
vImage = hsvImage(:, :, 3);
% Para visualizar el efecto descomentar lo siguiente:
% figure;
% subplot(3,2,1);
% imshow(hImage);grid on;title('a) Matiz(H)');
% subplot(3,2,2);
% hHist = histogram(hImage);grid on;title('b) Histograma del Matiz(H)');
% subplot(3,2,3);
% imshow(sImage);grid on;title('c) Saturacion(S)');
% subplot(3,2,4);
% sHist = histogram(sImage);grid on;title('d) Histograma de la Saturacion(S)');
% subplot(3,2,5);
% imshow(vImage);grid on; title('e) Valor(V)');
% subplot(3,2,6);
% vHist = histogram(vImage);grid on;title('f) Histograma del Valor(V)');

% A continuación, se procede a la umbralizacion:
imh  = hImage>0.25 & hImage<0.4;
ims = sImage>0.4; 
im_umbr = imh.*ims; 
% Para visualizar el efecto descomentar lo siguiente:
% figure
% subplot(2,2,1)
% imshow(imh);grid on;title('a) Umbral Matiz [0.25,0.4]')
% subplot(2,2,2)
% imshow(ims);grid on;title('b) Umbral Saturacion > 0.4')
% subplot (2,2,3)
% imshow(im_umbr);grid on;title('c) imagen_a.* imagen_b')
% subplot(2,2,4)
% imt=uint8(im_umbr).*im(:,:,:);
% imshow(imt);grid on; title('d) Superposicion con la imagen original')

% --------OPERACIONES MORFOLOGICAS-------:
% Para eliminar los pixeles de fondo se aplica la operacion de apertura:
im_er=bwmorph(im_umbr,'erode',2);     
im_d=bwmorph(im_er,'dilate',3.5);
% Para visualizar el efecto descomentar lo siguiente:
% figure
% subplot(1,2,1)
% imshow(im_d); grid on; title('a) Proceso de Apertura')
% subplot(1,2,2)
% imshow(uint8(im_d).*im(:,:,:)); grid on; title('b) Superposici�n con la imagen original')
if quit==1
    im_neg=1-(im_etquit==num_tum_quit);
    im_d=im_d.*im_neg;
end
% --------ETIQUETADO-------:
im_et=bwlabel(im_d);
% Para visualizar el efecto descomentar lo siguiente:
% figure
% imshow(label2rgb(im_et==1+1)), title(' Etiquetado')
% imetrgb=label2rgb(im_et);
% imshow(imetrgb)
% mult=uint8(im_d).*imetrgb;
% imshow(mult), title('Etiquetado')
num_tum=max(max(im_et));
% --------DESCRIPTORES DE LA REGION-------:
% Para cada tumor detectado, se calcula el area y su centroide:
centroides=[];
area=[];
    for k=1:num_tum
        ob=(im_et==k);
        area(k)=bwarea(ob);
        s = regionprops(ob,'centroid');
        centroides(:,k) = cat(1,s.Centroid);
%       figure
%       imshow(im)
%       hold on
%       plot(centroides(1,k),centroides(2,k),'*r');
%       text(centroides(1,k)+5,centroides(2,k), sprintf('%d',k),'Fontsize',10,'Color', 'red' );
%       text(10,10+20*k, sprintf('Area %d: %10.3f',k,area(k)), 'Fontsize',10,'Color', 'white');
    end

    if fig~=0
       figure(fig);
       imshow(im);
       hold on;
       plot(centroides(1,:),centroides(2,:),'*r');
       plot([1 70],[1 1],'r','LineWidth',2);
       plot([1 1],[1 70],'g','LineWidth',2);
         for i=1:num_tum
         text(centroides(1,i)+5,centroides(2,i), sprintf('%d',i),'Fontsize',10,'Color', 'red' );
         text(10,10+50*i, sprintf('Area %d: %10.3f',i,area(i)), 'Fontsize',10,'Color', 'black');
         end
       hold off;
    end 

end



