%% Legacy:                      Main Hermite
% Ugalde-Ontiveros J.A. 
%% add path for classes and functions
clear all
repoRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(repoRoot);
setpaths();
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

%% Hankel 1D

HermiteInitialWaistX = HermiteParametersz0.HermiteWaistX;
HermiteInitialWaistY = HermiteParametersz0.HermiteWaistY;
HermiteInitialWaist  = HermiteParametersz0.HermiteWaist;
PhiPhase             = HermiteParametersz0.PhiPhase;
% for x-direction
InitialWaist         = HermiteParametersz0.InitialWaist;
q                    = ( 1./HermiteParametersz0.Radius-1i./(HermiteParametersz0.Waist).^2);

[Hx,NHx]             = HermiteParameters.getHermiteSolutions(nu,sqrt(1i*q).*x);

GaussX               = GaussianBeam(x,HermiteParametersz0).OpticalField;
Hx                   = Hx.*GaussX.*exp(1i*PhiPhase);
NHx                  = NHx.*GaussX.*exp(1i*PhiPhase);

H1x                  = Hx+1j*NHx;
H2x                  = Hx-1j*NHx;

% for y-direction
[Hy,NHy]             = HermiteParameters.getHermiteSolutions(mu,sqrt(1i*q).*x);

% Hermite Gauss 1D and Hankel Hermite Gauss 
PhiPhase             = HermiteParametersz0.PhiPhase;
GaussX               = GaussianBeam(x,HermiteParametersz0).OpticalField;
Hy                   = Hy .*GaussX.*exp(1i*PhiPhase);
NHy                  = NHy.*GaussX.*exp(1i*PhiPhase);

H1y                  = Hy+1i*NHy;
H2y                  = Hy-1i*NHy;



%% build Hankels 2D without trunc
H11 = (H1y')*(H1x);
H12 = (H2y')*(H1x);
H21 = (H1y')*(H2x);
H22 = (H2y')*(H2x);

%% phases
close(figure(2))
fig2 = figure(2);
fig2.Position = [680 273 721 705];
ha = tight_subplot(2,2,[.01 .03],[.06 .05],[.1 .09]);
axes(ha(1))
plotOpticalField(x/InitialWaist,x/InitialWaist,(angle(H22)),parula,'');
title('$\psi_{n,m}^{1,1}$','interpreter','latex','FontSize',10)
ha(1).XAxis.Visible = 'off';
axes(ha(2))
plotOpticalField(x/InitialWaist,x/InitialWaist,(angle(H21)),parula,'');
title('$\psi_{n,m}^{1,2}$','interpreter','latex','FontSize',10)
ha(2).XAxis.Visible = 'off';
ha(2).YAxis.Visible = 'off';
%ha(2).YAxisLocation = 'right';
axes(ha(3))
plotOpticalField(x/InitialWaist,x/InitialWaist,(angle(H12)),parula,'');
title('$\psi_{n,m}^{2,1}$','interpreter','latex','FontSize',10)
%ha(3).YAxis.Visible = 'off';
axes(ha(4))
plotOpticalField(x/InitialWaist,x/InitialWaist,(angle(H11)),parula,'');
ha(4).YAxisLocation = 'right';
ha(4).YAxis.Visible = 'off';
title('$\psi_{n,m}^{2,2}$','interpreter','latex','FontSize',10)
sgtitle('Phase of Hankels')
cb = colorbar;
cb.Location = 'eastoutside';
cb.Position =  [0.9490    0.0598    0.0255    0.8755];
export_fig('ImagesThesis/PhasesHankels','-png','-transparent')

%% trunc
SupGaussX = exp(-(sqrt(2)*x./(HermiteInitialWaistX)).^(50)); 
NHx       = NHx.*SupGaussX;

H1x       = Hx+1j*NHx;
H2x       = Hx-1j*NHx;


SupGaussY = exp(-(sqrt(2)*y./(HermiteInitialWaistY)).^50);
NHy       = NHy.*SupGaussY;
H1y       = Hy+1i*NHy;
H2y       = Hy-1i*NHy;

H11 = (H1y')*(H1x);
H12 = (H2y')*(H1x);
H21 = (H1y')*(H2x);
H22 = (H2y')*(H2x);

%% plots for x
close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hx),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGauss1SolutionX','-png','-transparent')

close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(NHx),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$NH_n$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGauss2SolutionX','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(H1x),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$HH_n^{1}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussHankel1SolutionX','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(H2x),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$HH_n^{2}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussHanke2SolutionX','-png','-transparent')


close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hx),'LineWidth',1.6)
hold on
plot(x/(HermiteParametersz0.Waist),abs(NHx),'--','LineWidth',1.6)
plot(x/(HermiteParametersz0.Waist),abs(H1x),'-.','LineWidth',1.6)
hold off
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$','$NH_n$','$HH_n^{1}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussSolutions1X','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hx),'LineWidth',1.6)
hold on
plot(x/(HermiteParametersz0.Waist),abs(NHx),'--','LineWidth',1.6)
plot(x/(HermiteParametersz0.Waist),abs(H2x),'-.','LineWidth',1.6)
hold off
xlim([-7 7])
ylim([0 .019])
xlabel('$\xi$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$','$NH_n$','$HH_n^{2}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussSolutions2X','-png','-transparent')

%% plots for y
close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hy),'LineWidth',1.6)
xlim([-7 7])
% ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGauss1SolutionY','-png','-transparent')

close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(NHy),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$NH_n$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGauss2SolutionY','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(H1y),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$HH_n^{1}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussHankel1SolutionY','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(H2y),'LineWidth',1.6)
xlim([-7 7])
ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$HH_n^{2}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussHanke2SolutionY','-png','-transparent')

