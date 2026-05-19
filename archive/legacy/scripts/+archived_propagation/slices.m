% Legacy: slices.m
% slices aproach
znorm = z;
xnorm = x;
ynorm = y;

xmin   = min(znorm(:));
xmax   = max(znorm(:)); 
ymin   = min(xnorm(:));  
ymax   = max(xnorm(:)); 
zmin   = min(xnorm(:));  
zmax   = max(xnorm(:));

bb         = Wo;
 iindex     = find(abs(bb)<=.0005);
 bb(iindex) = NaN;

% hslice = surf(linspace(xmin,xmax,100),linspace(ymin,ymax,100),zeros(100));
% rotate(hslice,[-1,0,0],-45)
% 
% xd1     = get(hslice,'XData');
% yd1     = get(hslice,'YData');
% zd1     = get(hslice,'ZData');
% 
% delete(hslice)
% 
% hslice = surf(linspace(xmin,xmax,100),linspace(ymin,ymax,100),zeros(100));
% rotate(hslice,[-1,0,0],45)


% xd2     = get(hslice,'XData');
% yd2     = get(hslice,'YData');
% zd2     = get(hslice,'ZData');
% 
% delete(hslice)
close(figure(101))
figure (101)
%plotPropagatedRays(rayH11,rayH12,rayH21,rayH22)
%slice to 45 degrees
% h45 = slice(z,x,y,abs(Wo),xd1,yd1,zd1); 
% h45.FaceColor = 'interp'; 
% h45.EdgeColor = 'none'; 
% h45.DiffuseStrength = 0.15;

plotPropagatedRays(rayH11,rayH12,rayH21,rayH22,1,1)
hold on 
%slice to -45 degrees
% h_45 = slice(z,x,y,abs(Wo),xd2,yd2,zd2); 
% h_45.FaceColor = 'interp'; 
% h_45.EdgeColor = 'none'; 
% h_45.DiffuseStrength = 0.15;

%Border of slices
% hxmin = slice(znorm,xnorm,ynorm,abs(bb),xmin,[],[]); 
% hxmin.FaceColor = 'interp'; 
% hxmin.EdgeColor = 'none'; 
% hxmax = slice(znorm,xnorm,ynorm,abs(bb),xmax,[],[]); 
% hxmax.FaceColor = 'interp'; 
% hxmax.EdgeColor = 'none';
% hy = slice(znorm,xnorm,ynorm,abs(bb),[],ymax,[]); 
% hy.FaceColor = 'interp'; 
% hy.EdgeColor = 'none';  
% 
% hz = slice(znorm,xnorm,ynorm,abs(bb),[],[],zmin); 
% hz.FaceColor = 'interp'; 
% hz.EdgeColor = 'none';

%% obstruction 
% xobs = [-0.5*lx,0,0.5*lx]; 
% yobs = [-0.5*ly,0.5,0.5*ly];
% 
% hxobs = slice(z,x,y,abs(Wo),[],xobs,[]); 
% hxobs(1).FaceColor = 'interp'; 
% hxobs(2).FaceColor = 'interp'; 
% hxobs(3).FaceColor = 'interp'; 
% hxobs(1).EdgeColor = 'none'; 
% hxobs(2).EdgeColor = 'none';
% hxobs(3).EdgeColor = 'none';
% 
% hyobs = slice(z,x,y,abs(Wo),[],[],yobs); 
% hyobs(1).FaceColor = 'interp'; 
% hyobs(2).FaceColor = 'interp';
% hyobs(3).FaceColor = 'interp';
% hyobs(1).EdgeColor = 'none'; 
% hyobs(2).EdgeColor = 'none'; 
% hyobs(3).EdgeColor = 'none'; 


daspect([1.5,.1,.1]) 
axis tight 
view(44,16) 
camzoom(1.4) 
camproj perspective
axis off



%distances of propagation
zprop  = [0, 6*Dz/3 , Dz/2, 0.99*Dz];
hzprop = slice(znorm,xnorm,ynorm,abs(bb),zprop,[],[]); 
hzprop(1).FaceColor = 'interp'; 
hzprop(2).FaceColor = 'interp';
hzprop(3).FaceColor = 'interp';
hzprop(4).FaceColor = 'interp';
hzprop(1).EdgeColor = 'none'; 
hzprop(2).EdgeColor = 'none'; 
hzprop(3).EdgeColor = 'none'; 
hzprop(4).EdgeColor = 'none'; 
colormap(mapgreen)


