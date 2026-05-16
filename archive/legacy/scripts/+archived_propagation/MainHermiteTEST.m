% Legacy: MainHermiteTEST.m
%adding guassian parameters folders in subfolder
here = mfilename('fullpath');
[path, ~, ~] = fileparts(here);
addpath(genpath(path));

%Color of beam
mapgreen = AdvancedColormap('kgg',256,[0 70 255]/255); 

%-----------------------indices del Elegant Hermite-----------------------%
nu=20;
mu=20;

% Physical parameters [microns]
wo     = 1000;
lamb   = 0.6328;
k      = 2*pi/lamb;
zo     = k*wo^2/2;

%------------------------ sampling of vectors ----------------------------%
%First we estimate samplig in z-direction with propagation distance 
% z-direction
Dz     = 2*zo;                    % z-window (propagation distance)
Nz     = 2^6;                     % number of points in z-direction
dz     = Dz/Nz;                   % Resolution in z
z      = 0:dz:Dz;                 % z-vector z of propagation 

% waist of Gaussian until z-propagation
ws     = waistPhysicalGaussianBeam(Dz,wo,zo);

% Waist of Hermite to max z-propagation distance 
niu=max(nu,mu);
sigmaH=ws*sqrt((2*niu+1));

% y,x-direction
N      =  2^10;                    % Number of points in x,y axis
n      = -N/2+.05:N/2-1+.05;      % vector with N-points with resolution 1
Dx     = (sigmaH)*2;           % Size of window 
dx     = Dx/N;                    % Resolution
x      = n*dx;                    % Vector
y      = x;
[X,Y]  = meshgrid(x,y);

%Last we estimate vectors of frequency for Fourier Transforms
Du     = 1/dx;                    % Size of window 
du     = 1/Dx;                    % Resolution
u      = n*du;                    % Vector
[U]    = meshgrid(u);
%kx,ky vectors
kx     = 2*pi*u;
[Kx]   = meshgrid(kx);

