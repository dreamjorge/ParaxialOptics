%% Legacy:                      Main Analytic Hermite
% Ugalde-Ontiveros J.A. 
%% add path for classes and functions
clear all
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))
addpath(fullfile('ParaxialBeams', 'Addons', 'panel-2.14'))
addpath(fullfile('ParaxialBeams', 'Addons', 'Plots_Functions'))

mapgreen = AdvancedColormap('kg',256,[0 255]/255);  %color of beam
GenerateVideo = 'NO';

%% Physical parameters [microns]
InitialWaist = 100;
Wavelength   = 0.6328;


%% Build parameters of Hermite in z=0
GaussianParametersZ0 = GaussianParameters(0,InitialWaist,Wavelength);
%obtain parameters of beam
k                   = GaussianParametersZ0.k;
RayleighDistance    = GaussianParametersZ0.RayleighDistance;


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

% waist of Gauss Beam until z-propagation
MaxWaist = GaussianParameters.getWaist(z(end),InitialWaist,RayleighDistance);

%Second, we estimate sampling in x,y-direction in terms of waist of Guassian
%Hermite Beam

% y,x-direction
Nx    =  2^8;                  % Number of points in x,y axis
n     = -Nx/2:Nx/2-1;          % vector with N-points with resolution 1
Dx    =  2.5*MaxWaist;           % Size of window 
dx    =  Dx/Nx;                % Resolution
x     =  n*dx;                 % Vector
y     =  x;
[X,Y] =  meshgrid(x,y);
[~,R] =  cart2pol(X,Y);
%Last, we estimate vectors of frequency for Fourier Transforms
Du    = 1/dx;                 % Size of window 
du    = 1/Dx;                 % Resolution
u     = n*du;                 % Vector
%kx,ky vectors
kx    = 2*pi*u;
[Kx]  = meshgrid(kx);
%diferential dr
dr    = [dx,dx,dz];


%% Generate Gaussian Beam at z = 0

GBzo = GaussianBeam(R,GaussianParametersZ0);
GB1D = GaussianBeam(x,GaussianParametersZ0);

sigmaG = GaussianParametersZ0.Waist/sqrt(2);
WaistG = GaussianParametersZ0.Waist;
fig = figure(1);
fig.Position = [700 316 1094 420];

subplot(1,2,1)
imagesc(x,x,abs(GBzo.OpticalField).^2)
colormap(mapgreen)
axis square

xticksv      = [-2*sigmaG, -WaistG, -sigmaG, 0, sigmaG, WaistG,2*sigmaG];
xticklabelsv = {'$-2\sigma$','$-w$','$-\sigma$','$0$','$\sigma$','$w$','$2\sigma$'};

set(gca,'xtick',xticksv);                                                   % Set values of ticks. 
set(gca,'xticklabel',xticklabelsv)   

set(gca,'ytick',xticksv);                                                   % Set values of ticks. 
set(gca,'yticklabel',xticklabelsv)   

c1 = plotCircle(0,0,sigmaG,'b',2);
c1.LineStyle = '--';

c2 = plotCircle(0,0,2*sigmaG,'r',2);
c2.LineStyle = '--';

c2 = plotCircle(0,0,WaistG,'m',2);
c2.LineStyle = '--';

xl = xlabel('$x$');
xl.Interpreter = 'Latex';

yl = ylabel('$y$');
yl.Interpreter = 'Latex';

subplot(1,2,2)
plot(x,abs(GB1D.OpticalField).^2/max(abs(GB1D.OpticalField).^2),'LineWidth',2,'Color','g');
h3=vline(-2*sigmaG);
h3.LineStyle = '--';
h3.LineWidth = 2;
h3.Color     = 'r';
xl = xlabel('$x$');
xl.Interpreter = 'Latex';
h4=vline(2*sigmaG);
h4.LineStyle = '--';
h4.LineWidth = 2;
h4.Color     = 'r';
set(gca,'xtick',xticksv);                                                   % Set values of ticks. 
set(gca,'xticklabel',xticklabelsv) 


h1=vline(-sigmaG);
h1.LineStyle = '--';
h1.LineWidth = 2;
h1.Color     = 'b';
xl = xlabel('$x$');
xl.Interpreter = 'Latex';
h2=vline(sigmaG);
h2.LineStyle = '--';
h2.LineWidth = 2;
h2.Color     = 'b';
set(gca,'xtick',xticksv);                                                   % Set values of ticks. 
set(gca,'xticklabel',xticklabelsv)



