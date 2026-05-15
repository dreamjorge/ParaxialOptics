function [rayOutput]= copy2Ray(rayInput,...
                              rayOutput,...
                              index_point,...
                              index_output_point)
                            
                            
  rayOutput.xCoordinate    (index_output_point) = rayInput.xCoordinate    (index_point);
  rayOutput.yCoordinate    (index_output_point) = rayInput.yCoordinate    (index_point);
  rayOutput.zCoordinate    (index_output_point) = rayInput.zCoordinate    (index_point);
  rayOutput.rCoordinate    (index_output_point) = rayInput.rCoordinate    (index_point);
  rayOutput.thetaCoordinate(index_output_point) = rayInput.thetaCoordinate(index_point);
  
  if (index_output_point>1)
    rayOutput.zxSlope        (index_output_point) = rayInput.zxSlope(index_point)        ;
    rayOutput.zySlope        (index_output_point) = rayInput.zySlope(index_point)        ;
    rayOutput.xySlope        (index_output_point) = rayInput.xySlope(index_point)        ;
  else
    rayOutput.zxSlope        (index_output_point) = Inf;
    rayOutput.zySlope        (index_output_point) = Inf;
    rayOutput.xySlope        (index_output_point) = Inf;
  end