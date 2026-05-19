%% Legacy: figure 3d of selfhealing without obstruction
%field without obstruction
fieldf  = (Wo(:,floor(Nz),:));
fieldf  = reshape(fieldf,[Nx,Nx]);
%field with obstruction
fieldfw = (W(:,floor(Nz),:));
fieldfw = reshape(fieldfw,[Nx,Nx]);

%firt cut transversal
dtx0    = -300;
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

yvectorticks = [-6, (dtx0*dx)/InitialWaist, 0,(dtx1*dx)/InitialWaist,   6];
yticks([yvectorticks])
yticklabels({'-6','y_o','0','y_1','6'})
xticks([-6 0 6])
export_fig('SelfHealingHermite','-png','-transparent')

%%
close(figure(11))
fig11 = figure(11);
fig11.Position = [680   187   956   791];
plot(x/InitialWaist,abs(gw1).^2,'color',orange,'LineWidth',3.6)
hold on
plot(x/InitialWaist,abs(g1).^2,'-.','color','b','LineWidth',3.6)
xline( rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',3,'Color','m')
xline(-rayH11(end).xCoordinate(1)/InitialWaist,':','LineWidth',3,'Color','c')
xline( rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',3,'Color','c')
xline(-rayH22(end).xCoordinate(1)/InitialWaist,':','LineWidth',3,'Color','m')
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