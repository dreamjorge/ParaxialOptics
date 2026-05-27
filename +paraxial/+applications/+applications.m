%% Applications - Paraxial Beam Applications Suite
%% 
%% This package provides a collection of application scripts demonstrating
%% beam propagation, analysis, and visualization capabilities of the
%% paraxial optics simulation library.
%%
%% STRUCTURE
%% --------
%% +demos/          - Basic demonstrations for learning and onboarding
%% +propagation/    - Beam propagation scripts (FFT, analytic, with obstructions)
%% +analysis/       - Beam analysis scripts (wavefront, ray bundles, self-healing)
%% +visualization/ - Visualization and figure generation scripts
%%
%% QUICK START
%% ----------
%% Run a demo:
%%   cd /path/to/ParaxialOptics
%%   octave --no-gui --eval "run('+paraxial/+applications/+demos/DemoGaussian.m')"
%%
%% Run propagation:
%%   octave --no-gui --eval "run('+paraxial/+applications/+propagation/PropagationFFT.m')"
%%
%% Run analysis:
%%   octave --no-gui --eval "run('+paraxial/+applications/+analysis/WavefrontAnalysis.m')"
%%
%% RUNNING SCRIPTS
%% ---------------
%% All scripts are self-contained and handle path setup automatically.
%% They can be run from any working directory.
%%
%% Demos (+demos/):
%%   DemoGaussian.m        - Gaussian beam basics
%%   DemoHermiteLaguerre.m - Hermite and Laguerre-Gaussian modes
%%   DemoElegantModes.m    - Elegant Hermite/Laguerre modes
%%
%% Propagation (+propagation/):
%%   PropagationFFT.m              - FFT-based angular spectrum propagation
%%   PropagationAnalytic.m        - Analytic beam propagation
%%   PropagationWithObstruction.m - Propagation through obstructions
%%   PropagationElegant.m          - Elegant beam propagation
%%
%% Analysis (+analysis/):
%%   WavefrontAnalysis.m    - Wavefront extraction and Zernike fitting
%%   RayBundleAnalysis.m    - Ray tracing and bundle analysis
%%   SelfHealingAnalysis.m  - Self-healing behavior analysis
%%
%% Visualization (+visualization/):
%%   GenerateSlices3D.m     - 3D slice visualization
%%   GenerateVideo.m        - Video generation from propagation
%%   GenerateFigures.m     - Publication-quality figure generation
%%
%% DEPENDENCIES
%% ------------
%% These scripts require the following packages on the MATLAB path:
%%   +paraxial/           - Main beam classes
%%   ParaxialBeams/       - Factory and utilities
%%   ParaxialBeams/Addons - Plotting and export utilities
%%
%% All paths are configured automatically by each script.
%%
%% API DESIGN
%% ----------
%% These application scripts are designed as both:
%%   1. Demonstrations - showing how to use the library
%%   2. Building blocks - reusable components for custom applications
%%
%% The scripts follow the API contract defined in:
%%   - +paraxial/+beams/ParaxialBeam.m (beam interface)
%%   - ParaxialBeams/BeamFactory.m (beam creation)
%%   - +paraxial/+propagation/+field/IPropagator.m (propagation interface)
%%
%% EXAMPLES
%% --------
%% Creating a beam:
%%   beam = BeamFactory.create('gaussian', 100e-6, 632.8e-9);
%%   field = beam.opticalField(X, Y, z);
%%
%% Propagation with FFT:
%%   grid = GridUtils(512, 512, 1e-3, 1e-3);
%%   fftOps = FFTUtils();
%%   field = fftOps.propagate(field0, Kx, Ky, dz, lambda);
%%
%% Wavefront analysis:
%%   wf = Wavefront(field, lambda, grid);
%%   coeffs = wf.fitZernike(36);
%%   metrics = wf.getMetrics(36);
%%
%% VERSION
%% -------
%% This package is part of the ParaxialOptics library.
%% Version: see +paraxial/simulation_scripts_version.m
%%
%% SEE ALSO
%% --------
%%   docs/ARCHITECTURE.md  - Architecture documentation
%%   docs/ROADMAP.md      - Development roadmap
%%   README.md            - Project overview
%%   examples/canonical/   - Additional examples

% This file is a package marker. See individual script headers for details.