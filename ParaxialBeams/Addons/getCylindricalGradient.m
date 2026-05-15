function [rayObject] = getCylindricalGradient(fr,...
                                              ftheta,...
                                              fz,...
                                              k,...
                                              difr,...
                                              rayObject) 
%% Function for calculate gradient in (x,y,z) coordinates in rayObject

  r      =  rayObject.rCoordinate;
  theta  =  rayObject.thetaCoordinate;
  z      =  rayObject.zCoordinate;
  
  tempdr         = num2cell(difr);
  [dr,dtheta,dz] = deal(tempdr{:});

  %partial derivatives 
  gr     = gradient(fr)/dr;
  gtheta = (1./r).*(gradient(ftheta)/dtheta);
  gz     = gradient(fz)/dz+k;
  N      = size(gr,2);

  rayObject.zrSlope  = gz(floor(z/dz+1))/gr(N/2+1+floor(r/dr));
  rayObject.zthSlope = gz(floor(z/dz+1))/gtheta(N/2+1+floor(theta/dtheta));
  rayObject.rthSlope = gr(floor(r/dr+1))/gtheta(N/2+1+floor(theta/dtheta));


end