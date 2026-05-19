% Legacy: MaineLaguerreForTest.m

%%          Script of Laguerre Beam (properties and propagation)
% adding path for classes and functions
repoRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(repoRoot);
setpaths();

% Selecting green color for beam
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);
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


%% Given Initial Waist and RayleighDistance we can do Normalizations/Scale Factors
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

%%                        Sampling of vectors 
% Estimate sampling in z-direction with propagation distance 
% z-direction
Dz = RayleighDistance;        % z-window (propagation distance)
Nz = 2^9;                     % number of points in z-direction
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
r    = 1:N;
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


%% ----------------------- Laguerre Gauss in z = 0 --------------------- %%

% With laguerre parameters calculated, it estimates Laguerre Gauss Beam
LG = eLaguerreBeam(RCoordinate,ThetaCoordinate,LPinZ0);
g  = LG.OpticalFieldLaguerre;
% Plot of Field
figure(2)
plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
axis square
plotCircle(0,0,scaleX*LPinZ0.LaguerreWaist,'r',1.5);

% Max Peak
pxy = max(max(g));

%% ----------------- Obstruction on Lagurre in z = 0 ------------------- %%
% Initial Waist of Laguerre Beam

lo      = (LPinZ0.LaguerreWaist)*0.1;  % size of obstruction in terms of waist of Laguerre
xt      = 0;                           % traslation of obstruction in x-axis
yt      = 0;         

[~,rho] = cart2pol(X-xt,X'-yt);        % Convert this in polar coordinates
obo     = double(rho<=lo);             % Create Obstruction   
clear rho      
% Clean Matrix of polar coordinates
% Applying obstruction in optic field
g       = g.*(1-obo);
%Ploting Laguerre with obstruction
figure(3)
pxyz   = g(1,1);
g(1,1) = pxy;
plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
axis square
plotCircle(0,0,scaleX*LPinZ0.LaguerreWaist,'r',1.5);
plotCircle(xt,yt,lo,'r',1.5);
g(1,1) = pxyz;
%% ----------------------- Ray tracing (rx,z=0)  ----------------------- %%

TotalRays = 100;          % Number of rays

rayH1(Nz) = CylindricalRay();
rayH2(Nz) = CylindricalRay();

for ray_index = 1 : TotalRays
    % Cartersian coordinates of point in circunference of obstruction
    xi = xt + lo*cos(ray_index*(2*pi)/(TotalRays))+.001; 
    yi = yt + lo*sin(ray_index*(2*pi)/(TotalRays))+.001;
    zi = 0;
    % assign coordinate to Optical Rays in z = 0, i.e index_z = 1  
    [rayH1(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH1(1),ray_index,1);
    [rayH2(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH2(1),ray_index,2);
    
end

% Initial Field with rays in this init conditions
figure(3) 
plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
plotRaysAtZ(rayH1(1),scaleX,scaleY,10,'r');


%%                         Physical Propagation
% paraxial propagator 
prop    = paraxialPropagator(Kx,Kx',LPinZ0.k,dz);

figure(5)
imagesc(u,u,(angle(prop)))
title('Propagator')

% Matrix for save transversal fields
gx      = zeros(N,length(z)); 
gy      = zeros(N,length(z));

% Save field in z = 0 
gx(:,1) = g(N/2+1,:);
gy(:,1) = g(:,N/2+1);


for z_index = 1:length(z)-1 % propagation with respect to z
%% loop of each component in z

  % propagation of Optical Field 
  g = propagateOpticalField(g,prop);
  %saving transversal fields
  gx(:,z_index+1) = g(N/2+1,:);
  gy(:,z_index+1) = g(:,N/2+1);  
    
  %%                    Calculating Rays

  % propagation distance 
  zi     = z(z_index);
  % calculating Laguerre Parameters in zi
  LPinZi = LaguerreParameters(zi,InitialWaist,Wavelength,l,p);   

  % propagate all rays of H1
  HankelType = 1;
  [rayH1(z_index+1)] = HankeleLaguerre.getPropagateCylindricalRays(rayH1(z_index),...
                                                                  TotalRays,...
                                                                  r,th,...
                                                                  difr,...
                                                                  LPinZi,...
                                                                  LPinZ,...
                                                                  HankelType...
                                                                 ); 
 

  % propagate all rays of H2
  HankelType = 2;
  [rayH2(z_index+1)] = HankeleLaguerre.getPropagateCylindricalRays(rayH2(z_index),...
                                                                  TotalRays,...
                                                                  r,th,...
                                                                  difr,...
                                                                  LPinZi,...
                                                                  LPinZ,...
                                                                  HankelType...
                                                                 );
                         

  %                             End calculating rays 
  %%

  fig = figure(6);
%   fig.Position = [-1349 147 813 733];

  pxyz   = g(1,1);
  g(1,1) = pxy;
  plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
  plotCircle(0,0,scaleX*LPinZi.LaguerreWaist,'r',1.5);
  
  
  title(['z/z_R = ', num2str(z(z_index)/RayleighDistance), ' of ', num2str(Dz/RayleighDistance)],'Interpreter','latex')
  g(1,1) = pxyz;
  drawnow 
  hold on

  % Plot propagated points of H1 and H2 in iteration before
  %change colors for H2 if cross origin
  c1 = (rayH2(z_index+1).hankelType == 1)'*redColor;
  c2 = (rayH2(z_index+1).hankelType == 2)'*yellowColor;    
  c  = c1+c2;
  
  plotRaysAtZ(rayH1(z_index+1),scaleX,scaleY,10,redColor);
  plotRaysAtZ(rayH2(z_index+1),scaleX,scaleY,10,c);
  pause(0.1)

end
%%
figure(7)
plotRaysPropagated(rayH1,rayH2,Nz);
%%
figure(8)
imagesc(z,x,abs(gx))

%%
hold on
for z_index = 1:length(z)-1
  scatter(rayH2(z_index).zCoordinate,rayH2(z_index).xCoordinate,10,'filled','MarkerFaceColor',[1 0 0])
  scatter(rayH1(z_index).zCoordinate,rayH1(z_index).xCoordinate,10,'filled','MarkerFaceColor',[0 1 0])
end
hold off

figure(9)

for z_index = 1:length(z)-1
  
  radial1(z_index) = rayH2(z_index).rCoordinate(1);
  radial2(z_index) = rayH2(z_index).rCoordinate(2);
end
hold on
plot(radial1)
plot(radial2)
hold off