% hzprop(3).AlphaData = abs(Wo(:,64,:));
% hzprop(4).AlphaData = abs(Wo(:,128,:));
hold off
%% values of Alpha
% planes rotates 45 -45
% h45.FaceAlpha       = 0.0;
% h_45.FaceAlpha      = 0.0;
% % slices on borders 
% hxmin.FaceAlpha     = 1; 
% hxmax.FaceAlpha     = 1; 
% hy.FaceAlpha        = 0;
% hz.FaceAlpha        = 0; 
% slices on obstruction
% hxobs(1).FaceAlpha  = 0.0;
% hxobs(2).FaceAlpha  = 0.0; % x axis
% hxobs(3).FaceAlpha  = 0.0;
% hyobs(1).FaceAlpha  = 0.0;
% hyobs(2).FaceAlpha  = 0.0;
% hyobs(3).FaceAlpha  = 0.0;

hzprop(1).FaceAlpha = 0.8;
hzprop(2).FaceAlpha = 0;
hzprop(3).FaceAlpha = 0.8;
hzprop(4).FaceAlpha = 0.8;

xlim([0 1.1*Dz])
 set(gcf, 'color', [0 0 0])
set(gca,'XColor','g')
set(gca,'YColor','g')
set(gca,'ZColor','g')
set(gca, 'color', [0 0 0])
axis on
xlabel('$\zeta$')
ylabel('$\eta$')
zlabel('$\xi$')
% set(gcf,'Color',[1 1 1])
%% w
fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);
figure(2)
plotOpticalField(x,x,abs(fieldfw),mapgreen,'n')
axis off

hold on
plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,1,1,floor(Nz))
  hold off
%%
%% w
fieldf = (Wo(:,floor(Nz),:));
fieldf = reshape(fieldf,[Nx,Nx]);
figure(2)
plotOpticalField(x,x,abs(fieldf),mapgreen,'n')
axis off

hold on
plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,1,1,floor(Nz))
  hold off
  

  %%
  g  = fieldf(512,:);
  gw = fieldfw(512,:);
  figure(3)
  plot(x/InitialWaist,abs(g),'.')
  hold on
  plot(x/InitialWaist,abs(gw),'-')
  hold off
  legend('Obstructed Hermite Gauss','Hermite Gauss')
  title('z = (Rayleigh Distance)/2')
  xlabel('x at y = 0.5*\sigma_y')
  ylabel('Amplitude')
  
  %%
  dtx = 00;
  
  g  = fieldf(512+dtx,:);
  gw = fieldfw(512+dtx,:);
%   close(figure(3))
  figure(3)
  p(1) = plot(x,abs(g),'.');
  hold on
  p(2) = plot(x,abs(gw),'-');
  hold off
  set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

  title('z = (Rayleigh Distance)/2')
  xlabel('x at y = 0')
  ylabel('Amplitude')
  xline(rayH11(end).xCoordinate(1))
  xline(-rayH11(end).xCoordinate(1))
  xline(rayH22(end).xCoordinate(1))
  xline(-rayH22(end).xCoordinate(1))
    legend([p(1),p(2)],{'Obstructed Hermite Gauss','Hermite Gauss'})
%   set(get(get(p(3),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%%
  dtx = 0;
  
  g  = fieldf(:,512+dtx);
  gw = fieldfw(:,512+dtx);
%   close(figure(3))
  figure(3)
  p(1) = plot(x,abs(g),'.');
  hold on
  p(2) = plot(x,abs(gw),'-');
  hold off
  set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

  title('z = (Rayleigh Distance)/2')
  xlabel('y at x = 0')
  ylabel('Amplitude')
  xline(rayH11(end).yCoordinate(3))
  xline(-rayH11(end).yCoordinate(3))
  xline(rayH22(end).yCoordinate(3))
  xline(-rayH22(end).yCoordinate(3))
    legend([p(1),p(2)],{'Obstructed Hermite Gauss','Hermite Gauss'})
    
    
%% last figure on paper
 
morado = [0.3010, 0.7450, 0.9330];

close(figure(2))
fig2 = figure(2); 
% set(gca,'Color','k')
% set(gcf, 'color', [0 0 0])

fig2.Position = [537 381 1106 597];
ha  = tight_subplot(2,2,[.01 .01],[.1 .1],[.1 .07]);

dtx1 = 135;

fieldf  = (Wo(:,floor(Nz),:));
fieldf  = reshape(fieldf,[Nx,Nx]);

fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);


axes(ha(1))
% set(gca,'Color','k')
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(fieldf),mapgreen,'n')

% plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,1,1,floor(Nz))
% xline(x(512+dtx1),':','color','r','LineWidth',2)

