%% Legacy:                      Main Analytic Hermite
% Ugalde-Ontiveros J.A. 
%% add path for classes and functions
clear all
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))
addpath(fullfile('ParaxialBeams', 'Addons', 'panel-2.14'))
addpath(fullfile('ParaxialBeams', 'Addons', 'Plots_Functions'))

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


%% Given Initial Waist and RayleighDistance we cand do Normalizations /Scale Factors
scaleX = 1/(InitialWaist);
scaleY = scaleX;
scaleZ = 1/(RayleighDistance);

labelX = '$x/w_o$';
labelY = '$x/w_o$';
labelZ = '$z/z_R$';

%% vectors for generate figures
figureSize   = [538, 376, 884, 568];
largeAspect  = [1.0000, 0.4113, 0.4113];
NormalAspect = [1, 1, 1]; 
%% sampling of vectors 
%First, we estimate samplig in z-direction with propagation distance 
% z-direction
Dz    = RayleighDistance;  % z-window (propagation distance)
Nz    = 2^7+1;             % number of points in z-direction
dz    = Dz/Nz;             % Resolution in z
nz    = 0:Nz;              % vector with N-points with resolution 1
z     = nz*dz;             % z-vector z of propagation 

% waist of Hermite Gauss Beam until z-propagation
MaxHermiteWaist = HermiteParameters.getWaist(z(end),InitialWaist,RayleighDistance,nu,mu);

%Second, we estimate sampling in x,y-direction in terms of waist of Guassian
%Hermite Beam

% y,x-direction
Nx    =  2^10;                 % Number of points in x,y axis
n     = -Nx/2:Nx/2-1;          % vector with N-points with resolution 1
Dx    =  1.1*MaxHermiteWaist;  % Size of window 
dx    =  Dx/Nx;                % Resolution
x     =  n*dx;                 % Vector
y     =  x;
[X,Y] =  meshgrid(x,y);

%Last, we estimate vectors of frequency for Fourier Transforms
Du    = 1/dx;                 % Size of window 
du    = 1/Dx;                 % Resolution
u     = n*du;                 % Vector
%kx,ky vectors
kx    = 2*pi*u;
[Kx]  = meshgrid(kx);
%diferential dr
dr    = [dx,dx,dz];

%% Generate and Save Plots of Hermite Gauss in zi

% copy of parameters
HPzi             = copy(HermiteParametersz0);
% distances for plot
zi               = [0, RayleighDistance/4 , RayleighDistance/3 , RayleighDistance/2, ...
                      2*RayleighDistance/3, 3*RayleighDistance/4, RayleighDistance  ];
textdis          = {'0','zR4','zR3','zR2','2zR3','3zR4','zR'};

for jj = 1 : numel(zi)
  
  HPzi.zCoordinate = zi(jj);
  % Build new Optical Field
  HGBzi            = eHermiteBeam(X,Y,HPzi);
  % Optic Field
  g                = HGBzi.OpticalFieldHermite;
  close(figure(3))
  fig3 = figure(3);
  fig3.Position = figureSize;
  plotOpticalField(scaleX.*x,scaleY.*x,abs(g).^2,mapgreen,labelX,labelY);
  axis square
  % set(gca,'FontSize',18);
  export_fig(['eHermite',textdis{jj}],'-png','-transparent')
%   h = plotWaistHermite2D(HPzi,scaleX,scaleY,'r');
%   h.LineStyle = '-.';
%   export_fig(['Hermite',textdis{jj},'Waist'],'-png','-transparent')
  
end
%% Generate transversal field 

[Zm,Xm] = meshgrid(z,x);
HPzi.zCoordinate = Zm;
HGB   = eHermiteBeam(0,Xm, HPzi);

close(figure(1))
fig1 = figure(1);
plotOpticalField(scaleZ.*z,scaleX.*x,abs(HGB.OpticalFieldHermite).^2,...
                 mapgreen,labelZ,labelX);
fig1.Position = figureSize;
pbaspect(largeAspect)

HPz = copy(HermiteParametersz0);
HPz.zCoordinate = z;

export_fig('eHermiteLateralX','-png','-transparent')
% hold on
% plot(scaleZ*z, scaleX*HPz.HermiteWaistX/2,'-.','Linewidth',2,'Color','r')
% plot(scaleZ*z,-scaleX*HPz.HermiteWaistX/2,'-.','Linewidth',2,'Color','r')
% hold off
% export_fig('HermiteLateralXWaist','-png','-transparent')