%% Legacy: hermite

distances = 2*[25/12,10/2,inf];

texts     = {'6/25','1/10','0'};


kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = Wo(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(scaleX*x,scaleX*x,abs(gg1).^1.5,mapgreen,'$x/w_o$','$y/wo$');
  axis square
  export_fig(['HermitePropagation',num2str(floor(jj))],'-png','-transparent')
  plotRaysSquare(rayH12(index),'m',scaleX,scaleX);
  plotRaysSquare(rayH21(index),'y',scaleX,scaleX);
  plotRaysSquare(rayH11(index),'r',scaleX,scaleX);
  plotRaysSquare(rayH22(index),'c',scaleX,scaleX);
%  title(['$z$ = ', texts{kk}],'Interpreter','latex')

  kk = kk+1 ;

  export_fig(['HermitePropagationRays',num2str(floor(jj))],'-png','-transparent')
  
  
end


%% h22


kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = W11o(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(scaleX*x,scaleX*x,abs(gg1).^1.5,mapgreen,'$x/w_o$','$y/wo$');
  axis square
  export_fig(['HermiteH22Propagation',num2str(floor(jj))],'-png','-transparent')

  plotRaysSquare(rayH21(index),'y',scaleX,scaleX);

  kk = kk+1 ;

  export_fig(['HermiteH22PropagationRays',num2str(floor(jj))],'-png','-transparent')
  
  
end

%% h11
kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = W22o(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(scaleX*x,scaleX*x,abs(gg1).^1.5,mapgreen,'$x/w_o$','$y/wo$');
  axis square
  export_fig(['HermiteH11Propagation',num2str(floor(jj))],'-png','-transparent')

   plotRaysSquare(rayH12(index),'m',scaleX,scaleX);

  kk = kk+1 ;

  export_fig(['HermiteH11PropagationRays',num2str(floor(jj))],'-png','-transparent')
  
  
end

%% h12
kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = W12o(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(scaleX*x,scaleX*x,abs(gg1).^1.5,mapgreen,'$x/w_o$','$y/wo$');
  axis square
  export_fig(['HermiteH21Propagation',num2str(floor(jj))],'-png','-transparent')
  plotRaysSquare(rayH22(index),'c',scaleX,scaleX);

  kk = kk+1 ;

  export_fig(['HermiteH21PropagationRays',num2str(floor(jj))],'-png','-transparent')
  
  
end

kk = 1;
for jj = distances
  
  index = floor(Nz/jj);
  if index == 0
    index = 1;
  end
  

  gg1 = W21o(:,index,:);
  gg1 = reshape(gg1,[Nx,Nx]);
  figure(1000)
  plotOpticalField(scaleX*x,scaleX*x,abs(gg1).^1.5,mapgreen,'$x/w_o$','$y/wo$');
  axis square
  export_fig(['HermiteH12Propagation',num2str(floor(jj))],'-png','-transparent')
  plotRaysSquare(rayH11(index),'r',scaleX,scaleX);

  kk = kk+1 ;

  export_fig(['HermiteH12PropagationRays',num2str(floor(jj))],'-png','-transparent')
  
  
end