hold on
plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,InitialWaist,InitialWaist,z_index)
hold on
dtx0 = -20;
g0   = fieldf(512+dtx0,:);
p(1) = plot(x/InitialWaist,80*abs(g0)+dtx0/InitialWaist,'.','color','r');
yline(dtx0/InitialWaist,':','color','r','LineWidth',2)
ha(1).Color = 'blue';

g1   = fieldf(512+dtx1,:);
p(1) = plot(x/InitialWaist,100*abs(g1)+dtx1/InitialWaist,'.','color','b');
yline(dtx1/InitialWaist,':','color','b','LineWidth',2)
% p(2) = plot(x,abs(gw),'-');

hold off


axes(ha(3))
% set(gca,'Color','k')
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(fieldfw),mapgreen,'n')

hold on
% plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,InitialWaist,InitialWaist,z_index)
hold on

gw0   = fieldfw(512+dtx0,:);
p(1) = plot(x/InitialWaist,100*abs(gw0)+dtx0/InitialWaist,'.','color',morado);
yline(dtx0/InitialWaist,':','color','b','LineWidth',2)


gw1   = fieldfw(512+dtx1,:);
p(1) = plot(x/InitialWaist,100*abs(gw1)+dtx1/InitialWaist,'.','color','m');
yline(dtx1/InitialWaist,':','color','m','LineWidth',2)

hold off

axes(ha(4))

