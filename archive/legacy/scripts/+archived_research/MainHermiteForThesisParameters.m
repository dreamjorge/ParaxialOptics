%% Legacy:                      Main Hermite
% Ugalde-Ontiveros J.A. 
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
HermiteParametersz0  = HermiteParameters(0,InitialWaist,Wavelength,nu,mu);
%obtain parameters of beam
k                    = HermiteParametersz0.k;
RayleighDistance     = HermiteParametersz0.RayleighDistance;

%% sampling of vectors 
%First, we estimate samplig in z-direction with propagation distance 
% z-direction
Dz    = RayleighDistance;         % z-window (propagation distance)
Nz    = 2^7;                      % number of points in z-direction
dz    = Dz/Nz;                    % Resolution in z
nz    = 0:Nz-1;                   % vector with N-points with resolution 1
z     = nz*dz;                    % z-vector z of propagation 

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

%Last, we estimate vectors of frequency for Fourier Transforms
Du    = 1/dx;                 % Size of window 
du    = 1/Dx;                 % Resolution
u     = n*du;                 % Vector
[U]   = meshgrid(u);
%kx,ky vectors
kx    = 2*pi*u;
[Kx]  = meshgrid(kx);

%diferential
dr    = [dx,dx,dz];


%% Hermite Gauss in z = 0
HGB   = HermiteBeam(X,Y,HermiteParametersz0);
% copy of parameters
HPz   = copy(HermiteParametersz0);
% Changing parameters to vector z
HPz.zCoordinate = z;  
% Optic Field to propagate 
g     = HGB.OpticalFieldHermite;
% Plot of Function
close(figure(3))
figure(3)

plotOpticalField(x/(HermiteParametersz0.Waist),x/(HermiteParametersz0.Waist),abs(g),mapgreen,'');

% xsq = [-HermiteInitialWaistX/2, HermiteInitialWaistX/2,HermiteInitialWaistX/2,-HermiteInitialWaistX/2];
% ysq = [-HermiteInitialWaistY/2,-HermiteInitialWaistY/2,HermiteInitialWaistY/2, HermiteInitialWaistY/2];
% plotSquare(xsq/InitialWaist,xsq/InitialWaist,'m')
recv = [-HermiteInitialWaistX/2 -HermiteInitialWaistY/2 HermiteInitialWaistX HermiteInitialWaistY];
rectangle('Position',sqrt(2)*recv/InitialWaist,'EdgeColor','b','LineWidth',2.5)
export_fig('ImagesThesis/HermiteGaussz0waist','-png','-transparent')

%% Hermite Gauss in z = 0
HGB   = HermiteBeam(X,Y,HermiteParametersz0);
% copy of parameters
HPz   = copy(HermiteParametersz0);
% Changing parameters to vector z
HPz.zCoordinate = z;  
% Optic Field to propagate 
g     = HGB.OpticalFieldHermite;
% Plot of Function
close(figure(3))
figure(3)

plotOpticalField(x/(HermiteParametersz0.Waist),x/(HermiteParametersz0.Waist),abs(g),mapgreen,'');
export_fig('ImagesThesis/HermiteGaussz0','-png','-transparent')


%% Obstruction on Hermite in z = 0

