function [OpticalField] = propagateOpticalField(OpticalField,Propagator)    
%%  function for obtain optical field propagated

  %% FFT of Optocal Field
  OpticalFieldFFT = fftshift(fft2(ifftshift(OpticalField)));...*exp(-1j.*(u(1)).*(Kx)).*exp(-1j.*(u(1)).*(Kx'));
  %obtain new propagated field
  OpticalField    = fftshift(ifft2(ifftshift(OpticalFieldFFT.*Propagator)));...*exp(-1j.*(u(1)).*(X))*exp(-1j.*(u(1)).*(X'));

  
end