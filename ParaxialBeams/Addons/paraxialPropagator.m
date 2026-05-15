function [propagator]=paraxialPropagator(Kx,Ky,k,dz)

  propagator = exp(1i*dz*(Kx.^2+Ky.^2)/(2*k));

end