plot(x/InitialWaist,abs(gw0),'color',morado,'LineWidth',2)
hold on
plot(x/InitialWaist,abs(g0),'-.','color','r','LineWidth',2)
pbaspect([2.5 1 1])
% xline( rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','m')
% xline(-rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','c')
% xline( rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','c')
% xline(-rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','m')
hold off
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('Amplitude')
% set(gca,'Color','k')
% set(gcf,'color', [0 0 0])

axes(ha(2))
plot(x/InitialWaist,abs(gw1),'color','m','LineWidth',2)
hold on
plot(x/InitialWaist,abs(g1),'-.','color','b','LineWidth',2)
xline( rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','m')
xline(-rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','c')
xline( rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','c')
xline(-rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',1.7,'Color','m')
pbaspect([2.5 1 1])
hold off
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('Amplitude')
% set(gca,'Color','k')
% set(gcf,'color', [0 0 0])

% set(ha(1),'ycolor','w')
% set(ha(2),'ycolor','w')
% set(ha(3),'ycolor','w')
% set(ha(4),'ycolor','w')
% set(ha(1),'xcolor','w')
% set(ha(2),'xcolor','w')
% set(ha(3),'xcolor','w')
% set(ha(4),'xcolor','w')

export_fig('Selfhealingv5','-png','-transparent')

%% figure 3d of selfhealing
%field without obstruction
fieldf  = (Wo(:,floor(Nz),:));
fieldf  = reshape(fieldf,[Nx,Nx]);
%field with obstruction
fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);

%firt cut transversal
dtx0    = -20;
g0      = fieldf(512+dtx0,:);
gw0     = fieldfw(512+dtx0,:);

%second cut transversal
dtx1    = 135;
g1      = fieldf(512+dtx1,:);
gw1     = fieldfw(512+dtx1,:);

%vector for translation in axis
xo = zeros(1,numel(x));

%build points for vertical lines
P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts1 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts2 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts3 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts4 = [P1; P2];

P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts11 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts21 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts31 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts41 = [P1; P2];


%plot figure
fig10 = figure(10);
fig10.Position = [789, 360, 783, 577];
morado = [165,60,246]/256;
imagesc(x/InitialWaist,y/InitialWaist,abs(fieldf))
colormap(mapgreen)
set(gca,'YDir','normal')
hold on
plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,0.001*abs(g1),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,0.001*abs(gw1),'-.','color','b','LineWidth',1.7)
plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,0.001*abs(g0),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,0.001*abs(gw0),'-.','color','b','LineWidth',1.7)
plot3(pts1(:,1) , pts1(:,2) , pts1(:,3) ,'LineWidth',1.5,'color','y')
plot3(pts2(:,1) , pts2(:,2) , pts2(:,3) ,'LineWidth',1.5,'color','y')
plot3(pts3(:,1) , pts3(:,2) , pts3(:,3) ,'LineWidth',1.5,'color','y')
plot3(pts4(:,1) , pts4(:,2) , pts4(:,3) ,'LineWidth',1.5,'color','y')
plot3(pts11(:,1), pts11(:,2), pts11(:,3),'LineWidth',1.5,'color','y')
plot3(pts21(:,1), pts21(:,2), pts21(:,3),'LineWidth',1.5,'color','y')
plot3(pts31(:,1), pts31(:,2), pts31(:,3),'LineWidth',1.5,'color','y')
plot3(pts41(:,1), pts41(:,2), pts41(:,3),'LineWidth',1.5,'color','y')
plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,InitialWaist,InitialWaist,z_index)
hold off
view(29,77)
axis tight 
% camproj perspective
set(gcf, 'color', [0 0 0])
set(gca, 'color', [0 0 0])
set(gca,'XColor',[1 1 1]);
set(gca,'YColor',[1 1 1]);
set(gca,'ZColor',[1 1 1]);
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('$y$','Interpreter','latex','FontSize',18)
zlabel('Amplitude','Interpreter','latex','FontSize',15)
export_fig('SelfHealingHermite','-png','-transparent')


%% figure 3d of selfhealing
%field without obstruction
fieldf  = (Wo(:,floor(Nz),:));
fieldf  = reshape(fieldf,[Nx,Nx]);
%field with obstruction
fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);

%firt cut transversal
dtx0    = -20;
g0      = fieldf(512+dtx0,:);
gw0     = fieldfw(512+dtx0,:);

%second cut transversal
dtx1    = 135;
g1      = fieldf(512+dtx1,:);
gw1     = fieldfw(512+dtx1,:);

%vector for translation in axis
xo = zeros(1,numel(x));

%build points for vertical lines
P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts1 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts2 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts3 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts4 = [P1; P2];

P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts11 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts21 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts31 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts41 = [P1; P2];


%plot figure
fig10 = figure(10);
fig10.Position = [789, 360, 783, 577];
morado    = [165,60,246]/256;
greenblue = [0,255,255]/256;
orange    = 1 - [31, 68, 249]/256;


imagesc(x/InitialWaist,y/InitialWaist,abs(fieldfw))
colormap(mapgreen)
set(gca,'YDir','normal')
hold on
% plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,100*abs(g1),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,abs(gw1),'-','color',orange,'LineWidth',1.7)
% plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,100*abs(g0),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,abs(gw0),'-','color',greenblue,'LineWidth',1.7)
hold off
view(27,80)
axis tight 

xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('$y$','Interpreter','latex','FontSize',18)
zlabel('Amplitude','Interpreter','latex','FontSize',15)
% yyaxis left

yvectorticks = [-5, (dtx0*dx)/InitialWaist, (dtx1*dx)/InitialWaist,   5];
yticks([yvectorticks])
yticklabels({'-5','y_o','y_1','5'})

export_fig('SelfHealingHermite','-png','-transparent')


%% figure 3d of selfhealing without obstruction
%field without obstruction
fieldf  = (Wo(:,floor(Nz),:));
fieldf  = reshape(fieldf,[Nx,Nx]);
%field with obstruction
fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);

%firt cut transversal
dtx0    = -20;
g0      = fieldf(512+dtx0,:);
gw0     = fieldfw(512+dtx0,:);

%second cut transversal
dtx1    = 135;
g1      = fieldf(512+dtx1,:);
gw1     = fieldfw(512+dtx1,:);

%vector for translation in axis
xo = zeros(1,numel(x));

%build points for vertical lines
P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts1 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts2 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts3 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx0)/InitialWaist,1.5];
pts4 = [P1; P2];

P1   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
% Their vertial concatenation is what you want
pts11 = [P1; P2];

P1   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH11(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts21 = [P1; P2];

P1   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts31 = [P1; P2];

P1   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,0];
P2   = [-rayH22(end).xCoordinate(1)/InitialWaist,(dtx1)/InitialWaist,1.5];
pts41 = [P1; P2];


%plot figure
fig10 = figure(10);
fig10.Position = [789, 360, 783, 577];
morado    = [165,60,246]/256;
greenblue = [0,255,255]/256;
orange    = 1 - [31, 68, 249]/256;


