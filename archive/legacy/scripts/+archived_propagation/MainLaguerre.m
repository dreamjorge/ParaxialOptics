% Legacy: MainLaguerre.m

%%          Script of Laguerre Beam (properties and propagation)
% adding path for classes and functions
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))

% Selecting green color for beam
mapgreen = AdvancedColormap('kggg',256,[0 30 70 255]/255);

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
r    = 0:N-1;
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
%% 
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
  plotOpticalField(x/InitialWaist,x/InitialWaist,abs(g).^2,mapgreen,'$x/w_o$','$y/w_o$');
  % set(gca,'FontSize',18);
  export_fig(['Laguerre',textdis{jj}],'-png','-transparent')
  plotCircle(0,0,LGBzi.LaguerreWaist/InitialWaist,'r',1.5);
  export_fig(['Hermite',textdis{jj},'Waist'],'-png','-transparent')
  
end




%% ----------------------- Laguerre Gauss in z = 0 --------------------- %%

% With laguerre parameters calculated, it estimates Laguerre Gauss Beam
LG = LaguerreBeam(RCoordinate,ThetaCoordinate,LPinZ0);
g  = LG.OpticalFieldLaguerre;
% Plot of Field
figure(2)
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(g).^2,mapgreen,'$x/w_0$','$x/w_0$');
plotCircle(0,0,LPinZ0.LaguerreWaist/InitialWaist,'r',1.5);

% Max Peak
pxy = max(max(g));

%% ----------------- Obstruction on Lagurre in z = 0 ------------------- %%
% Initial Waist of Laguerre Beam

lo      = (LPinZ0.LaguerreWaist)*0.3;  % size of obstruction in terms of waist of Laguerre
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
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(g).^2,mapgreen,'$x/w_0$','$x/w_0$');
plotCircle(0,0,LPinZ0.LaguerreWaist,'r',1.5);
plotCircle(xt,yt,lo,'r',1.5);
g(1,1) = pxyz;
%% ----------------------- Ray tracing (rx,z=0)  ----------------------- %%

TotalRays = 20;          % Number of rays

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
plotOpticalField(x,x,abs(g).^2,mapgreen,'$x/w_0$','$x/w_0$');
plotRaysAtZ(rayH1(1),1,10,'r');


%%                         Physical Propagation
% paraxial propagator 
prop    = paraxialPropagator(Kx,Kx',LPinZ0.k,dz);

figure(5)
imagesc(u,u,(angle(prop)))
title('Propagator')

% Matrix for save transversal fields
gx      = zeros(N,length(z)); 
gy      = zeros(N,length(z));

if strcmp(runGPU,'yes')
  gx      = gpuArray(gx); 
  gy      = gpuArray(gy); 
end

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
  [rayH1(z_index+1)] = HankelLaguerre.getPropagateCylindricalRays(rayH1(z_index),...
                                                                  TotalRays,...
                                                                  r,th,...
                                                                  difr,...
                                                                  LPinZi,...
                                                                  LPinZ,...
                                                                  HankelType...
                                                                 ); 
 

  % propagate all rays of H2
  HankelType = 2;
  [rayH2(z_index+1)] = HankelLaguerre.getPropagateCylindricalRays(rayH2(z_index),...
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
  plotOpticalField(x,x,abs(g),mapgreen,'$x/w_0$','$x/w_0$');
  title(['z = ', num2str(z_index), ' of ', num2str(Nz)])
  g(1,1) = pxyz;
  drawnow 
  hold on

  % Plot propagated points of H1 and H2 in iteration before
  plotRaysAtZ(rayH1(z_index+1),1,10,'r');
  plotRaysAtZ(rayH2(z_index+1),1,10,'r');

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