% Legacy: MaineLaguerreWithOutObstruction.m

%%          Script of Laguerre Beam (properties and propagation)
% adding path for classes and functions
addpath(fullfile('ParaxialBeams'))
addpath(fullfile('ParaxialBeams', 'Addons'))
addpath(fullfile('ParaxialBeams', 'Addons', 'export_fig-master'))

% Selecting green color for beam
mapgreen = AdvancedColormap('kgg',256,[0 100 255]/255);

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
LG    = eLaguerreBeam(RCoordinate,ThetaCoordinate,LPinZ0);
ginit = LG.OpticalFieldLaguerre;

pxyzo = max(abs(ginit(:)).^2);


% Plot of Field
figure(2)
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(ginit).^2,mapgreen,'$x/w_0$','$x/w_0$');
plotCircle(0,0,LPinZ0.LaguerreWaist/InitialWaist,'r',1.5);
I = abs(ginit);
sigmaeL(1)=sqrt(2*(trapz(y,trapz(x,I.*(X.^2+(X').^2),2)))./(trapz(y,trapz(x,I,2))));


%%  transversal propagation analytic
LPinZi  = copy(LPinZ0);

% distances for plot
zi      = [0, Dz/4,   Dz/3,   Dz/2, ...
              2*Dz/3, 3*Dz/4, Dz  ];
textdis = {'0','zR4','zR3','zR2','2zR3','3zR4','zR'};

for jj = 1 : numel(zi)
  
  LPinZi.zCoordinate = zi(jj);
  % Build new Optical Field
  LGBzi              = eLaguerreBeam(RCoordinate,ThetaCoordinate,LPinZi);
  % Optic Field
  g                  = LGBzi.OpticalFieldLaguerre;
  
  I = abs(g);
  seL=sqrt(2*(trapz(y,trapz(x,I.*(X.^2+(X').^2),2)))./(trapz(y,trapz(x,I,2))));

  fig3 = figure(3);
  fig3.Position = [680 406 802 572];
  plotOpticalField(x/InitialWaist,x/InitialWaist,abs(g).^1.6,mapgreen,'$x/w_o$','$y/w_o$');
%   colorbar
%      caxis([0 10e-4])
  % set(gca,'FontSize',18);
  export_fig(['eLaguerre',textdis{jj}],'-png','-transparent')
  plotCircle(0,0,seL(1)/InitialWaist,'r',1.5);
  export_fig(['eLaguerre',textdis{jj},'Waist'],'-png','-transparent')
  
end


%%                         Physical Propagation
% paraxial propagator 
prop    = paraxialPropagator(Kx,Kx',LPinZ0.k,dz);

figure(5)
imagesc(u,u,(angle(prop)))
title('Propagator')
%field to propagate
g = ginit;

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
  W (:,z_index,:) = g;
  %%

  fig = figure(6);
%   fig.Position = [-1349 147 813 733];
  I = abs(g);
  sigmaeL(z_index)=sqrt(2*(trapz(y,trapz(x,I.*(X.^2+(X').^2),2)))./(trapz(y,trapz(x,I,2))));

  pxyz   = g(1,1);
  g(1,1) = pxyzo;
  plotOpticalField(x/InitialWaist,x/InitialWaist,abs(g).^2,mapgreen,'$x/w_0$','$x/w_0$');
  plotCircle(0,0,sigmaeL(z_index)/InitialWaist,'r',1.5);
  
  
  title(['z = ', num2str(z(z_index)/RayleighDistance), ' of ', num2str(Dz/RayleighDistance)],'Interpreter','latex')
  g(1,1) = pxyz;
  drawnow 
  hold on

  pause(0.01)

end

%%
close(figure(8))
fig = figure(8);
fig.Position = [680,558,1024,420];
imagesc(z/RayleighDistance,x/InitialWaist,abs(gx))
colormap(mapgreen)
xlabel('$z/z_R$','Interpreter','latex')
ylabel('$x/w_o$','Interpreter','latex')
export_fig('eLaguerreBeamXLateral','-png','-transparent')

hold on
plot(z(1:end-1)/RayleighDistance, sigmaeL/InitialWaist,'-.','Color','m','LineWidth',2)
plot(z(1:end-1)/RayleighDistance,-sigmaeL/InitialWaist,'-.','Color','m','LineWidth',2)
hold off
export_fig('eLaguerreBeamXLateralRays','-png','-transparent')