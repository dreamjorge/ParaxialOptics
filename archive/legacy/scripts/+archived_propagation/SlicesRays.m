%%Hankel 11 slices
mapgreen = AdvancedColormap('kgg',256,[0 70 255]/255);  %color of beam


bb = W22o;
iindex = find(abs(bb)<=.000041);
 bb(iindex) = NaN;
close(figure(1))
figure (1)

plotPropagatedRays2(rayH11,rayH12,rayH21,rayH22)
hold on 

daspect([0.7,.1,.1]) 
axis tight 
view(44,16) 
camzoom(1.4) 
camproj perspective
axis off

zprop  = [0, (1/10)*RayleighDistance, (1/6)*RayleighDistance, (1/5)*RayleighDistance];
%zprop  = [0, 6*Dz/3 , Dz/2, 0.99*Dz];

hzprop = slice(z,x,y,abs(bb).^2,zprop,[],[]); 
hzprop(1).FaceColor = 'interp'; 
hzprop(2).FaceColor = 'interp';
hzprop(3).FaceColor = 'interp';
hzprop(4).FaceColor = 'interp';
hzprop(1).EdgeColor = 'none'; 
hzprop(2).EdgeColor = 'none'; 
hzprop(3).EdgeColor = 'none'; 
hzprop(4).EdgeColor = 'none'; 
colormap(mapgreen)

hold off
%
hzprop(1).FaceAlpha = 0.9;
hzprop(2).FaceAlpha = 0.9;
hzprop(3).FaceAlpha = 0.0;
hzprop(4).FaceAlpha = 0.9;

 xlim([0 1.02*(1/5)*RayleighDistance])
set(gcf, 'color', [0 0 0])
set(gca,'XColor','g')
set(gca,'YColor','g')
set(gca,'ZColor','g')
 set(gca, 'color', [0 0 0])
axis off
xlabel('\zeta')
ylabel('\eta')
zlabel('\xi')

%% Selfhealing Hermite in rays



bb = Wo;
iindex = find(abs(bb)<=.0009);
 bb(iindex) = NaN;
close(figure(1))
figure (1)

plotPropagatedRays2(rayH11,rayH12,rayH21,rayH22)
hold on 

daspect([1,.07,.07]) 
axis tight 
view(44,16) 
camzoom(1.4) 
camproj perspective
axis off

% zprop  = [0, (1/10)*RayleighDistance, (1/6)*RayleighDistance, (1/5)*RayleighDistance];
zprop  = [0, 6*Dz/3 , Dz/2, 0.99*Dz];

hzprop = slice(z,x,y,abs(bb),zprop,[],[]); 
hzprop(1).FaceColor = 'interp'; 
hzprop(2).FaceColor = 'interp';
hzprop(3).FaceColor = 'interp';
hzprop(4).FaceColor = 'interp';
hzprop(1).EdgeColor = 'none'; 
hzprop(2).EdgeColor = 'none'; 
hzprop(3).EdgeColor = 'none'; 
hzprop(4).EdgeColor = 'none'; 
colormap(mapgreen)

hold off
%
hzprop(1).FaceAlpha = 0.7;
hzprop(2).FaceAlpha = 0.7;
hzprop(3).FaceAlpha = 0.7;
hzprop(4).FaceAlpha = 0.7;

%  xlim([0 1.02*(1/5)*RayleighDistance])
set(gcf, 'color', [0 0 0])
set(gca,'XColor','g')
set(gca,'YColor','g')
set(gca,'ZColor','g')
 set(gca, 'color', [0 0 0])
axis off
xlabel('\zeta')
ylabel('\eta')
zlabel('\xi')




%%

fieldf = (W(:,floor((1/5)*Nz),:));
fieldf = reshape(fieldf,[Nx,Nx]);
figure(2)
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(fieldf),mapgreen,'n')
axis off