imagesc(x/InitialWaist,y/InitialWaist,abs(fieldf).^2)
colormap(mapgreen)
set(gca,'YDir','normal')
hold on
% plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,100*abs(g1),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx1*dx)/InitialWaist,abs(g1).^2,'-','color','b','LineWidth',3)
% plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,100*abs(g0),'color','r','LineWidth',1.5)
plot3(x/InitialWaist,xo+(dtx0*dx)/InitialWaist,abs(g0).^2,'-','color','r','LineWidth',3)
plotPropagatedRaysInZ(rayH11,rayH12,rayH21,rayH22,InitialWaist,InitialWaist,z_index)

hold off
view(27,80)
axis tight 
xlabel('$x$','Interpreter','latex','FontSize',18)
ylabel('$y$','Interpreter','latex','FontSize',18)
zlabel('Intensity','Interpreter','latex','FontSize',15)
% yyaxis left

yvectorticks = [-5, (dtx0*dx)/InitialWaist, (dtx1*dx)/InitialWaist,   5];
yticks([yvectorticks])
yticklabels({'-5','y_o','y_1','5'})

export_fig('SelfHealingHermite','-png','-transparent')

%%
close(figure(11))
fig11 = figure(11);
fig11.Position = [680   187   956   791];
plot(x/InitialWaist,abs(gw1).^2,'color',orange,'LineWidth',3)
hold on
plot(x/InitialWaist,abs(g1).^2,'-.','color','b','LineWidth',3)
xline( rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',2,'Color','m')
xline(-rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',2,'Color','c')
xline( rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',2,'Color','c')
xline(-rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',2,'Color','m')
pbaspect([2.5 1 1])
hold off
xlabel('$x$','Interpreter','latex','FontSize',22)
ylabel('Intensity','Interpreter','latex','FontSize',22)
set(gca,'FontSize',18);
export_fig('SelfHealingHermite1','-png','-transparent')
fig12 = figure(12);
fig12.Position = [680   187   956   791];
plot(x/InitialWaist,abs(gw0).^2,'color',greenblue,'LineWidth',3)
hold on
plot(x/InitialWaist,abs(g0).^2,'-.','color','r','LineWidth',3)
pbaspect([2.5 1 1])
hold off 
xlabel('$x$','Interpreter','latex','FontSize',22)
ylabel('Intensity','Interpreter','latex','FontSize',22)
set(gca,'FontSize',18);
export_fig('SelfHealingHermite2','-png','-transparent')


%%
dtx  = 00;
g    = fieldf(512+dtx,:);
gw   = fieldfw(512+dtx,:);
p(1) = plot(x,abs(g),'.');
hold on
p(2) = plot(x,abs(gw),'-');
hold off
set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%title('$z = \frac{z_R}{2}$','Interpreter','latex','FontSize',18)
xlabel('$y$ at $x = 0$','Interpreter','latex','FontSize',18)
ylabel('Amplitude')
xline(rayH11(end).xCoordinate(1),':','color','r','LineWidth',2)
xline(-rayH11(end).xCoordinate(1),':','color','m','LineWidth',2)
xline(rayH22(end).xCoordinate(1),':','color','m','LineWidth',2)
xline(-rayH22(end).xCoordinate(1),':','color','r','LineWidth',2)
%legend([p(1),p(2)],{'Obstructed Hermite Gauss','Hermite Gauss'})

axes(ha(3))
g    = fieldf(512+dtx1,:);
gw   = fieldfw(512+dtx1,:);
p(1) = plot(x,abs(g),'.');
hold on
p(2) = plot(x,abs(gw),'-');

set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(p(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%title('$z = \frac{z_R}{2}$','Interpreter','latex','FontSize',18)
xlabel(['$y$ at $x =',num2str(x(512+dtx1)),'$'],'Interpreter','latex','FontSize',18)
ylabel('Amplitude')
xline(rayH11(end).xCoordinate(1),':','color','r','LineWidth',2)
xline(-rayH11(end).xCoordinate(1),':','color','m','LineWidth',2)
xline(rayH22(end).xCoordinate(1),':','color','m','LineWidth',2)
xline(-rayH22(end).xCoordinate(1),':','color','r','LineWidth',2)
legend([p(1),p(2)],{'Obstructed Hermite Gauss','Hermite Gauss'})
hold off