% Obstruction
lx    = HermiteParametersz0.HermiteWaist/3.8;
ly    = HermiteParametersz0.HermiteWaist/4.5;
xt    = 0;...HPz0.HermiteWaist/5;
yt    = xt;
obx   = double(abs(x-xt)<=lx/2);
oby   = double(abs(x-yt)<=ly/2);
obo   = (oby')*obx;

% Applying obstruction in optic field
go    = g.*(1-obo);
%Ploting Laguerre with obstruction
close(figure(2))
figure(2)
plotOpticalField(x/(HermiteParametersz0.Waist),x/(HermiteParametersz0.Waist),abs(go),mapgreen,'');
export_fig('ImagesThesis/HermiteBeamWithObstruction','-png','-transparent')
%% Parametrization of obstruction for rays
% Total points/rays in obstruction
no        = 4;
TotalRays = 2^no;
th        = 2*pi/TotalRays;

% Optical Ray of size Nz, i.e size of direction of z-coordinate
rayH11(Nz) = OpticalRay();
rayH12(Nz) = OpticalRay();
rayH21(Nz) = OpticalRay();
rayH22(Nz) = OpticalRay();

% it given parametrization of obstruction, we give initial conditions of
% rays
for ray_index = 1:TotalRays
  
  xj         = xt + (lx/2)*(abs(cos((ray_index)*th))*cos((ray_index)*th)...
             + abs(sin((ray_index)*th))*sin((ray_index)*th));
  yj         = yt + (ly/2)*(abs(cos((ray_index)*th))*cos((ray_index)*th)...
             - abs(sin((ray_index)*th))*sin((ray_index)*th));
  zj         = 0;

  %assign coordinates to each Hankel ray
  hankeltype = 11;
  rayH11(1)  = assignCoordinates2CartesianRay(xj,yj,zj,rayH11(1),ray_index,hankeltype);
  hankeltype = 12;
  rayH12(1)  = assignCoordinates2CartesianRay(xj,yj,zj,rayH12(1),ray_index,hankeltype);
  hankeltype = 21;
  rayH21(1)  = assignCoordinates2CartesianRay(xj,yj,zj,rayH21(1),ray_index,hankeltype);
  hankeltype = 22;
  rayH22(1)  = assignCoordinates2CartesianRay(xj,yj,zj,rayH22(1),ray_index,hankeltype);
  
end
close(figure(3))
figure(3)
plotOpticalField(x,x,abs(go),mapgreen,'microns');
plotRays(rayH11(1),'r',1)
export_fig('ImagesThesis/HermiteBeamWithObstructionRays','-png','-transparent')
%% Physical Propagation

prop = paraxialPropagator(Kx,Kx',k,dz);
figure(4)
imagesc(u,u,(angle(prop)))
title('Propagator')

% Matrix for save transversal fields
gx   = zeros(Nx,length(z)); 
gy   = zeros(Nx,length(z));
gox  = zeros(Nx,length(z)); 
goy  = zeros(Nx,length(z));
W    = zeros(Nx,Nz,Nx);
Wo   = zeros(Nx,Nz,Nx);
% Videos Options for generate video
if strcmp(GenerateVideo,'YES') % this was defined 8-line
  vidObj1 = VideoWriter('HGo.avi');
  vidObj1.Quality   = 100;
  vidObj1.FrameRate = 30;
  open(vidObj1);
end
%% propagation with respect to z
for z_index = 1:length(z)
  %% plot propagate field                                      
  fig6 = figure(6);
  fig6.Position = [408 4 1037 973];
  plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
  hold on
%% Plot propagated points of hankels
  plotRays(rayH11(z_index),'r',1)
  plotRays(rayH21(z_index),'y',1)
  plotRays(rayH12(z_index),'m',1)                                         
  plotRays(rayH22(z_index),'c',1)
  title(['z = ', num2str(z(z_index)), ' of ', num2str(z(end)), ' microns'])
  drawnow
% Write video
  if strcmp(GenerateVideo,'YES')
    writeVideo(vidObj1, getframe(gca));
  end                                    
        
% propagation with respect to z
  % saving transversal fields
  gx(:,z_index)   = g(Nx/2+1,:);
  gy(:,z_index)   = g(:,Nx/2+1);
  gox(:,z_index)  = go(Nx/2+1,:);
  goy(:,z_index)  = go(:,Nx/2+1);
  % saving field for slices
  W    (:,z_index,:) = g;
  Wo   (:,z_index,:) = go;
  % propagating field
  G    = fftshift(fft2((g)));
  Go   = fftshift(fft2((go)));

  % obtain new propagated field
  go   = (ifft2(ifftshift(Go.*prop)));
  g    = (ifft2(ifftshift(G.*prop)));
  
%%  Calculating propagation of Rays
  % propagation distance 
  zi   = z(z_index);
  % calculating Laguerre Parameters in zi
  HPzi = HermiteParameters(zi,InitialWaist,Wavelength,nu,mu);   
  
  % propagate all rays of H11
  HankelType = 11;
  [rayH11(z_index+1)] = ...
  HankelHermite.getPropagateCartesianRays(rayH11(z_index),...
                                          x,y,...
                                          dr,...
                                          HPzi,...
                                          HPz,...
                                          HankelType); 
 
  HankelType = 12;                                      
  [rayH12(z_index+1)] = ...
  HankelHermite.getPropagateCartesianRays(rayH12(z_index),...
                                          x,y,...
                                          dr,...
                                          HPzi,...
                                          HPz,...
                                          HankelType); 
                                        
  HankelType = 21;                                      
  [rayH21(z_index+1)] = ...
  HankelHermite.getPropagateCartesianRays(rayH21(z_index),...
                                          x,y,...
                                          dr,...
                                          HPzi,...
                                          HPz,...
                                          HankelType);                                       
   
  HankelType = 22;                                       
  [rayH22(z_index+1)] = ...
  HankelHermite.getPropagateCartesianRays(rayH22(z_index),...
                                          x,y,...
                                          dr,...
                                          HPzi,...
                                          HPz,...
                                          HankelType);                                       
                                
    pause(0.01)
end

%% plot propagate field at z(end)                                    
fig6 = figure(6);
fig6.Position = [408 4 1037 973];
plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
title(['z = ', num2str(z(z_index)), ' of ', num2str(z(end)), ' microns'])

%% Plot propagated points of hankels at z(end)
plotRays(rayH11(z_index+1),'r',1)
plotRays(rayH21(z_index+1),'y',1)
plotRays(rayH12(z_index+1),'m',1)
plotRays(rayH22(z_index+1),'c',1)

if strcmp(GenerateVideo,'YES')
  writeVideo(vidObj1, getframe(gca));
  close(vidObj1);
end

%% transversal field
close(figure(1))
fig1          =figure(1);
fig1.Position = [680,558,1024,420];
imagesc(z/RayleighDistance,x/InitialWaist,abs(gy).^2)
xlabel('$z$','Interpreter','latex')
ylabel('$\eta$','Interpreter','latex')
colormap(mapgreen)
export_fig('ImagesThesis/HermiteBeamYLateral','-png','-transparent')
hold on
p1 = plot(z/RayleighDistance, HPz.HermiteWaistY/(sqrt(2)*InitialWaist),'-.','color','r','LineWidth',2);
plot(z/RayleighDistance,-HPz.HermiteWaistY/(sqrt(2)*InitialWaist),'-.','color','r','LineWidth',2)
p2 = plot(z/RayleighDistance, HPz.Waist/(InitialWaist),'-.','color','m','LineWidth',2);
plot(z/RayleighDistance,-HPz.Waist/(InitialWaist),'-.','color','m','LineWidth',2)
legend([p1,p2],'Hermite Waist','Gaussian Waist')
export_fig('ImagesThesis/HermiteBeamYLateralRays','-png','-transparent')


%% parameters of Hermite

close(figure(1))
fig1          =figure(1);
fig1.Position = [680,558,1024,420];

p1 = plot(z/RayleighDistance, HPz.HermiteWaistY/(sqrt(2)*InitialWaist),'-.','color','r','LineWidth',2);
hold on
plot(z/RayleighDistance,-HPz.HermiteWaistY/(sqrt(2)*InitialWaist),'-.','color','r','LineWidth',2)
plot(z/RayleighDistance, HPz.Amplitude/(sqrt(2)*InitialWaist),'-.','color','b','LineWidth',2);
plot(z/RayleighDistance, HPz.PhiPhase,'-.','color','b','LineWidth',2);
plot(z/RayleighDistance, HPz.Radius,'-.','color','b','LineWidth',2);
ylim([0 10])
