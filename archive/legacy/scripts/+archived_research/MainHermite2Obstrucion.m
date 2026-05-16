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
nu = 22;
mu = 21;

%% Physical parameters [microns]
InitialWaist = 100;
Wavelength   = 0.6328;

%% Build parameters of Hermite in z=0
HermiteParametersz0  = HermiteParameters(0,InitialWaist,Wavelength,nu,mu);
%obtain parameters of beam
k                    = HermiteParametersz0.k;
RayleighDistance     = HermiteParametersz0.RayleighDistance;

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
Dz    = RayleighDistance;     % z-window (propagation distance)
Nz    = 2^7;                      % number of points in z-direction
dz    = Dz/Nz;                    % Resolution in z
nz    = 0:Nz-1;                   % vector with N-points with resolution 1
z     = nz*dz;                    % z-vector z of propagation 

% waist of Hermite Gauss Beam until z-propagation
MaxHermiteWaist = HermiteParameters.getWaist(z(end),InitialWaist,RayleighDistance,nu,mu);

%Second, we estimate sampling in x,y-direction in terms of waist of Guassian
%Hermite Beam

% y,x-direction
Nx    =  2^10;                 % Number of points in x,y axis
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
figure(3)
plotOpticalField(scaleX*x,scaleY*x,abs(g).^2,mapgreen,labelX,labelY);
axis square
%% Obstruction on Hermite in z = 0

