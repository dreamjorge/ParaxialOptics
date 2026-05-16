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

%% Hermite Gauss in z = 0
HGB   = HermiteBeam(X,Y,HermiteParametersz0);

% Optic Field to propagate 
g     = HGB.OpticalFieldHermite;
% Plot of Function
fig3 = figure(3);
fig3.Position = [680 406 802 572];
plotOpticalField(scaleX.*x,scaleY.*x,abs(g),mapgreen,labelX,labelY);
% title('Superposition of 4 Hankels')
export_fig('HermiteZ0','-png','-transparent')
%% Generate and Save Plots of Hermite Gauss in zi

% copy of parameters
HPzi             = copy(HermiteParametersz0);
% distances for plot
zi               = [0, RayleighDistance/4, RayleighDistance/3, RayleighDistance/2, ...
                    2*RayleighDistance/3, 3*RayleighDistance/4, RayleighDistance];
textdis          = {'0','zR4','zR3','zR2','2zR3','3zR4','zR'};

for jj = 1 : numel(zi)
  
  HPzi.zCoordinate = zi(jj);
  % Build new Optical Field
  HGBzi            = HermiteBeam(X,Y,HPzi);
  % Optic Field
  g                = HGBzi.OpticalFieldHermite;

  fig3 = figure(3);
  fig3.Position = [680 406 802 572];
  plotOpticalField(scaleX.*x,scaleY.*x,abs(g),mapgreen,labelX,labelY);
  % set(gca,'FontSize',18);
  export_fig(['Hermite',textdis{jj}],'-png','-transparent')
  h = plotWaistHermite2D(HPzi,scaleX,scaleY,'r');
  h.LineStyle = '-.';
  export_fig(['Hermite',textdis{jj},'Waist'],'-png','-transparent')
  
end


%% Obstruction on Hermite in z = 0
% Optic Field to propagate 
g     = HGB.OpticalFieldHermite;
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
figure(2)
plotOpticalField(scaleX*x,scaleY*x,abs(go),mapgreen,labelX,labelY);
export_fig('HermiteObs','-png','-transparent')
%% Parametrization of obstruction for rays
% Total points/rays in obstruction
no        = 3;
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

fig3 = figure(3);
fig3.Position = [680 406 802 572];
plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
plotRays(rayH11(1),'r',scaleX,scaleY)
export_fig('HermiteObsRays','-png','-transparent')

fig3 = figure(3);
fig3.Position = [680 406 802 572];
plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
plotRaysSquare(rayH11(1),'r',scaleX,scaleY)
export_fig('HermiteObsSquareRays','-png','-transparent')


%% Physical Propagation

prop = paraxialPropagator(Kx,Kx',k,dz);
figure(4)
imagesc(u,u,(angle(prop)))
title('Propagator')

% Matrix for save transversal fields
gx      = zeros(Nx,length(z)); 
gy      = zeros(Nx,length(z));
W       = zeros(Nx,Nz,Nx);
Wo      = zeros(Nx,Nz,Nx);
% Videos Options for generate video
if strcmp(GenerateVideo,'YES') % this was defined 8-line
  vidObj1 = VideoWriter('HGo.avi');
  vidObj1.Quality   = 100;
  vidObj1.FrameRate = 30;
  open(vidObj1);
end
%% propagation with respect to z
% copy of parameters
HPz             = copy(HermiteParametersz0);
HPz.zCoordinate = z;
for z_index = 1:length(z)
  %% plot propagate field                                      
  fig6 = figure(6);
  fig6.Position = [408 4 1037 973];
  plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
  hold on
%% Plot propagated points of hankels
  plotRays(rayH11(z_index),'r',scaleX,scaleY)
  plotRays(rayH21(z_index),'y',scaleX,scaleY)
  plotRays(rayH12(z_index),'m',scaleX,scaleY)                                         
  plotRays(rayH22(z_index),'c',scaleX,scaleY)
  title([labelZ, num2str(scaleZ*z(z_index)), ' of ', num2str(scaleZ*z(end))])
  drawnow
% Write video
  if strcmp(GenerateVideo,'YES')
    writeVideo(vidObj1, getframe(gca));
  end                                    
        
% propagation with respect to z
  % saving transversal fields
  gx(:,z_index)   = g(Nx/2+1,:);
  gy(:,z_index)   = g(:,Nx/2+1);
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
plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
title([labelZ, num2str(scaleZ*z(z_index)), ' of ', num2str(scaleZ*z(end))],'Interpreter','latex')

%% Plot propagated points of hankels at z(end)
plotRays(rayH11(z_index+1),'r',scaleX,scaleY)
plotRays(rayH21(z_index+1),'y',scaleX,scaleY)
plotRays(rayH12(z_index+1),'m',scaleX,scaleY)
plotRays(rayH22(z_index+1),'c',scaleX,scaleY)

if strcmp(GenerateVideo,'YES')
  writeVideo(vidObj1, getframe(gca));
  close(vidObj1);
end


%%
close(figure(6))
fig6          = figure(6);
fig6.Position = [382 228 1375 537];
imagesc(scaleZ*z,scaleY*y,abs(gy).^2);
set(gca,'YDir','normal')
xlabel(labelZ,'Interpreter','latex','FontSize',18)
ylabel(labelY,'Interpreter','latex','FontSize',18)
export_fig('HermiteLateralY','-png','-transparent')
hold on
plot(scaleZ*z, scaleX*HPz.HermiteWaistX/2,'-.','Linewidth',2,'Color','r')
plot(scaleZ*z,-scaleX*HPz.HermiteWaistX/2,'-.','Linewidth',2,'Color','r')
hold off
export_fig('HermiteLateralYRays','-png','-transparent')