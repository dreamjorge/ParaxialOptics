function [rayOutput]= copyArrayRay2Ray(rayInput,...
                                       rayOutput,...
                                       index_point)
%% Function for copy ray data in index_point to an simple ray structure.   
                                     
  rayOutput.xCoordinate     = rayInput.xCoordinate(index_point);
  rayOutput.yCoordinate     = rayInput.yCoordinate(index_point);
  rayOutput.zCoordinate     = rayInput.zCoordinate(index_point);                                   
  rayOutput.hankelType      = rayInput.hankelType (index_point);
    
  if isa(rayInput,'OpticalRay')
    rayOutput.zxSlope         = rayInput.zxSlope(index_point);
    rayOutput.zySlope         = rayInput.zySlope(index_point);
    rayOutput.xySlope         = rayInput.xySlope(index_point);
    
  else
    rayOutput.rCoordinate     = rayInput.rCoordinate    (index_point);
    rayOutput.thetaCoordinate = rayInput.thetaCoordinate(index_point);
    rayOutput.zrSlope         = rayInput.zrSlope        (index_point);
    rayOutput.zthSlope        = rayInput.zthSlope       (index_point);
    rayOutput.rthSlope        = rayInput.rthSlope       (index_point);
  end
  
end