% Obstruction
lx    = HermiteParametersz0.HermiteWaist/3.85;
ly    = HermiteParametersz0.HermiteWaist/4.35;
xt    = 0;
yt    = HermiteParametersz0.HermiteWaist/3.1;
obx   = double(abs(x-xt)<=lx/2);
oby   = double(abs(x-yt)<=ly/2);
obo   = (oby')*obx;


% Applying obstruction in optic field
go    = g.*(1-obo);
%Ploting Laguerre with obstruction
figure(2)
plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
axis square
export_fig('HermiteBeamWithObstruction','-png','-transparent')
% Parametrization of obstruction for rays
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

figure(3)
plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
axis square
plotRays(rayH11(1),'r',scaleX,scaleY);
%pr = plotRaysSquare(rayH11(1),'r',scaleX,scaleY);
%pr.LineStyle = ':';
export_fig('HermiteBeamWithObstructionRays','-png','-transparent')
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
  title(['z = ', num2str(z(z_index)/RayleighDistance), ' of ', num2str(z(end)/RayleighDistance)])
  drawnow
% Write video
  if strcmp(GenerateVideo,'YES')
    writeVideo(vidObj1, getframe(gca));
  end                                    
        
% propagation with respect to z
  % saving transversal fields
  gx(:,z_index)   = go(Nx/2,:);
  gy(:,z_index)   = go(:,Nx/2);
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
plotOpticalField(scaleX*x,scaleY*x,abs(go).^2,mapgreen,labelX,labelY);
  hold on
%% Plot propagated points of hankels
  plotRays(rayH11(z_index),'r',scaleX,scaleY)
  plotRays(rayH21(z_index),'y',scaleX,scaleY)
  plotRays(rayH12(z_index),'m',scaleX,scaleY)                                         
  plotRays(rayH22(z_index),'c',scaleX,scaleY)
  title(['z = ', num2str(z(z_index)/RayleighDistance), ' of ', num2str(z(end)/RayleighDistance)])
export_fig('SelfHealingHermiteatZR','-png','-transparent')

% plotRaysSquare(rayH11(z_index+1),'r',InitialWaist)
% plotRaysSquare(rayH21(z_index+1),'y',InitialWaist)
% plotRaysSquare(rayH12(z_index+1),'m',InitialWaist)
% plotRaysSquare(rayH22(z_index+1),'c',InitialWaist)
% export_fig('SelfHealingHermiteatZRSquares','-png','-transparent')
%% Plot propagated points of hankels at z(end)
plotRays(rayH11(z_index+1),'r',InitialWaist,InitialWaist)
plotRays(rayH21(z_index+1),'y',InitialWaist,InitialWaist)
plotRays(rayH12(z_index+1),'m',InitialWaist,InitialWaist)
plotRays(rayH22(z_index+1),'c',InitialWaist,InitialWaist)
export_fig('SelfHealingHermiteatZRRays','-png','-transparent')

if strcmp(GenerateVideo,'YES')
  writeVideo(vidObj1, getframe(gca));
  close(vidObj1);
end

%%
  ray11 = struct();
  ray12 = struct();
  ray21 = struct();
  ray22 = struct();
  for z_index = 1:Nz

        for ray_index = 1:TotalRays
          
          ray11(ray_index).z(z_index) = rayH11(z_index).zCoordinate(ray_index);
          ray11(ray_index).x(z_index) = rayH11(z_index).xCoordinate(ray_index);
          ray11(ray_index).y(z_index) = rayH11(z_index).yCoordinate(ray_index);
          
          ray12(ray_index).z(z_index) = rayH12(z_index).zCoordinate(ray_index);
          ray12(ray_index).x(z_index) = rayH12(z_index).xCoordinate(ray_index);
          ray12(ray_index).y(z_index) = rayH12(z_index).yCoordinate(ray_index);
          
          ray21(ray_index).z(z_index) = rayH21(z_index).zCoordinate(ray_index);
          ray21(ray_index).x(z_index) = rayH21(z_index).xCoordinate(ray_index);
          ray21(ray_index).y(z_index) = rayH21(z_index).yCoordinate(ray_index);
          
          ray22(ray_index).z(z_index) = rayH22(z_index).zCoordinate(ray_index);
          ray22(ray_index).x(z_index) = rayH22(z_index).xCoordinate(ray_index);
          ray22(ray_index).y(z_index) = rayH22(z_index).yCoordinate(ray_index);
          
        end
 
  end    



  gxt = Wo(512,:,:);
  
  gtx = squeeze(gxt);
  
  fig6 = figure(6);
  fig6.Position = [382 228 1375 537];
  pcolor(z/RayleighDistance,x/InitialWaist, abs(gtx').^2);
  shading interp
  xlabel('$z/z_R$','Interpreter','latex','FontSize',18)
  ylabel('$y/w_o$','Interpreter','latex','FontSize',18)
  export_fig('HermiteLateralX','-png','-transparent')
  hold on
  indexray = 4;
   plot(ray11(indexray).z/RayleighDistance, ray11(indexray).x./InitialWaist,'-.','Linewidth',2,'Color','r')
   plot(ray22(indexray).z/RayleighDistance, ray22(indexray).x./InitialWaist,'-.','Linewidth',2,'Color','c')
  indexray = 1;
   plot(ray11(indexray).z/RayleighDistance, ray11(indexray).x./InitialWaist,'-.','Linewidth',2,'Color','r')
   plot(ray22(indexray).z/RayleighDistance, ray22(indexray).x./InitialWaist,'-.','Linewidth',2,'Color','c')
   
   plot(z/RayleighDistance,-HPz.HermiteWaistX/(2*InitialWaist),'-.','Linewidth',2,'Color','r')
  hold off
  export_fig('HermiteLateralXRays','-png','-transparent')
  pause(0.1)
  
  %%
  
  
  gxt = Wo(:,:,680);
  
  gtx = reshape(gxt,1024,128);
  
  fig6 = figure(6);
  fig6.Position = [382 228 1375 537];
  pcolor(z/RayleighDistance,x/InitialWaist,abs(gxt).^2);
  colormap(mapgreen)
  shading flat
  xlabel('$z/z_R$','Interpreter','latex','FontSize',18)
  ylabel('$y/w_o$','Interpreter','latex','FontSize',18)
  export_fig('HermiteLateralY','-png','-transparent')
  pause(0.1)
hold on
  indexray = 6;
   plot(ray11(indexray).z/RayleighDistance, ray11(indexray).y./InitialWaist,'-.','Linewidth',2,'Color','r')
   plot(ray22(indexray).z/RayleighDistance, ray22(indexray).y./InitialWaist,'-.','Linewidth',2,'Color','c')
  indexray = 2;
   plot(ray11(indexray).z/RayleighDistance, ray11(indexray).y./InitialWaist,'-.','Linewidth',2,'Color','r')
   plot(ray22(indexray).z/RayleighDistance, ray22(indexray).y./InitialWaist,'-.','Linewidth',2,'Color','c')
   
  hold off