function [Rays] = getPropagateCylindricalRays(Rays, ...
                                              TotalRays, ...
                                              r, th, ...
                                              difr, ...
                                              LParametersZi, ...
                                              LParametersZ)
%% getPropagateCylindricalRays - Propagate cylindrical rays one z-step
% Computes new (r, theta, z) coordinates for each ray using the ray equation:
%   r(z) = r(z-1) + (1/mrz)*dz
% Then recalculates slopes via the cylindrical gradient.
%
% Ported from feature/FixLaguerre (commit aa33098).

  tempdr     = num2cell(difr);
  [~, ~, dz] = deal(tempdr{:});

  temporalRay = CylindricalRay();

  for point_index = 1 : TotalRays

    temporalRay = copyArrayRay2Ray(Rays, temporalRay, point_index);

    % Update cylindrical coordinates
    temporalRay.rCoordinate     = temporalRay.rCoordinate     + (1 ./ temporalRay.zrSlope)  * dz;
    temporalRay.thetaCoordinate = temporalRay.thetaCoordinate + (1 ./ temporalRay.zthSlope) * dz;
    temporalRay.zCoordinate     = temporalRay.zCoordinate + dz;

    % Sync Cartesian coordinates
    [Rays.xCoordinate, Rays.yCoordinate] = pol2cart(Rays.thetaCoordinate, Rays.rCoordinate);

    ri  = temporalRay.rCoordinate;
    thi = temporalRay.thetaCoordinate;

    % Flip Hankel type when ray crosses the axis
    if (ri < 0) && (temporalRay.hankelType == 2)
      temporalRay.hankelType = 1;
    end
    temporalRay.rCoordinate = abs(ri);

    % Compute field slices for gradient
    HLr  = HankelLaguerre(r,  thi, LParametersZi, temporalRay.hankelType);
    HLth = HankelLaguerre(ri, th,  LParametersZi, temporalRay.hankelType);
    HLz  = HankelLaguerre(ri, thi, LParametersZ,  temporalRay.hankelType);

    fr  = unwrap(angle(HLr.OpticalFieldLaguerre));
    fth = unwrap(angle(HLth.OpticalFieldLaguerre));
    fz  = unwrap(angle(HLz.OpticalFieldLaguerre));

    % Recalculate slopes
    temporalRay = getCylindricalGradient(fr, fth, fz, LParametersZi.k, difr, temporalRay);

    % Enforce slope sign convention per Hankel type
    if (temporalRay.hankelType == 1)
      temporalRay.zrSlope = abs(temporalRay.zrSlope);
    elseif (temporalRay.hankelType == 2)
      temporalRay.zrSlope = -abs(temporalRay.zrSlope);
    end

    Rays = copyRay2ArrayRay(temporalRay, Rays, point_index);
  end

end
