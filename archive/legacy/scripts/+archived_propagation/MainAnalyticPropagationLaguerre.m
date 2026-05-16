%% Legacy:          Script of Laguerre Beam (properties and propagation)
% adding path for classes and functions
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))
addpath(fullfile('ParaxialBeams', 'Addons', 'Plots_Functions'))
% Selecting green color for beam
mapgreen    = AdvancedColormap('kggg',256,[0 30 70 255]/255);
redColor    = [1,0,0];
yellowColor = [1,1,0];
%%          Initial parameters of Laguerre Gaussian Beams
l = 11;
p = 0;
% Physical parameters [microns]
InitialWaist        = 100;%179*2;
Wavelength          = 0.6328;
PropagationDistance = 0;

% Calculating Laguerre parameters in z=0
LPinZ0 = LaguerreParameters(PropagationDistance...
                           ,InitialWaist...
                           ,Wavelength...
                           ,l...
                           ,p);
                     
RayleighDistance    = LPinZ0.RayleighDistance;
%%                        Sampling of vectors 
% Estimate sampling in z-direction with propagation distance 
% z-direction
Dz = RayleighDistance;        % z-window (propagation distance)
Nz = 2^9+1;                   % number of points in z-direction
dz = Dz/Nz;                   % Resolution in z
z  = 0:dz:Dz;                 % z-vector z of propagation 

% Calculating Laguerre parameters in z distance vector copying object in z = 0
LPinZ  = copy(LPinZ0);
LPinZ.zCoordinate = z;                         
                        
fig1          = figure(1);
fig1.Position = [314 300 1097 479];
plotLaguerreParameters(LPinZ);
                                             
MaxLaguerreWaist = LPinZ.LaguerreWaist(end);

N   = 2^9;                  % Number of points in x,y axis
n   = -N/2+.05:N/2-1+.05;   % vector with N-points with resolution 1
Dx  = 2.2*MaxLaguerreWaist; % Size of window 
dx  = Dx/N;                 % Resolution
x   = n*dx;                 % Vector with dimentions
y   = x;                    % same for y
[X] = meshgrid(x,y);        % Matrix for x,y

% Transformation of coordinates
[ThetaCoordinate,RCoordinate] = cart2pol(X,X');

% 1d (r,th) coordinates
r    = 1:N;                 % (avoid origin)
Dr   = sqrt(2)*Dx;
dr   = Dr/N;
r    = r*dr;

th   = -N/2:N/2-1;
Dth  = 2*pi;
dth  = Dth/N;
th   = th*dth;

% Diferential vector in cylindrical coordinates
difr = [dr,dth,dz];

% Estimate vectors of frequency for Fourier Transforms associated
% with x,y
Du   = 1/dx;         % Size of window 
du   = 1/Dx;         % Resolution
u    = n*du;         % freq vector with dimentions
[U]  = meshgrid(u);  % freq Matrix
%kx,ky vectors
kx   = 2*pi*u;       % angular freq vector
[Kx] = meshgrid(kx); % angular freq matrix

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



%% Analytic Propagation
LPinZi  = copy(LPinZ0);

% distances for plot
zi      = [0, RayleighDistance/4,   RayleighDistance/3,   RayleighDistance/2, ...
              2*RayleighDistance/3, 3*RayleighDistance/4, RayleighDistance  ];
textdis = {'0','zR4','zR3','zR2','2zR3','3zR4','zR'};

for jj = 1 : numel(zi)
  
  LPinZi.zCoordinate = zi(jj);
  % Build new Optical Field
  LGBzi              = LaguerreBeam(RCoordinate,ThetaCoordinate,LPinZi);
  % Optic Field
  g                  = LGBzi.OpticalFieldLaguerre;

  fig3 = figure(3);
  fig3.Position = [680 406 802 572];
  plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
  axis square
  % set(gca,'FontSize',18);
  export_fig(['Laguerre',textdis{jj}],'-png','-transparent')
  plotCircle(0,0,scaleX*LGBzi.LaguerreWaist,'r',1.5);
  export_fig(['Laguerre',textdis{jj},'Waist'],'-png','-transparent')
  
end


%% Generate transversal field 
% [~,rho] = cart2pol(X,X'-InitialWaist/10);        % Convert this in polar coordinates

[Zm,Xm] = meshgrid(z,x);

LPinZi.zCoordinate = Zm;
LGB    = LaguerreBeam(Xm,0,LPinZi);

close(figure(1))
fig1 = figure(1);
plotOpticalField(scaleZ.*z,scaleX.*x,abs(LGB.OpticalFieldLaguerre).^2,...
                 mapgreen,labelZ,labelX);
fig1.Position = figureSize;
pbaspect(largeAspect)

LPinZ  = copy(LPinZ0);
LPinZ.zCoordinate = z;

export_fig('LaguerreLateralX','-png','-transparent')
hold on
plot(scaleZ*z, scaleX*LPinZ.LaguerreWaist,'-.','Linewidth',2,'Color','r')
plot(scaleZ*z,-scaleX*LPinZ.LaguerreWaist,'-.','Linewidth',2,'Color','r')
hold off
export_fig('LaguerreLateralXWaist','-png','-transparent')