close(figure(1))
fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hy),'LineWidth',1.6)
hold on
plot(x/(HermiteParametersz0.Waist),abs(NHy),'--','LineWidth',1.6)
plot(x/(HermiteParametersz0.Waist),abs(H1y),'-.','LineWidth',1.6)
hold off
xlim([-7 7])
ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$','$NH_n$','$HH_n^{1}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussSolutions1Y','-png','-transparent')

fig1          = figure(1);
fig1.Position = [609 206 945 348];
plot(x/(HermiteParametersz0.Waist),abs(Hy),'LineWidth',1.6)
hold on
plot(x/(HermiteParametersz0.Waist),abs(NHy),'--','LineWidth',1.6)
plot(x/(HermiteParametersz0.Waist),abs(H2y),'-.','LineWidth',1.6)
hold off
xlim([-7 7])
% ylim([0 .019])
xlabel('$\eta$','Interpreter','latex')
ylabel('Amplitude')
leg1=legend('$H_n$','$NH_n$','$HH_n^{2}$');
set(leg1,'Interpreter','latex');
export_fig('ImagesThesis/hankelHermiteGaussSolutions2Y','-png','-transparent')

%% abs of hankels

close(figure(3))
fig3 = figure(3);
fig3.Position = [680 164 721 814];
ha = tight_subplot(2,2,[.01 .01],[.05 .01],[.1 .01]);
axes(ha(1))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21),mapgreen,'');
ha(1).XAxis.Visible = 'off';
ha(1).YAxisLocation = 'left';
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}|$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
axes(ha(2))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H11+H22),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
ha(2).XAxis.Visible = 'off';
ha(2).YAxis.Visible = 'off';
ha(2).YAxisLocation = 'right';
set(gca,'FontSize',18);
axes(ha(3))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
ha(3).YAxisLocation = 'left';
axes(ha(4))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11+H12),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{1,2}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
ha(4).YAxisLocation = 'right';
ha(4).YAxis.Visible = 'off';
set(gca,'FontSize',18);
% sgtitle('Superposition of Hankels','FontSize',18)
%saveas(gcf,'SuperpositionOfHankels.png')
export_fig('ImagesThesis/SuperpositionOfHankels','-png','-transparent')
%%
close(figure(4))
fig4 = figure(4);
fig4.Position = [680 164 721 814];
ha = tight_subplot(2,2,[.01 .01],[.05 .01],[.1 .01]);
axes(ha(1))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H21+H11),mapgreen,'');
ha(1).XAxis.Visible = 'off';
ha(1).YAxisLocation = 'left';
title('$|\psi_{n,m}^{2,1}+\psi_{n,m}^{1,1}|$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
axes(ha(2))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H21+H12),mapgreen,'');
title('$|\psi_{n,m}^{2,1}+\psi_{n,m}^{1,2}|$','interpreter','latex','FontSize',18)
ha(2).XAxis.Visible = 'off';
ha(2).YAxis.Visible = 'off';
ha(2).YAxisLocation = 'right';
set(gca,'FontSize',18);
axes(ha(3))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H12+H21),mapgreen,'');
title('$|\psi_{n,m}^{1,2}+\psi_{n,m}^{2,1}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
ha(3).YAxisLocation = 'left';
axes(ha(4))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11+H12),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{1,2}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
ha(4).YAxisLocation = 'right';
ha(4).YAxis.Visible = 'off';
set(gca,'FontSize',18);
% sgtitle('Superposition of Hankels','FontSize',18)
%saveas(gcf,'SuperpositionOfHankels.png')
export_fig('ImagesThesis/SuperpositionOfHankels2','-png','-transparent')

