% Legacy: SlicesHermite.m
%Script For Genereate Slices, we need run first MainHermite for obtain Wo
%Matrix
znorm = z;
xnorm = x;
ynorm = y;
xmin  = min(znorm(:));
xmax  = max(znorm(:)); 
ymin  = min(xnorm(:));  
ymax  = max(xnorm(:)); 
zmin  = min(xnorm(:));  
zmax  = max(xnorm(:));

% Introduce Nan Values on Marixf
bb         = Wo;
iindex     = find(abs(bb)<=.000007);
bb(iindex) = NaN;


close(figure(101))
fig = figure (101);
fig.Position = [1 31 1920 973];
plotPropagatedRays(rayH11,rayH12,rayH21,rayH22,1,1)
hold on 
daspect([1.5,.1,.1]) 
axis tight 
view(44,16) 
camzoom(1.4) 
camproj perspective
axis off
%%Correction of axis on Slices
aa = permute(bb,[3 2 1]);
%distances of propagation
zprop  = [0, 6*Dz/3 , Dz/2, 0.99*Dz];
hzprop = slice(znorm,ynorm,xnorm,abs(aa).^2,zprop,[],[]); 
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
export_fig('SelfHealingHermite3D','-png','-transparent')


%%

distances = [1,3,inf];

texts     = {'1/5','1/10','0'};


close(figure(800))
fig800 = figure(800);

kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = Wo(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(x,x,abs(gg1).^2,mapgreen,'','');
  axis square
  axis off
  plotRaysSquare(rayH12(index),'m',1,1);
  plotRaysSquare(rayH21(index),'y',1,1);
  plotRaysSquare(rayH11(index),'r',1,1);
  plotRaysSquare(rayH22(index),'c',1,1);
%   title(['$z$ = ', texts{kk}],'Interpreter','latex')
axis off
  kk = kk+1 ;

  export_fig(['HermitePropagation',num2str(jj)],'-png','-transparent')

  
end