%% Legacy:                      Main Hermite
% Ugalde-Ontiveros J.A. 
% This script generate plots 1D of Hermite
%% add path for classes and functions
clear all
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))
addpath(fullfile('ParaxialBeams', 'Addons', 'panel-2.14'))
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);  %color of beam
GenerateVideo = 'NO';
%% indices of Hermite Gaussian Beams 
nu = 12;
mu = 11;

%% Physical parameters [microns]
InitialWaist = 100;
Wavelength   = 0.6328;

%% Build parameters of Hermite in z=0
HermiteParametersz0 = HermiteParameters(0,InitialWaist,Wavelength,nu,mu);
%obtain parameters of beam
k                   = HermiteParametersz0.k;
RayleighDistance    = HermiteParametersz0.RayleighDistance;


%% sampling of vectors 
%First, we estimate samplig in z-direction with propagation distance 
% z-direction
Dz    = RayleighDistance;     % z-window (propagation distance)
Nz    = 2^7;                  % number of points in z-direction
dz    = Dz/Nz;                % Resolution in z
nz    = 0:Nz-1;               % vector with N-points with resolution 1
z     = nz*dz;                % z-vector z of propagation 

% waist of Hermite Gauss Beam until z-propagation
MaxHermiteWaist = HermiteParameters.getWaist(z(end),InitialWaist,RayleighDistance,nu,mu);

%Second, we estimate sampling in x,y-direction in terms of waist of Guassian
%Hermite Beam

% y,x-direction
Nx    =  2^10;                % Number of points in x,y axis
n     = -Nx/2:Nx/2-1;         % vector with N-points with resolution 1
Dx    = 1.1*MaxHermiteWaist;  % Size of window 
dx    = Dx/Nx;                % Resolution
x     = n*dx;                 % Vector
y     = x;
[X,Y] = meshgrid(x,y);


%% Hankel 1D

HermiteInitialWaistX  = HermiteParametersz0.HermiteWaistX;
HermiteInitialWaistY  = HermiteParametersz0.HermiteWaistY;
HermiteInitialWaist   = HermiteParametersz0.HermiteWaist;
PhiPhase              = HermiteParametersz0.PhiPhase;
% for x-direction
InitialWaist          = HermiteParametersz0.InitialWaist;
[Hx,NHx]              = ...
HermiteParameters.getHermiteSolutions(nu,(sqrt(2)./InitialWaist).*x);

GaussX                = GaussianBeam(x,HermiteParametersz0).OpticalField;
Hx                    = Hx.*GaussX.*exp(1i*PhiPhase);
NHx                   = NHx.*GaussX.*exp(1i*PhiPhase);

SupGaussX             = exp(-(x./(HermiteInitialWaistX/2)).^(50)); 

NHx                   = NHx.*SupGaussX;

H1x                   = Hx+1j*NHx;
H2x                   = Hx-1j*NHx;

% for y-direction
[Hy,NHy]  = ...
HermiteParameters.getHermiteSolutions(mu,(sqrt(2)./InitialWaist).*x);

% Hermite Gauss 1D and Hankel Hermite Gauss 
PhiPhase  = HermiteParametersz0.PhiPhase;
GaussX    = GaussianBeam(x,HermiteParametersz0).OpticalField;
Hy        = Hy .*GaussX.*exp(1i*PhiPhase);
NHy       = NHy.*GaussX.*exp(1i*PhiPhase);

SupGaussY = exp(-(y./(HermiteInitialWaistY/2)).^50);
NHy       = NHy.*SupGaussY;
H1y       = Hy+1i*NHy;
H2y       = Hy-1i*NHy;

%% Plot First Solution
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(Hy).^2,'LineWidth',1.6)
xlim([-5 5])
ylim([0 .0003])
xlabel('$y/w_o$','Interpreter','latex','FontSize',14)
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('HermiteGaussY','-png','-transparent')
 
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(Hx).^2,'LineWidth',1.6)
xlim([-5 5])
ylim([0 .0003])
xlabel('$x/w_o$','Interpreter','latex','FontSize',14)
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('HermiteGaussX','-png','-transparent')

%% Plot Second Solution
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(NHy).^2,'LineWidth',1.6)
xlim([-5 5])
ylim([0 .0003])
xlabel('$y/w_o$','Interpreter','latex','FontSize',14)
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('NHermiteGaussY','-png','-transparent')
 
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(NHx).^2,'LineWidth',1.6)
xlim([-5 5])
ylim([0 .0003])
xlabel('$x/w_o$','Interpreter','latex','FontSize',14)
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('NHermiteGaussX','-png','-transparent')

%%
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(Hy).^2,'LineWidth',2.2)
hold on
plot(x/InitialWaist,abs(NHy).^2,'--','LineWidth',2.2)
colorp = [0,200,100]/256;
plot(x/InitialWaist,abs(H1y).^2,'-.','LineWidth',2.2,'color',colorp)
hold off
xlim([-5 5])
ylim([0 .0003])
xlabel('$y$','Interpreter','latex','FontSize',14)
leg1=legend('$\left|\psi_{n,m}^{(1,1)}\right|^2$','$\left|Re\left(\psi_{n,m}^{(1,1)}\right)\right|^2$','$\left|Im\left(\psi_{n,m}^{(1,1)}\right)\right|^2$','interpreter','latex','FontSize',14,'NumColumns',3);
leg1.Position = [0.5693, 0.8203, 0.3337, 0.0967];
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('hankelHermiteGaussSolutionsY','-png','-transparent')
 

%%
close(figure(1))
fig1 = figure(1);
fig1.Position = [716, 444, 1235, 389];
plot(x/InitialWaist,abs(Hx).^2,'LineWidth',2.2)
hold on
plot(x/InitialWaist,abs(NHx).^2,'--','LineWidth',2.2)
colorp = [0,200,100]/256;
plot(x/InitialWaist,abs(H1x).^2,'-.','LineWidth',2.2,'color',colorp)
hold off
xlim([-5 5])
ylim([0 .0003])
xlabel('$x$','Interpreter','latex','FontSize',14)
leg1=legend('$\left|\psi_{n,m}^{(1,1)}\right|^2$','$\left|Re\left(\psi_{n,m}^{(1,1)}\right)\right|^2$','$\left|Im\left(\psi_{n,m}^{(1,1)}\right)\right|^2$','interpreter','latex','FontSize',14,'NumColumns',3);
leg1.Position = [0.5693, 0.8203, 0.3337, 0.0967];
% title(['Solutions of Hermite Equation with integer number equal to ',num2str(nu)])
% legend off
 set(gca,'FontSize',18);
export_fig('hankelHermiteGaussSolutionsX','-png','-transparent')

