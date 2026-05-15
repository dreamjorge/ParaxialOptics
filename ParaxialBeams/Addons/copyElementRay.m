function [rayOutput]= copyElementRay(rayInput,...
                                    index_point)
%% function for copy ray object
  
 
  rayOutput.xCoordinate    (index_point) = rayInput.xCoordinate    (index_point);
  rayOutput.yCoordinate    (index_point) = rayInput.yCoordinate    (index_point);
  rayOutput.zCoordinate    (index_point) = rayInput.zCoordinate    (index_point);
  rayOutput.rCoordinate    (index_point) = rayInput.rCoordinate    (index_point);
  rayOutput.thetaCoordinate(index_point) = rayInput.thetaCoordinate(index_point);
  
  if (index_point>1)
    rayOutput.zxSlope        (index_point) = rayInput.zxSlope        (index_point);
    rayOutput.zySlope        (index_point) = rayInput.zySlope        (index_point);
    rayOutput.xySlope        (index_point) = rayInput.xySlope        (index_point);
  else
    rayOutput.zxSlope        (index_point) = Inf;
    rayOutput.zySlope        (index_point) = Inf;
    rayOutput.xySlope        (index_point) = Inf;
  end
end