h3=vline(-WaistG);
h3.LineStyle = '--';
h3.LineWidth = 2;
h3.Color     = 'm';
xl = xlabel('$x$');
xl.Interpreter = 'Latex';
h4=vline(WaistG);
h4.LineStyle = '--';
h4.LineWidth = 2;
h4.Color     = 'm';
set(gca,'xtick',xticksv);                                                   % Set values of ticks. 
set(gca,'xticklabel',xticklabelsv)

ylabel('Intensity')


 export_fig('GaussianIntensityProfile','-png','-transparent')

%%
figure(2)

g = abs(GBzo.OpticalField).^2/max(abs(GBzo.OpticalField(:)).^2);

h = surf(X,Y,g);
colormap(mapgreen)
h.EdgeColor = 'none';


zci = g(79,79);
c1=plotCircleIn3D(0,0,zci,WaistG,'m',2);
c1.LineStyle = '--';
zci = g(94,94);
c2=plotCircleIn3D(0,0,zci,sigmaG,'b',2);
c2.LineStyle = '--';
zci = g(60,60);
c3=plotCircleIn3D(0,0,zci,2*sigmaG,'r',2);
c3.LineStyle = '--';
set(gca,'xtick',xticksv);                                                   % Set values of ticks. 
set(gca,'xticklabel',xticklabelsv)   

set(gca,'ytick',xticksv);                                                   % Set values of ticks. 
set(gca,'yticklabel',xticklabelsv)   

%% Generate and Save Plots of Hermite Gauss in zi

% copy of parameters
GPzi             = copy(GaussianParametersZ0);
% distances for plot
zi               = [0, RayleighDistance/4 , RayleighDistance/3 , RayleighDistance/2, ...
                      2*RayleighDistance/3, 3*RayleighDistance/4, RayleighDistance  ];
textdis          = {'0','zR4','zR3','zR2','2zR3','3zR4','zR'};

for jj = 1 : numel(zi)
  
  GPzi.zCoordinate = zi(jj);
  % Build new Optical Field
  GBzi            = GaussianBeam(R,GPzi);
  % Optic Field
  g                = GBzi.OpticalField;
  close(figure(3))
  fig3 = figure(3);
  fig3.Position = figureSize;
  plotOpticalField(scaleX.*x,scaleY.*x,abs(g).^2,mapgreen,labelX,labelY);
  axis square
  % set(gca,'FontSize',18);
  export_fig(['GaussBeam',textdis{jj}],'-png','-transparent')
   h = plotCircle(0,0,GPzi.Waist*scaleX,'r',1.5);
   h.LineStyle = '-.';
   export_fig(['GaussBeam',textdis{jj},'Waist'],'-png','-transparent')
  
end
%% Generate transversal field 

[Zm,Xm] = meshgrid(z,x);
GPzi.zCoordinate = Zm;
GB   = GaussianBeam(Xm, GPzi);

close(figure(1))
fig1 = figure(1);
plotOpticalField(scaleZ.*z,scaleX.*x,abs(GB.OpticalField).^2,...
                 mapgreen,labelZ,labelX);
fig1.Position = figureSize;
pbaspect(largeAspect)

HPz = copy(GaussianParametersZ0);
HPz.zCoordinate = z;

export_fig('GaussianBeamLateralX','-png','-transparent')
hold on
plot(scaleZ*z, scaleX*GB.Waist,'-.','Linewidth',2,'Color','r')
plot(scaleZ*z,-scaleX*GB.Waist,'-.','Linewidth',2,'Color','r')
hold off
export_fig('GaussianBeamLateralXWaist','-png','-transparent')

%%
fig2 = figure(2);
fig2.Position = [680 392 822 586];
h = surf(scaleZ.*Zm,scaleX.*Xm,abs(GB.OpticalField).^2/max(abs(GB.OpticalField(:)).^2));
colormap(mapgreen)
h.EdgeColor = 'none';
xlabel(labelZ,'Interpreter','latex')
ylabel(labelX,'Interpreter','latex')
zlabel('Intensity')
%  set(gcf, 'color', [0 0 0])
% set(gca,'XColor','w')
% set(gca,'YColor','w')
% set(gca,'ZColor','w')
% set(gca, 'color', [0 0 0])
 ylim([-2.5 2.5])
 view(-33,41)
 export_fig('GaussianBeam3DLateral','-png','-transparent')

%%
[Zm,Xm,Ym]       = meshgrid(z,x,y);
[Thm,Rm,zm]      = cart2pol(Xm,Ym,Zm);
GPzi.zCoordinate = Zm;
GB               = GaussianBeam(Rm, GPzi);
AA = GB.OpticalField;


%%