%% 
sigmaHx=ws*sqrt((2*nu+1));
sigmaHy=ws*sqrt((2*mu+1));
HGx = hermitePhysicalGaussBeam(nu,wo,zo,x,0);
HGy = hermitePhysicalGaussBeam(mu,wo,zo,x,0);
HG=(HGy')*(HGx);
figure(1)
imagesc(x/(wo),x/(wo),abs(HG))
axis square
colormap(mapgreen)
set(gca,'YDir','normal')
axis1=gca;
set(axis1,'FontSize',28);
xlabel('$x$','Interpreter','latex','FontSize',28) 
ylabel('$y$','Interpreter','latex','FontSize',28)
hold on
% Drawing waist of Hermite
rectangle('Position',[-sigmaHx/(2*sqrt(2)*wo) -sigmaHy/(2*sqrt(2)*wo) sigmaHx/(sqrt(2)*wo) sigmaHy/(sqrt(2)*wo)],'EdgeColor','b','LineStyle','--','LineWidth',2)

% Obstruction
lx     = sigmaHx(1)/10;
radius = (lx)*(sqrt(2));
tx=0;
ty=0;
obx=double(abs(x)<=lx);
oby=double(abs(x)<=lx);
ob=(oby')*obx;
HGo=HG.*(1-ob);

%%Field with obstruction
figure(2)
imagesc(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(HGo).^2)
axis square
colormap(mapgreen)
set(gca,'YDir','normal')
axis1=gca;
set(axis1,'FontSize',28);
xlabel('$x$','Interpreter','latex','FontSize',28) 
ylabel('$y$','Interpreter','latex','FontSize',28)
hold on

% points in obstruction
no=3;
np=2^no;
th=2*pi/np;


ray = ([]);                         % Structure of rays

for jj=1:numberpoints
    %vectors of zeros for each x,y-component ray for H1 and H2
    ray(jj).rxHH11 = zeros(1,length(z));
    ray(jj).rxHH12 = zeros(1,length(z));
    ray(jj).rxHH21 = zeros(1,length(z));
    ray(jj).rxHH21 = zeros(1,length(z));
    ray(jj).ryHH11 = zeros(1,length(z));
    ray(jj).ryHH12 = zeros(1,length(z));
    ray(jj).ryHH21 = zeros(1,length(z));
    ray(jj).ryHH22 = zeros(1,length(z));
end


%puntos sobre el rectangulo dada su parametrizacion, donde empezaran los
%rayos
for jj=1:np
  
    ray(jj).rxHH11(1) = xt+(lx/2)*(abs(cos((jj)*th))*cos((jj)*th)+abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).rxHH12(1) = xt+(lx/2)*(abs(cos((jj)*th))*cos((jj)*th)+abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).rxHH21(1) = xt+(lx/2)*(abs(cos((jj)*th))*cos((jj)*th)+abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).rxHH21(1) = xt+(lx/2)*(abs(cos((jj)*th))*cos((jj)*th)+abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).ryHH11(1) = yt+(ly/2)*(abs(cos((jj)*th))*cos((jj)*th)-abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).ryHH12(1) = yt+(ly/2)*(abs(cos((jj)*th))*cos((jj)*th)-abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).ryHH21(1) = yt+(ly/2)*(abs(cos((jj)*th))*cos((jj)*th)-abs(sin((jj)*th))*sin((jj)*th));
    ray(jj).ryHH22(1) = yt+(ly/2)*(abs(cos((jj)*th))*cos((jj)*th)-abs(sin((jj)*th))*sin((jj)*th));
 
end

%%

% rays

for jj=1:numberpoints
    %vectors of zeros for each x,y-component ray for H1 and H2
    xp = pt(jj,1);
    yp = pt(jj,2);
    zp = 0;
    ray(jj).rxHH11(1) = xp;
    ray(jj).rxHH12(1) = xp;
    ray(jj).rxHH21(1) = xp;
    ray(jj).rxHH22(1) = xp;
    ray(jj).ryHH11(1) = yp;
    ray(jj).ryHH12(1) = yp;
    ray(jj).ryHH21(1) = yp;
    ray(jj).ryHH22(1) = yp;
    
    %Hankel 11
    HH11x = hankelHermite2D(1,1,nu,mu,wo,zo,x,yp,zp);
    HH11y = hankelHermite2D(1,1,nu,mu,wo,zo,xp,y,zp);
    HH11z = hankelHermite2D(1,1,nu,mu,wo,zo,xp,yp,z);
    %components for gradient
    fx    = unwrap(angle(HH11x));
    fy    = unwrap(angle(HH11y));
    fz    = unwrap(angle(HH11z));
    %Slopes
    [ray(jj).mzx11,ray(jj).mzy11,ray(jj).mxy11] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp);
    
    %Hankel 12
    HH12x = hankelHermite2D(1,2,nu,mu,wo,zo,x,yp,zp);
    HH12y = hankelHermite2D(1,2,nu,mu,wo,zo,xp,y,zp);
    HH12z = hankelHermite2D(1,2,nu,mu,wo,zo,xp,yp,z);
    %components for gradient
    fx    = unwrap(angle(HH12x));
    fy    = unwrap(angle(HH12y));
    fz    = unwrap(angle(HH12z));
    %Slopes
    [ray(jj).mzx12,ray(jj).mzy12,ray(jj).mxy12] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 
    
    %Hankel 21
    HH21x = hankelHermite2D(2,1,nu,mu,wo,zo,x,yp,zp);
    HH21y = hankelHermite2D(2,1,nu,mu,wo,zo,xp,y,zp);
    HH21z = hankelHermite2D(2,1,nu,mu,wo,zo,xp,yp,z);
    %components for gradient
    fx    = unwrap(angle(HH21x));
    fy    = unwrap(angle(HH21y));
    fz    = unwrap(angle(HH21z));
    %Slopes
    [ray(jj).mzx21,ray(jj).mzy21,ray(jj).mxy21] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 
    
    %Hankel 22
    HH22x = hankelHermite2D(2,2,nu,mu,wo,zo,x,yp,zp);
    HH22y = hankelHermite2D(2,2,nu,mu,wo,zo,xp,y,zp);
    HH22z = hankelHermite2D(2,2,nu,mu,wo,zo,xp,yp,z);
    %components for gradient
    fx    = unwrap(angle(HH22x));
    fy    = unwrap(angle(HH22y));
    fz    = unwrap(angle(HH22z));
    %Slopes
    [ray(jj).mzx22,ray(jj).mzy22,ray(jj).mxy22] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 

end

%propagador
prop=exp(-1i*pi*lamb*dz*(U.^2+(U').^2));
figure(3)
imagesc((angle(prop)))
%funcion a propagar
g=HGo;

%matrices de campos transversales para guardar los datos
gx=zeros(N,sizezp(2)); gy=zeros(N,sizezp(2));

gy(:,1)=g(N/2+1,:);
gx(:,1)=g(:,N/2+1);

for ii=2:sizezp(2) %corriendo todos los valores de zp
    
    %Transformada de fourier de campo a propagar
    G=fftshift(fft2(g));
    %obteniendo el campo propagado
    g=ifft2(fftshift(G.*prop));
    gx(:,ii)=g(:,N/2+1);
    gy(:,ii)=g(N/2+1,:);

    %%rays
    for jj=1:numberpoints
        %vectors of zeros for each x,y-component ray for H1 and H2

        ray(jj).rxHH11(ii) = ray(jj).rxHH11(ii-1) + (1/ray(jj).mzx11)*(z(ii)-z(ii-1));
        ray(jj).rxHH12(ii) = ray(jj).rxHH12(ii-1) + (1/ray(jj).mzx12)*(z(ii)-z(ii-1));
        ray(jj).rxHH21(ii) = ray(jj).rxHH21(ii-1) + (1/ray(jj).mzx21)*(z(ii)-z(ii-1));
        ray(jj).rxHH22(ii) = ray(jj).rxHH22(ii-1) + (1/ray(jj).mzx22)*(z(ii)-z(ii-1));
        ray(jj).ryHH11(ii) = ray(jj).ryHH11(ii-1) + (1/ray(jj).mzx11)*(z(ii)-z(ii-1));
        ray(jj).ryHH12(ii) = ray(jj).ryHH12(ii-1) + (1/ray(jj).mzx12)*(z(ii)-z(ii-1));
        ray(jj).ryHH21(ii) = ray(jj).ryHH21(ii-1) + (1/ray(jj).mzx21)*(z(ii)-z(ii-1));
        ray(jj).ryHH22(ii) = ray(jj).ryHH22(ii-1) + (1/ray(jj).mzx22)*(z(ii)-z(ii-1));

        %Hankel 11
        xp11  = ray(jj).rxHH11(ii);
        yp11  = ray(jj).ryHH11(ii);
        HH11x = hankelHermite2D(1,1,nu,mu,wo,zo,x,yp11,zp);
        HH11y = hankelHermite2D(1,1,nu,mu,wo,zo,xp11,y,zp);
        HH11z = hankelHermite2D(1,1,nu,mu,wo,zo,xp11,yp11,z(ii));
        %components for gradient
        fx    = unwrap(angle(HH11x));
        fy    = unwrap(angle(HH11y));
        fz    = unwrap(angle(HH11z));
        %Slopes
        [ray(jj).mzx11,ray(jj).mzy11,ray(jj).mxy11] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp);


        %Hankel 12
        xp12  = ray(jj).rxHH12(ii);
        yp12  = ray(jj).ryHH12(ii);
        HH12x = hankelHermite2D(1,2,nu,mu,wo,zo,x,   yp12,z(ii));
        HH12y = hankelHermite2D(1,2,nu,mu,wo,zo,xp12,y,   z(ii));
        HH12z = hankelHermite2D(1,2,nu,mu,wo,zo,xp12,yp12,z);
        %components for gradient
        fx    = unwrap(angle(HH12x));
        fy    = unwrap(angle(HH12y));
        fz    = unwrap(angle(HH12z));
        %Slopes
        [ray(jj).mzx12,ray(jj).mzy12,ray(jj).mxy12] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 

        %Hankel 21
        xp21  = ray(jj).rxHH21(ii);
        yp21  = ray(jj).ryHH21(ii);
        HH21x = hankelHermite2D(2,1,nu,mu,wo,zo,x,   yp21,z(ii));
        HH21y = hankelHermite2D(2,1,nu,mu,wo,zo,xp21,y,   z(ii));
        HH21z = hankelHermite2D(2,1,nu,mu,wo,zo,xp21,yp21,z);
        %components for gradient
        fx    = unwrap(angle(HH21x));
        fy    = unwrap(angle(HH21y));
        fz    = unwrap(angle(HH21z));
        %Slopes
        [ray(jj).mzx21,ray(jj).mzy21,ray(jj).mxy21] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 

        %Hankel 22
        xp22  = ray(jj).rxHH22(ii);
        yp22  = ray(jj).ryHH22(ii);
        HH22x = hankelHermite2D(2,2,nu,mu,wo,zo,x,   yp22,z(ii));
        HH22y = hankelHermite2D(2,2,nu,mu,wo,zo,xp22,y,   z(ii));
        HH22z = hankelHermite2D(2,2,nu,mu,wo,zo,xp22,yp22,z);
        %components for gradient
        fx    = unwrap(angle(HH22x));
        fy    = unwrap(angle(HH22y));
        fz    = unwrap(angle(HH22z));
        %Slopes
        [ray(jj).mzx22,ray(jj).mzy22,ray(jj).mxy22] = gradientxyz(fx,fy,fz,k,dx,dx,dz,xp,yp,zp); 

    end

    figure(10)
    fig10=figure(10);
    fig10.Name=([' z = ',num2str(z(ii))]);
    imagesc(x/(sqrt(2)*wo),x/(sqrt(2)*wo),abs(g))
    axis square
    colormap(mapgreen)
    set(gca,'YDir','normal')
    axis1=gca;
    set(axis1,'FontSize',28);
    xlabel('$x$','Interpreter','latex','FontSize',28) 
    ylabel('$y$','Interpreter','latex','FontSize',28)
    hold on
    %cuadro de la cintura en del Hermite en z
    %rectangle('Position',[-sigmaHx(ii)/(sqrt(2)*wo) -sigmaHy(ii)/(sqrt(2)*wo) 2*sigmaHx(ii)/(sqrt(2)*wo) 2*sigmaHy(ii)/(sqrt(2)*wo)],'EdgeColor','b','LineStyle','--','LineWidth',2)
    %Propagacion de las cuatro hankel en la esquina superior derecha
    for jj=1:numberpoints
       
      plot(ray(jj).rxHH11(ii)/(sqrt(2)*wo),ray(jj).ryHH11(ii)/(sqrt(2)*wo))
      plot(ray(jj).rxHH12(ii)/(sqrt(2)*wo),ray(jj).ryHH12(ii)/(sqrt(2)*wo))
      plot(ray(jj).rxHH21(ii)/(sqrt(2)*wo),ray(jj).ryHH21(ii)/(sqrt(2)*wo))
      plot(ray(jj).rxHH22(ii)/(sqrt(2)*wo),ray(jj).ryHH22(ii)/(sqrt(2)*wo))  
        
    end
    hold off
    pause(.001)
%     writeVideo(vidObj1, getframe(gca));
end  
% close(vidObj1);

