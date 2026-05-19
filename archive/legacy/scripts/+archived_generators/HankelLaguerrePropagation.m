%% Legacy: add path for classes and functions
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);  %color of beam
%% elegant normalization 
%principal 2 parameters of paraxial beams
InitialWaist     = 1;
Wavelength       = pi/2;
%dependent parameters given principal parameters for z=0 
GP               = GaussianParameters(0,InitialWaist,Wavelength);
k                = GP.k;
RayleighDistance = GP.RayleighDistance;
% parameters of Laguerre
nu               = 7;
mu               = 0;




clear all
%--------Propagacion paraxial (unidades fisicas) por espectro angular-----%

%-----------------------indices del Laguerre Gauss------------------------%
nu=12;19;mu=0;
% Parametros fisicos [micras]
wo=179*5/2;100;%179*2;
lamb=0.6328;
k=2*pi/lamb;
% Probando los c's esferoidales
nu=7;
lamb=0.6328;
k=2*pi/lamb;
csph=12000;
wo=sqrt(2*(sqrt(csph^2+1)-1))/k;
zl=k*wo^2/2;
% El zls(elegante) es zl/2
%------------------------muestreo de vectores-----------------------------%
N=2^9;                     % N�mero de puntos para x, y
n=-N/2+.05:N/2-1+.05;     % Vector indicial igualmente espaciado

% Muestreo de vector z
Dz=zl/2;%1.105*zl; % Tama�o de la ventana en z (distancia a la cual propagar)
Nz=2^6;%2^9;          % N�mero de puntos en z
dz=Dz/Nz;        % Resolucion en z
z=0:dz:Dz;       % Vector z de propagacion

% Cintura de gaussiana a la distancia del tama�o de la ventana en z
ws=wo*sqrt(1+Dz.^2/zl^2);
% Cintura de Laguerre a la distancia del tama�o de la ventana en z
sigmaL=ws*sqrt((2*nu+mu+1));

% Muestreo de los vectores espaciales x,y
% Calculamos el tama�o de ventana en x,y en terminos de la cintura a la
% distancia z que se propaga (esto para que no se salga de la ventana)
Dx=(2*sigmaL)*1.37;  % Tama�o de la ventana
Dx=3*(2*sigmaL)*1.37;  % Tama�o de la ventana
dx=Dx/N;            % Resoluci�n
x=n*dx;             % Vector x (plano de campo a propapar)
[X]=meshgrid(x);
% Muestreo del vector de frecuencia
Du=1/dx;        % Tama�o de la ventana de Fourier
du=1/Dx;        % Resoluci�n
u=n*du;         % Vector
[U]=meshgrid(u);
% Vectores kx,ky
kx=2*pi*u;
[Kx]=meshgrid(kx); 
% Coordenadas polares para el Laguerre
[TH,R]=cart2pol(X,X');

%-----------------Laguerre Gauss sin ostrucci�n en z=0--------------------%

% Las dos soluciones del Laguerre Gauss
Ln=exp(1i*mu*TH).*laguerregz(nu,mu,wo,zl,R,0); 
% Ln=exp(i*mu*TH).*LaguerreG(nu,abs(mu),2*R.^2/wo^2);
Xn=exp(1i*mu*TH).*xlaguerregz(nu,mu,wo,zl,R,0);

% funciones Hankel
H1=Ln+1i*Xn;
H2=Ln-1i*Xn;

% Funci�n a propagar (Recuerde normalizar respecto al m�ximo de la funci�n
% en cuesti�n)
g=Ln;
% Graficando Laguerre
figure(1)
pcolor(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g).^2)
axis square
shading flat
colormap(mapgreen)
xlabel('x') 
ylabel('y') 
pxy=max(max(g));

%---------------Funcion a propagar con obstrucci�n en z=0-----------------%
sigmaLo=2*wo*sqrt((2*nu+mu+1));   %cintura de Laguerre en z=0
lo=sigmaLo/7;%sigmaLo/4;%sigmaLo/8;                   %tama�o de la obstrucci�n (radio de la obstruccion)
%traslado
xt=sigmaLo/15;%sigmaLo/6;%sigmaLo/15;%.15*sigmaLo;sigmaLo/2.5;
 yt=0;   %xt=0;