%% abs of combinations of hankels

close(figure(4))
fig4 = figure(4);
fig4.Position = [537 535 1067 443];
ha = tight_subplot(1,3,[.01 .01],[.05 .1],[.1 .07]);

axes(ha(1))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H11),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
ha(2).YAxisLocation = 'left';
set(gca,'FontSize',18);
axes(ha(2))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
ha(2).YAxis.Visible = 'off';
axes(ha(3))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11+H12),mapgreen,'');
title('$|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{1,2}+\psi_{n,m}^{2,2}|$','interpreter','latex','FontSize',18)
ha(3).YAxisLocation = 'right';
set(gca,'FontSize',18);
sgtitle('Superposition of Hankels','FontSize',18)
%saveas(gcf,'SuperpositionOfHankels.png')
export_fig('SuperpositionOfHankels2','-png','-transparent')




%% Hermite Gauss in z = 0
HGB   = eHermiteBeam(X,Y,HermiteParametersz0);
% copy of parameters
HPz   = copy(HermiteParametersz0);
% Changing parameters to vector z
HPz.zCoordinate = z;  
% Optic Field to propagate 
g     = HGB.OpticalFieldHermite;
% Plot of Function
close(figure(3))   
figure(3)

plotOpticalField(x/(HermiteParametersz0.Waist),x/(HermiteParametersz0.Waist),abs(g).^.5,mapgreen,'');

% xsq = [-HermiteInitialWaistX/2, HermiteInitialWaistX/2,HermiteInitialWaistX/2,-HermiteInitialWaistX/2];
% ysq = [-HermiteInitialWaistY/2,-HermiteInitialWaistY/2,HermiteInitialWaistY/2, HermiteInitialWaistY/2];
% plotSquare(xsq/InitialWaist,xsq/InitialWaist,'m')
recv = [-HermiteInitialWaistX/2 -HermiteInitialWaistY/2 HermiteInitialWaistX HermiteInitialWaistY];
rectangle('Position',sqrt(2)*recv/InitialWaist,'EdgeColor','b','LineWidth',2.5)
export_fig('ImagesThesis/HermiteGaussz0waist','-png','-transparent')

%% Hermite Gauss in z = 0
HGB   = eHermiteBeam(X,Y,HermiteParametersz0);
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
  HankeleHermite.getPropagateCartesianRays(rayH11(z_index),...
                                          x,y,...
                                          dr,...
                                          HPzi,...
                                          HPz,...
                                          HankelType); 
 
  HankelType = 12;                                      
  [rayH12(z_index+1)] = ...
  HankeleHermite.getPropagateCartesianRays(rayH12(z_index),...
                                           x,y,...
                                           dr,...
                                           HPzi,...
                                           HPz,...
                                           HankelType); 
                                        
  HankelType = 21;                                      
  [rayH21(z_index+1)] = ...
  HankeleHermite.getPropagateCartesianRays(rayH21(z_index),...
                                           x,y,...
                                           dr,...
                                           HPzi,...
                                           HPz,...
                                           HankelType);                                       
   
  HankelType = 22;                                       
  [rayH22(z_index+1)] = ...
  HankeleHermite.getPropagateCartesianRays(rayH22(z_index),...
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
