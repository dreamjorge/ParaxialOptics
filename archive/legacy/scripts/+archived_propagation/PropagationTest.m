%% Legacy: add path for classes and functions
addpath(fullfile('ParaxialBeams'))
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

%% vector of propagation in z
N      = 2^8;                    % Number of points in z-direction
n      = (0:N-1);                 % Vector with resolution of 1, with n-points
Dz     = 2;                       % Size of window 
dz     = Dz/N;                    % Resolution
z      = n*dz;                    % Vector

%% vectors in x,y plane
%Estimate waist of Laguerre in max distance of propagation
MaxLaguerreWaist = LaguerreBeam.waistLaguerre(z(end),InitialWaist,RayleighDistance,nu,mu);

N      =  2^10;                       % Number of points in x,y axis
n      = (-N/2:N/2-1);               % vector with N-points with resolution 1
Dx     = 2.2*MaxLaguerreWaist;         % Size of window in terms of max size of waist
dx     = Dx/N;                       % Resolution
x      = n*dx;                       % Vector
y      = x;
[X,Y]  = meshgrid(x,y);
%[TH,R] = cart2pol(X,Y);
% u,v vector for spectrum Fourier
Du     = 1/dx;                    % Size of window 
du     = 1/Dx;                    % Resolution
u      = n*du;                    % Vector
[U]    = meshgrid(u);
%kx,ky vectors
kx     = 2*pi*u;
[Kx]   = meshgrid(kx);

%% propagator

prop   = exp(1i*dz*(Kx.^2+(Kx').^2)/(2*k));
%prop=exp(-1i*k*dz*sqrt(1-(Wavelength^2)*(U.^2+(U').^2)));
figure(2)
imagesc(u,u,(angle(prop)))
title('Propagator')
axis square
%% Laguerre in z = 0

LG = LaguerreBeam(X,Y,0,InitialWaist,Wavelength,nu,mu);
g  = LG.OpticalField;

%amplitudefactor = max(LG.OpticalField(:));
%amplitudefactor = inf;
% plot this field
figure(3)
imagesc(x,y,abs(g).^2)
%caxis([0 amplitudefactor])
hold on
%plot circle of waist
r     = LG.LaguerreWaist;
th    = 0:pi/50:2*pi;
xt    = 0;
yt    = 0;
xunit = r * cos(th) + xt;
yunit = r * sin(th) + yt;
plot(xunit, yunit,  'LineWidth',2,'Color','r');
hold off
axis square


%%

LaguerreWaist = LaguerreBeam.waistLaguerre(z,InitialWaist,RayleighDistance,nu,mu);
for ii = 2:length(z) % propagation with respect to z
  
    %% field before propagation
    figure(4)
    subplot(2,2,1)
    imagesc(x,y,abs(g).^2)
    title('Amplitude Angular Spectrum Method')
    %caxis([0 amplitudefactor])
    hold on
    %plot circle of waist
    r     = LaguerreWaist(ii)/sqrt(2);
    th    = 0:pi/50:2*pi;
    xt    = 0;
    yt    = 0;
    xunit = r * cos(th) + xt;
    yunit = r * sin(th) + yt;
    plot(xunit, yunit,  'LineWidth',2,'Color','r');
    hold off
    axis square
    
    subplot(2,2,2)
    gp = LaguerreBeam(X,Y,z(ii-1),InitialWaist,Wavelength,nu,mu);
    imagesc(x,y,abs(gp.OpticalField).^2)
    title( 'Amplitude Analytic Function')
    %caxis([0 amplitudefactor])
    hold on
    plot(xunit, yunit,  'LineWidth',2,'Color','r');
    hold off
    axis square
    
    subplot(2,2,3)
    imagesc((angle(g)))
    title('Phase of Propagated Field')
    axis square
    
    subplot(2,2,4)
    imagesc((angle(gp.OpticalField)))
    title('Phase of Analytic Field')
    axis square
    suptitle(['z = ', num2str(z(ii))])
    drawnow
    
    % propagation
    % it's needed correction in phase of FFT
    G = fftshift(fft2(ifftshift(g)));...*exp(-1j.*(u(1)).*(Kx)).*exp(-1j.*(u(1)).*(Kx'));
    %obtain new propagated field
    g = fftshift(ifft2(ifftshift(G.*prop)));...*exp(-1j.*(u(1)).*(X))*exp(-1j.*(u(1)).*(X'));
  
    pause(.5)
end