[~,ro]=cart2pol(X-xt,X'-yt);    %aplicando la traslaci�n a coordendas xy
obo=double(ro<=lo);             %creando la obstrucci�n   
clear ro                        %limpiando coordenadas trasladadas
% Funci�n a propagar con obstrucci�n
g=g.*(1-obo);

figure(2)
pcolor(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g).^2)
axis square
shading flat
colormap(mapgreen)
axis1=gca;
set(axis1,'FontSize',13);
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('$y$','Interpreter','latex','FontSize',18)
caxis([0 1])

%---------------calculo de los rayos en el punto (rx,z=0)-----------------%
%--------construccion de rayos por ciclo for
pn=20;%30;        %numero de puntos que queremos muestrear alrededor del circulo

%structures para rayos ahi guardaremos la informacion para cada rayo
rayo=([]);
for jj=1:pn
    %matrices de ceros para colocar las coordenadas x,y de las Hankel
    rayo(jj).xH1=zeros(1,length(z));
    rayo(jj).xH2=zeros(1,length(z));
    rayo(jj).yH1=zeros(1,length(z));
    rayo(jj).yH2=zeros(1,length(z));
end

%para el gradiente en z=0 las funciones gradiente z=cte no cambian para
%cualquier rayo por lo que las calculamos antes del ciclo for

H1r=laguerregz(nu,mu,wo,zl,x,z(1))+1i*xlaguerregz(nu,mu,wo,zl,x,z(1));
H2r=laguerregz(nu,mu,wo,zl,x,z(1))-1i*xlaguerregz(nu,mu,wo,zl,x,z(1));

for jj=1:pn
    %en que punto de la circunferencia estamos en x,y
    xi=xt+lo*cos(jj*(2*pi)/(pn)); yi=yt+lo*sin(jj*(2*pi)/(pn));
    %guardando los puntos de la circunferencia asociado a cada rayo
    rayo(jj).xc=xi; rayo(jj).yc=yi;
    %calculando el radio al origen de cada punto
    ri=sqrt((xi)^2+(yi)^2);    
    %calculo de las pendientes en el punto (r,z)  Hankel 1
    % para r=cte;
    H1z=laguerregz(nu,mu,wo,zl,ri,z)+1i*xlaguerregz(nu,mu,wo,zl,ri,z);
    % pendiente para el frente de onda para cada punto y guardandola
    rayo(jj).mH1=gradientrz(unwrap(angle(H1r)),unwrap(angle(H1z)),k,dx,dz,ri,z(1));
    %calculo de las pendientes en el punto (r,z)  Hankel 2
    H2z=laguerregz(nu,mu,wo,zl,ri,z)-1i*xlaguerregz(nu,mu,wo,zl,ri,z);
    rayo(jj).mH2=gradientrz(unwrap(angle(H2r)),unwrap(angle(H2z)),k,dx,dz,ri,z(1)); 
end

% Graficando los puntos que se propagaran
figure(3)
pcolor(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g).^2)
axis square
shading flat
colormap(mapgreen)
axis1=gca;
set(axis1,'FontSize',13);
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('$y$','Interpreter','latex','FontSize',18)
hold on
for jj=1:pn
    plot(rayo(jj).xc/(sqrt(2)*wo),rayo(jj).yc/(sqrt(2)*wo),'.','MarkerSize',10,'LineWidth',2,'color','r')
end
hold off

% Condiciones iniciales para el loop, las dos Hankel parten del mismo r
% rH1=zeros(1,pn);
for jj=1:pn
    %guardando los datos de los rayos de sus componentes x,y
    rayo(jj).xH1(1)=rayo(jj).xc;
    rayo(jj).xH2(1)=rayo(jj).xc;
    rayo(jj).yH1(1)=rayo(jj).yc;
    rayo(jj).yH2(1)=rayo(jj).yc;
    %calculando el radio para cada punto
    rayo(jj).rH1=sqrt((rayo(jj).xH1(1))^2+(rayo(jj).yH1(1))^2);
    rayo(jj).rH2=rayo(jj).rH1;    %los radios debidos a Hankel 1 y 2 parten del mismo punto
    %para pasar de coordenadas polares a cartesianas requerimos el angulo
    rayo(jj).th=atan2(rayo(jj).yc,rayo(jj).xc); %atan2 da el signo correcto 
