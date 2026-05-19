% Legacy: MainLaguerre2.m
 
%%          Script of Laguerre Beam (properties and propagation)
% adding path for classes and functions
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
% Selecting green color for beam
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);
% use gpu? 
runGPU = 'no';
%% -         Initial parameters of Laguerre Gaussian Beams

l = 10;
p = 0;

% Physical parameters [microns]
InitialWaist = 10;%179*2;
Wavelength   = 0.6328;
% normalized parameters
% InitialWaist = 1;
% Wavelength   = pi;
PropagationDistance = 0;

% Calculating Laguerre parameters in z=0
LPinZ0 = LaguerreParameters(PropagationDistance...
                           ,InitialWaist...
                           ,Wavelength...
                           ,l...
                           ,p);
                     
%%                        Sampling of vectors 
% Estimate sampling in z-direction with propagation distance 
% z-direction
Dz = LPinZ0.RayleighDistance; % z-window (propagation distance)
Nz = 2^9;                     % number of points in z-direction
dz = Dz/Nz;                   % Resolution in z
z  = 0:dz:Dz;                 % z-vector z of propagation 

% Calculating Laguerre parameters in z distance vector
% LPinZ = LaguerreParameters(z...
%                           ,InitialWaist...
%                           ,Wavelength...
%                           ,l...
%                           ,p);
                        
% Calculating Laguerre parameters in z distance vector copying object in z = 0
LPinZ  = copy(LPinZ0);
LPinZ.zCoordinate = z;                         
                        
fig1          = figure(1);
fig1.Position = [314 300 1097 479];
plotLaguerreParameters(LPinZ);

% Estimate sampling in x,y-direction in terms of waist of max  
% Laguerre Gauss Beam waist until max z-propagation

% MaxLaguerreWaist = LaguerreParameters.waistFunction(z(end)...
%                                                    ,InitialWaist...
%                                                    ,LPinZ0.RayleighDistance...
%                                                    ,l...
%                                                    ,p);
 % waist in max z, from LaguereParametersz0                                               
MaxLaguerreWaist = LPinZ.LaguerreWaist(end);

% radial vetor 
Nr  = 2^9;
nr  = 1:Nr;   
Dr  = 4.4*MaxLaguerreWaist;  %radial distance 
dr  = Dr/Nr;                 
r   = nr*dr;                 

% angular vector
Nth = Nr;
nth = -Nth/2+1:1:Nth/2;
Dth = 2*pi;
dth = Dth/Nth;
th  = nth*dth;

% cartesian vector
N   = 2^9;                  % Number of points in x,y axis
n   = -N/2:N/2-1;           % vector with N-points with resolution 1
Dx  = Dr/sqrt(2);           % Size of window 
dx  = Dx/N;                 % Resolution
x   = n*dx;                 % Vector with dimentions
y   = x;                    % same for y

% 2D matrixes
[X,Y]  = meshgrid(x,y);
[TH,R] = cart2pol(X,Y);

% Diferential vector in cilindrycal coordinates
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

[X,Y,Z]  = meshgrid(x,y,z);
if strcmp(runGPU,'yes')
%Parallel Computing Toolbox
  x               = gpuArray(x);
  X               = gpuArray(X);
  u               = gpuArray(u);
  U               = gpuArray(U);
  kx              = gpuArray(kx);
  rCoordinate     = gpuArray(rCoordinate);
  thetaCoordinate = gpuArray(thetaCoordinate);
  RCoordinate     = gpuArray(RCoordinate);
  ThetaCoordinate = gpuArray(ThetaCoordinate);
end
%% ----------------------- Laguerre Gauss in z = 0 --------------------- %%

% With laguerre parameters calculated, it estimates Laguerre Gauss Beam
LG = LaguerreBeam(R,TH,LPinZ0);

% Plot of Field
figure(2)
plotOpticalField(x,x,abs(LG.OpticalFieldLaguerre).^2,mapgreen,'microns');
plotCircle(0,0,LPinZ0.LaguerreWaist);

% Optic Field to propagate 
g   = LG.OpticalFieldLaguerre;
% Max Peak
pxy = max(max(g));

%% ----------------- Obstruction on Lagurre in z = 0 ------------------- %%
% Initial Waist of Laguerre Beam

lo      = (LPinZ0.LaguerreWaist)/4.3;  % size of obstruction in terms of waist of Laguerre
xt      = LPinZ0.LaguerreWaist/3.5;    % traslation of obstruction in x-axis
yt      = LPinZ0.LaguerreWaist/3.5;    % traslation of onstruction in y-axis
[~,rho] = cart2pol(X-xt,Y-yt);        % Convert this in polar coordinates
obo     = double(rho<=lo);             % Create Obstruction   
clear rho      
% Clean Matrix of polar coordinates
% Applying obstruction in optic field
g       = g.*(1-obo);
%Ploting Laguerre with obstruction
figure(3)
plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
plotCircle(0,0,LPinZ0.LaguerreWaist);
plotCircle(xt,yt,lo);


