% Legacy: AnalysisExperimentalLaguerre.m
% Default Parameters
defaultFormat = '*.mat';
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
mapgreen = parula;
% open files of images

current_dir = pwd;
cd ..
image_dir   = ['Imagenes lateral Laguerre Experimental Procesado\Laguerre Obstruccion fuera de eje\']; 

cd(image_dir)

files = dir('*.mat');

% [ListFiles,WorkDir] = uigetfile({defaultFormat,['.mat (',defaultFormat,')']},...
%                       'Select One or More .mat Files','MultiSelect','on');
                    
NrFilesInDirectory  = size(files,1);                   

S = struct();

for jj = 1:NrFilesInDirectory

 S.ListFiles{jj} = load([pwd,'\',files(jj).name]);
    
end

cd(current_dir)

%%

%resolution of camera of capture
dx     = 8;                             %microns
Nx     = size((S.ListFiles{1}.im),1);
n      = -Nx/2:Nx/2-1;
Dx     = Nx*dx;
x      = n*dx;
X      = meshgrid(x);
[TH,R] = cart2pol(X,X');

% Estimate vectors of frequency for Fourier Transforms associated
% with x,y
Du   = 1/dx;         % Size of window 
du   = 1/Dx;         % Resolution
u    = n*du;         % freq vector with dimentions
[U]  = meshgrid(u);  % freq Matrix
%kx,ky vectors
kx   = 2*pi*u;       % angular freq vector
[Kx] = meshgrid(kx); % angular freq matrix


% radial vetor 
Nr  = Nx;
nr  = 1:Nr;   
Dr  = Dx/2;  %radial distance 
dr  = Dr/Nr;                 
r   = nr*dr;                 

% angular vector
Nth = Nr;
nth = -Nth/2+1:1:Nth/2;
Dth = 2*pi;
dth = Dth/Nth;
th  = nth*dth;



%waist of laguerre
waistL = 1050;
xt1    = -20;
yt1    = 0;

obst   = waistL/4.7;
xt2    = 110;
yt2    = 0;

figure(1)
subplot(1,2,1)
imagesc(x,x,abs(S.ListFiles{1}.im))
axis square
xlabel('microns')
ylabel('microns')
title('z = 0')
hold on
plotCircle(xt1,yt1,waistL);
plotCircle(xt2,yt2,obst);
hold off

% create analytic beam

Wavelength          = 0.6328;
PropagationDistance = 0;
l                   = 12;
p                   = 0;
InitialWaist        = waistL/sqrt(2*l+p+1);

LPinZ0 = LaguerreParameters(PropagationDistance...
                           ,InitialWaist...
                           ,Wavelength...
                           ,l...
                           ,p);
                     
LG     = LaguerreBeam(R,TH,LPinZ0);


lo      = (LPinZ0.LaguerreWaist)/4.7;  % size of obstruction in terms of waist of Laguerre
xto     = xt2;                         % traslation of obstruction in x-axis
yto     = yt2;                         % traslation of onstruction in y-axis
[~,rho] = cart2pol(X-xto,X'-yto);      % Convert this in polar coordinates
obo     = double(rho<=lo);             % Create Obstruction   

g       = (LG.OpticalFieldLaguerre).*(1-obo);


gh1     = HankelLaguerre(R,TH,LPinZ0,1);
gh2     = HankelLaguerre(R,TH,LPinZ0,2);

gh1     = (gh1.OpticalFieldLaguerre).*(1-obo);
gh2     = (gh2.OpticalFieldLaguerre).*(1-obo);


figure(1)
subplot(1,2,2)
imagesc(x,x,abs(g).^2)
axis square
xlabel('microns')
ylabel('microns')
title('z = 0')
hold on
plotCircle(0,0,LPinZ0.LaguerreWaist);
plotCircle(xt2,yt2,lo);
hold off

TotalRays = 100;          % Number of rays
Nz = 28;
rayH1(Nz) = CylindricalRay();
rayH2(Nz) = CylindricalRay();

for point_index = 1 : TotalRays
    % Cartersian coordinates of point in circunference of obstruction
    xi = xto + lo*cos(point_index*(2*pi)/(TotalRays))+.001; 
    yi = yto + lo*sin(point_index*(2*pi)/(TotalRays))+.001;
    zi = 0;
    % assign coordinate to Optical Rays in z = 0, i.e index_z = 1  
    [rayH1(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH1(1),point_index,1);
    [rayH2(1)] = assignCoordinates2CylindricalRay(xi,yi,zi,rayH2(1),point_index,2);
    
end

% Initial Field with rays in this init conditions
figure(3) 
plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
plotRays(rayH1(1),'r')

dz = 9020;
Nz = 28;
nz = 0:Nz-1;
Dz = Nz*dz;
z  = nz*dz;


% Diferential vector in cilindrycal coordinates
difr = [dr,dth,dz];

% paraxial propagator 
prop    = paraxialPropagator(Kx,Kx',LPinZ0.k,dz);

figure(2)
imagesc(angle(prop))


LPinZ = LaguerreParameters(z...
                          ,InitialWaist...
                          ,Wavelength...
                          ,l...
                          ,p);

for z_index = 1:length(z)-1 % propagation with respect to z
% loop of each component in z

  G = fftshift(fft2(ifftshift(g)));...*exp(-1j.*(u(1)).*(Kx)).*exp(-1j.*(u(1)).*(Kx'));
    %obtain new propagated field
  g = fftshift(ifft2(ifftshift(G.*prop)));...*


  G = fftshift(fft2(ifftshift(gh1)));...*exp(-1j.*(u(1)).*(Kx)).*exp(-1j.*(u(1)).*(Kx'));
    %obtain new propagated field
  gh1 = fftshift(ifft2(ifftshift(G.*prop)));...*

  G = fftshift(fft2(ifftshift(gh2)));...*exp(-1j.*(u(1)).*(Kx)).*exp(-1j.*(u(1)).*(Kx'));
    %obtain new propagated field
  gh2 = fftshift(ifft2(ifftshift(G.*prop)));...*

  %saving transversal fields
  gx(:,z_index+1) = g(Nx/2+1,:);
  gy(:,z_index+1) = g(:,Nx/2+1);  

  
  
  % propagation distance 
  zi     = z(z_index);
  % calculating Laguerre Parameters in zi
  LPinZi = LaguerreParameters(zi,InitialWaist,Wavelength,l,p);   
  %% rays 
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
  

  fig3 = figure(3);
  %fig3.Position = [408 4 1037 973];
  subplot(2,2,3)
  plotOpticalField(x,x,abs(g).^2,mapgreen,'microns');
  axis square
  plotRays(rayH1(z_index+1),'r')
  plotRays(rayH2(z_index+1),'y')
  title(['Analytic Field, z = ', num2str(z(z_index)), ' of ', num2str(z(end)), ' microns'])
  subplot(2,2,1)
  imagesc(x,x,abs(S.ListFiles{z_index}.im))
  axis square
  % Plot propagated points of H1 and H2
  plotRays(rayH1(z_index+1),'r')
  plotRays(rayH2(z_index+1),'y')
  title(['Experimental Iamge, z = ', num2str(z(z_index)), ' of ', num2str(z(end)), ' microns'])
  subplot(2,2,2)
  plotOpticalField(x,x,log(abs(gh1)),mapgreen,'microns');
  %plotRays(rayH1(z_index+1),'r')
  axis square
  subplot(2,2,4)
  plotOpticalField(x,x,log(abs(gh2)),mapgreen,'microns');
  %plotRays(rayH2(z_index+1),'y')
  axis square

end
                        
