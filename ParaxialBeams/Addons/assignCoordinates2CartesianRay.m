function    [Ray]=assignCoordinates2CartesianRay(xi,yi,zi,Ray,point_index,hankelType)

  Ray.xCoordinate(point_index) = xi;
  Ray.yCoordinate(point_index) = yi;
  Ray.zCoordinate(point_index) = zi;
  
  %initial conditions of slopes
  Ray.xySlope(point_index) = Inf;
  Ray.zxSlope(point_index) = Inf;
  Ray.zySlope(point_index) = Inf;
  
  % hankel type of rays
  Ray.hankelType(point_index) = hankelType;
  
end
  