end
%-----------------------------fin de rayos--------------------------------%

%-------------------------Propagagaci�n f�sica----------------------------%
% Propagador paraxial
prop=exp(-1i*lamb*dz*(Kx.^2+(Kx').^2)/(4*pi));
% prop=exp(1i*lamb*dz*(Kx.^2+(Kx').^2)/(2*k));
% prop=exp(1i*dz*sqrt(k^2-Kx.^2-(Kx').^2));
figure(5)
imagesc(u,u,(angle(prop)))
title('Propagador')
% Matrices de campos transversales para guardar los datos
gx=zeros(N,length(z)); gy=zeros(N,length(z));
% Guardando campo transversal en z=0
gx(:,1)=g(N/2+1,:);
gy(:,1)=g(:,N/2+1);

% % para generar video
% vidObj1 = VideoWriter('LGo.avi');
% vidObj1.Quality = 100;
% vidObj1.FrameRate =30;
% open(vidObj1);

for ii=2:length(z) %corriendo todos los valores de sp
    %graficando campo en z(ii-1)
    pxyz=g(1,1);
    g(1,1)=pxy;
    fig=figure(6);
    set(gca,'un','n','pos',[0,0,1,1])
    imagesc(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g).^.2)
    axis off
    fig.MenuBar='none';
    fig.Position=[1,1,1354.0,733];
    colormap(mapgreen)
    set(gca,'YDir','normal')
    axis square
    hold on
    caxis([0 1])
    %puntos propagados debido a Hankel 1 y 2
    for jj=1:pn
        plot(rayo(jj).xH1(ii-1)/(sqrt(2)*wo),rayo(jj).yH1(ii-1)/(sqrt(2)*wo),'.','MarkerSize',10,'LineWidth',2,'color','r')
        plot(rayo(jj).xH2(ii-1)/(sqrt(2)*wo),rayo(jj).yH2(ii-1)/(sqrt(2)*wo),'.','MarkerSize',10,'LineWidth',2,'color','y')
    end
%     text(-5,5,[' z = ',num2str(z(ii-1))],'Color','y','FontSize',16)
    text(-6,6,[' z = ',num2str(2*z(ii-1)/zl)],'Color','y','FontSize',16)
    hold off
    g(1,1)=pxyz;
%     writeVideo(vidObj1, getframe(gca));
    %-------------------------Calculo de Rayos----------------------------%   
    % Dado z encontramos z+dz y la posici�n de r que le corresponde a este
    % punto z+dz con la pendiente del frente de onda que hay entre estos 
    % dos puntos
    H1r=laguerregz(nu,mu,wo,zl,x,z(ii))+1i*xlaguerregz(nu,mu,wo,zl,x,z(ii));
    for jj=1:pn
        %incrementamos en la recta de r 
        rayo(jj).rH1=((1/rayo(jj).mH1)*(z(ii)-z(ii-1))+rayo(jj).rH1);
        % Reescribiendo los valores nuevos de x,y dado este radio y
        % guardandolos en los rayos
        rayo(jj).xH1(ii)=rayo(jj).rH1*cos(rayo(jj).th);
        rayo(jj).yH1(ii)=rayo(jj).rH1*sin(rayo(jj).th);
        %-----------Calculando las pendientes del siguiente paso----------%
        %calculo de la pendiente en (r,z(ii)) de Hankel 1
        % para r=cte;
        H1z=laguerregz(nu,mu,wo,zl,rayo(jj).rH1,z)+1i*xlaguerregz(nu,mu,wo,zl,rayo(jj).rH1,z);
        rayo(jj).mH1=gradientrz(unwrap(angle(H1r)),unwrap(angle(H1z)),k,dx,dz,rayo(jj).rH1,z(ii));
        %calculo de la pendiente en (r,z(ii)) de Hankel 2
        %Aqui el rayo que entra debido a Hankel 1 despues se rige por Hankel 2
        %cuando pasa por el origen, para ello calculamos el angulo con
        %atan2 para saber en que cuadrante estamos y si as� paso por el
        %origen
        rayo(jj).rH2=((1/rayo(jj).mH2)*(z(ii)-z(ii-1))+rayo(jj).rH2);
        rayo(jj).xH2(ii)=rayo(jj).rH2*cos(rayo(jj).th);
        rayo(jj).yH2(ii)=rayo(jj).rH2*sin(rayo(jj).th);
        if  rayo(jj).rH2<0
            H2r=laguerregz(nu,mu,wo,zl,x,z(ii))+1i*xlaguerregz(nu,mu,wo,zl,x,z(ii));
            H2z=laguerregz(nu,mu,wo,zl,rayo(jj).rH2,z)+1i*xlaguerregz(nu,mu,wo,zl,rayo(jj).rH2,z);
            rayo(jj).mH2=gradientrz(unwrap(angle(H2r)),unwrap(angle(H2z)),k,dx,dz,rayo(jj).rH2,z(ii));
        else
            H2r=laguerregz(nu,mu,wo,zl,x,z(ii))-1i*xlaguerregz(nu,mu,wo,zl,x,z(ii));
            H2z=laguerregz(nu,mu,wo,zl,rayo(jj).rH2,z)-1i*xlaguerregz(nu,mu,wo,zl,rayo(jj).rH2,z);
            rayo(jj).mH2=gradientrz(unwrap(angle(H2r)),unwrap(angle(H2z)),k,dx,dz,rayo(jj).rH2,z(ii));
        end
    end
    %-----------------------Fin de Calculo de Rayos-----------------------%   
    %propagacion del campo
    G=fftshift(fft2(g));
    %obteniendo el campo propagado
    g=ifft2(fftshift(G.*prop));
    %guardando campo transversal
    gx(:,ii)=g(N/2+1,:);
    gy(:,ii)=g(:,N/2+1);
    pause(.1)
end

%graficando el campo en z
pxyz=g(1,1);
g(1,1)=pxy;
fig=figure(6);
set(gca,'un','n','pos',[0,0,1,1])
imagesc(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g))
axis off
fig.MenuBar='none';
fig.Position=[1,1,1354.0,733];
colormap(mapgreen)
set(gca,'YDir','normal')
axis square
hold on
 %puntos propagados debido a Hankel 1 y 2
    for jj=1:pn
        plot(rayo(jj).xH1(ii)/(sqrt(2)*wo),rayo(jj).yH1(ii)/(sqrt(2)*wo),'.','MarkerSize',10,'LineWidth',2,'color','r')
        plot(rayo(jj).xH2(ii)/(sqrt(2)*wo),rayo(jj).yH2(ii)/(sqrt(2)*wo),'.','MarkerSize',10,'LineWidth',2,'color','y')
    end
    text(-5,5,[' z = ',num2str(2*Dz/zl)],'Color','y','FontSize',16)
hold off
g(1,1)=pxyz;

% writeVideo(vidObj1, getframe(gca));
% close(vidObj1);

figure(1)
% set(gca,'un','n','pos',[0,0,1,1])
% pxy=gy(1,1); gy(1,1)=1; % Para H2 (Recuerde normalizar respecto al m�ximo de la funci�n en cuesti�n)
pcolor(z/(zl/2),x/(sqrt(2)*wo),abs(gx).^1)
shading interp
colormap(mapgreen)
axis1=gca;
set(axis1,'FontSize',38);
xlabel('$z$','Interpreter','latex','FontSize',50) % x-axis label
% ylabel('$x$','Interpreter','latex','FontSize',18) % y-axis label
xticks([0 1 2.4 4 6 8])
yticks([-10 -5 0 5 10])
ylim([-4 4])
% caxis([0 max(max(abs(gx).^2))])
% pbaspect([2.1 1 2])
% pbaspect([5 2 2])