%% ----------------------- Ray tracing (rx,z=0)  ----------------------- %%

TotalRays = 10;          % Number of rays

rayH1(Nz) = CylindricalRay();
rayH2(Nz) = CylindricalRay();

for point_index = 1 : TotalRays
    % Cartersian coordinates of point in circunference of obstruction
    xi = xt + lo*cos(point_index*(2*pi)/(TotalRays))+.001; 
    yi = yt + lo*sin(point_index*(2*pi)/(TotalRays))+.001;
    zi = 0;
    % assign coordinate to Optical Rays in z = 0, i.e index_z = 1  
    [rayH1(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH1(1),point_index,1);
    [rayH2(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH2(1),point_index,2);
    
end

% Initial Field with rays in this init conditions
figure(3) 
plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
plotRays(rayH1(1),'r')


%%                         Physical Propagation
% paraxial propagator 
prop    = paraxialPropagator(Kx,Kx',LPinZ0.k,dz);

figure(4)
imagesc(u,u,(angle(prop)))
title('Propagator')

% Matrix for save transversal fields
gx      = zeros(Nr,length(z)); 
gy      = zeros(Nr,length(z));

if strcmp(runGPU,'yes')
  gx      = gpuArray(gx); 
  gy      = gpuArray(gy); 
end

% Save field in z = 0 
gx(:,1) = g(Nr/2+1,:);
gy(:,1) = g(:,Nr/2+1);

vidObj1 = VideoWriter('LaguerreBeamMomemtum20.avi');
vidObj1.Quality = 100;
vidObj1.FrameRate =30;
open(vidObj1);

slicesField = {};
slicesField = g;
slices = [floor(Nz/3) , floor(2*Nz/3) , Nz]; 

h = zeros(512,512,4);

h(:,:,1) = g;
ll = 1;
for z_index = 1:length(z)-1 % propagation with respect to z
%% loop of each component in z

  % propagation of Optical Field 

  if ismember(z_index,slices)
    ll = ll+1;
    h(:,:,ll) = g;
  end
  %saving transversal fields
  gx(:,z_index+1) = g(Nr/2+1,:);
  gy(:,z_index+1) = g(:,Nr/2+1);  

  %%                    Calculating Rays

  % propagation distance 
  zi     = z(z_index);
  % calculating Laguerre Parameters in zi
  LPinZi = LaguerreParameters(zi,InitialWaist,Wavelength,l,p);   

  % propagate all rays of H1
  HankelType = 1;
  [rayH1(z_index+1)] = getPropagateCylindricalRays(rayH1(z_index),...
                                                   TotalRays,...
                                                   r,th,...
                                                   difr,...
                                                   LPinZi,...
                                                   LPinZ,...
                                                   HankelType); 
 

  % propagate all rays of H2
  HankelType  = 2;
  [rayH2(z_index+1)] = getPropagateCylindricalRays(rayH2(z_index),...
                                                   TotalRays,...
                                                   r,th,...
                                                   difr,...
                                                   LPinZi,...
                                                   LPinZ,...
                                                   HankelType);
                         

  %                             End calculating rays 
  %%

  fig6 = figure(6);
  fig6.Position = [408 4 1037 973];
  plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
  title(['z = ', num2str(z(z_index)), ' of ', num2str(z(end)), ' microns'])

  % Plot propagated points of H1 and H2
  plotRays(rayH1(z_index+1),'r')
  plotRays(rayH2(z_index+1),'y')

  pause(0.01)
  writeVideo(vidObj1, getframe(gca));
end
%%

writeVideo(vidObj1, getframe(gca));
close(vidObj1);

%%


zs = [0 z(floor(Nz/3)) , z(floor(2*Nz/3)) , z(Nz)]; 

[Xs,Ys,Zs] = meshgrid(x,y,zs);

xslice = [];   
yslice = [];
zslice = zs;

figure(7)
slice(Xs,Ys,Zs,abs(h),xslice,yslice,zs)
%plotRaysPropagated(rayH1,rayH2,Nz);
% hold on 
% im = imagesc(x,y,abs(LG.OpticalFieldLaguerre));
% im.AlphaData = .5;
% hold on
% im2 = imagesc(x,y,abs(slicesField(:,513:1024)));
% im2.AlphaData = .5;
% hold off
%%
%%
figure(8)
imagesc(z,x,abs(gx))
hold on
for z_index = 1:length(z)-1
  scatter(rayH2(z_index).zCoordinate,rayH2(z_index).xCoordinate,10,'filled','MarkerFaceColor',[1 0 0])
  scatter(rayH1(z_index).zCoordinate,rayH1(z_index).xCoordinate,10,'filled','MarkerFaceColor',[0 1 0])
end
hold off

figure(9)

radial1 = zeros(length(z));
radial2 = zeros(length(z));

for z_index = 1:length(z)-1
  
  radial1(z_index) = rayH2(z_index).rCoordinate(1);
  radial2(z_index) = rayH2(z_index).rCoordinate(2);
end
hold on
plot(radial1)
plot(radial2)
hold off