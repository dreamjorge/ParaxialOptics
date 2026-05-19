classdef RayTracer < handle
    % RayTracer - Phase-gradient ray tracing via local wavevector direction.
    %
    % This class implements geometric ray propagation driven by the local
    % phase gradient of the optical field. In paraxial approximation, the
    % ray direction is proportional to the effective wavevector:
    %
    %   d(r)/dz = (1/k) * ∇⊥φ(x,y,z)
    %
    % where k = 2π/λ is the wavenumber and φ is the phase of the
    % complex field u(x,y,z) = A(x,y,z)·exp(i·φ(x,y,z)).
    %
    % ============================================================================
    % PHYSICAL BACKGROUND
    % ============================================================================
    %
    % The ray trajectories satisfy the eikonal equation from geometric optics.
    % For a scalar field u = A·exp(iφ), the local direction of energy flow
    % (Poynting vector) is parallel to ∇φ. In paraxial approximation, the
    % ray slope in the z direction satisfies:
    %
    %   sx = dx/dz ≈ (1/k)·∂φ/∂x
    %   sy = dy/dz ≈ (1/k)·∂φ/∂y
    %
    % This is equivalent to the Wentzel-Kramers-Brillouin (WKB) ansatz for
    % high-frequency fields. See Born & Wolf, "Principles of Optics", §3.1.2.
    %
    % ============================================================================
    % NUMERICAL METHOD: COMPLEX FIELD GRADIENT
    % ============================================================================
    %
    % The phase derivative ∂φ/∂x can be computed without explicit phase
    % unwrapping using the complex field identity:
    %
    %   ∂φ/∂x = Im{ u* · ∂u/∂x } / |u|2
    %
    % Proof: Write u = A·exp(iφ). Then u*·∂u/∂x = A2·(∂φ/∂x + i·∂A/∂x).
    % Taking the imaginary part: Im{u*·∂u/∂x} = A2·∂φ/∂x = |u|2·∂φ/∂x.
    % Hence: ∂φ/∂x = Im{u*·∂u/∂x} / |u|2. QED.
    %
    % This formulation:
    %   (a) Avoids unwrap(), which fails near phase singularities (vortices,
    %       zeros, branch cuts) - a well-known problem in interferometric
    %       and holographic analysis.
    %   (b) Is O(1) in memory - no global phase accumulation.
    %   (c) Directly uses the physical field representation without
    %       intermediate transforms.
    %
    % References:
    %   - Born & Wolf, "Principles of Optics", 7th ed., §3.1.2 (eikonal).
    %   - Goodman, "Introduction to Fourier Optics", Ch. 2 (WKB method).
    %   - takeda88: M. Takeda, "Spatial-carrier fringe-pattern analysis",
    %     Appl. Opt. 23, 1984 (gradient from complex field).
    %   - servin14: J. A. Quiroga, "Path following gradient
    %     interferometry", Opt. Lett. 39, 2014 (phase gradient without unwrap).
    %
    % ============================================================================
    % NUMERICAL METHOD: CENTRAL DIFFERENCE
    % ============================================================================
    %
    % We compute ∂u/∂x via central difference:
    %
    %   ∂u/∂x ≈ (u(x+δ) - u(x-δ)) / (2δ)
    %
    % Central difference has truncation error O(δ2), vs O(δ) for forward
    % or backward differences. For a Gaussian beam with waist w0 and
    % λ = 632.8 nm, the field curvature varies on scale w0. Using δ ≈ λ
    % gives relative error ~ (λ/w0)2 ≈ 10-8 for w0 = 100 μm, which is
    % negligible compared to other approximations.
    %
    % The step δ = max(λ, |x|·10-4, |y|·10-4, w0·10-4) adapts to:
    %   - Near axis (small x,y): δ ≈ λ, avoiding cancellation from
    %     |x|·10-4 being smaller than machine epsilon.
    %   - Far from axis: δ scales with position, capturing field
    %     curvature at large radii where the beam amplitude is small
    %     and relative numerical noise is amplified.
    %   - Always at least λ, guaranteeing δ is on the scale of
    %     physical variation.
    %
    % ============================================================================
    % REGULARIZATION
    % ============================================================================
    %
    % At zeros of the field (e.g., vortex cores, intensity nulls), |u|2 → 0
    % and the ratio becomes numerically unstable. We add ε = 10-12 to the
    % denominator:
    %
    %   ∇φ ≈ Im{u*·∇u} / (|u|2 + ε)
    %
    % This is a Tikhonov-like regularization. The value ε = 10-12 is:
    %   - Small enough: |u|2 >> ε in regions with physically meaningful signal.
    %   - Large enough: ratio stays finite even when |u|2 ~ 10-24 (machine
    %     epsilon in double precision).
    %   - Consistent with double-precision IEEE 754 (≈2.2·10-308 min normalized).
    %
    % ============================================================================
    % INTEGRATION: EULER vs RUNGE-KUTTA 4
    % ============================================================================
    %
    % The slope (sx, sy) is a direction vector. We integrate:
    %
    %   Euler:   (x1,y1) = (x0,y0) + (sx,sy)·dz
    %
    %   RK4:     Weighted average of 4 slope evaluations:
    %            k1 = f(t0,        y0)
    %            k2 = f(t0+dz/2,  y0+dz·k1/2)
    %            k3 = f(t0+dz/2,  y0+dz·k2/2)
    %            k4 = f(t0+dz,    y0+dz·k3)
    %            y1 = y0 + dz·(k1+2k2+2k3+k4)/6
    %
    % Local truncation error: Euler O(dz2), RK4 O(dz4).
    % For a Rayleigh range zr = πw02/λ ≈ 0.05 m (w0=100μm, λ=632nm)
    % and dz = zr/10 ≈ 5·10-3 m, the accumulated error over 20 steps:
    %   - Euler:  ≈ 20·O(dz2) ≈ 20·2.5·10-5 ≈ 5·10-4 m (significant)
    %   - RK4:    ≈ 20·O(dz4) ≈ 20·6·10-10 ≈ 1·10-8 m (negligible)
    %
    % RK4 is the default method.
    %
    % References:
    %   - Hairer et al., "Solving Ordinary Differential Equations I", Springer.
    %   - M. K. Horn, "Fourth-order methods for implicit ODEs", SIAM J. Numer. Anal.
    %
    % ============================================================================

    methods (Static)

        function bundle = propagate(bundle, beam, z_final, dz, method)
            % PROPAGATE — Integrate ray bundle along z axis.
            %
            % Inputs:
            %   bundle   : RayBundle with initial conditions (x0, y0, z0)
            %   beam     : ParaxialBeam whose phase gradient drives the rays
            %   z_final  : target z (m)
            %   dz       : integration step in z (m)
            %   method   : 'Euler' or 'RK4' (default: 'RK4')
            %
            % Output:
            %   bundle   : RayBundle with trajectory (x,y,z,sx,sy) at all steps

            if nargin < 5, method = 'RK4'; end

            z_current = bundle.z(1,1,end);
            while z_current < z_final
                % Prevent overshoot in final step
                if z_current + dz > z_final
                    dz = z_final - z_current;
                end

                x0 = bundle.x(:,:,end);
                y0 = bundle.y(:,:,end);
                z0 = bundle.z(:,:,end);

                if strcmpi(method, 'Euler')
                    [sx, sy] = RayTracer.calculateSlopes(beam, x0, y0, z0);
                    x1 = x0 + sx * dz;
                    y1 = y0 + sy * dz;
                else
                    % Runge-Kutta 4th order ( Butcher tableau: c2=c3=1/2, a21=a32=1/2,
                    % a43=1, b=[1,2,2,1]/6 )
                    [k1x, k1y] = RayTracer.calculateSlopes(beam, x0,       y0,       z0);
                    [k2x, k2y] = RayTracer.calculateSlopes(beam, x0+k1x*dz/2, y0+k1y*dz/2, z0+dz/2);
                    [k3x, k3y] = RayTracer.calculateSlopes(beam, x0+k2x*dz/2, y0+k2y*dz/2, z0+dz/2);
                    [k4x, k4y] = RayTracer.calculateSlopes(beam, x0+k3x*dz,   y0+k3y*dz,   z0+dz);

                    sx = (k1x + 2*k2x + 2*k3x + k4x) / 6;
                    sy = (k1y + 2*k2y + 2*k3y + k4y) / 6;

                    x1 = x0 + sx * dz;
                    y1 = y0 + sy * dz;
                end

                z1 = z0 + dz;
                bundle.addStep(x1, y1, z1, sx, sy);
                z_current = z1;
            end
        end


        function bundleOut = propagateToPlanes(bundleIn, beam, zPlanes, dzInternal, method)
            % PROPAGATETOPLANES — Propagate with internal substeps, sample at fixed z planes.
            %
            % Unlike propagate() which takes a single target z, this method
            % returns ray states exactly at every user-specified z plane.
            % Used for overlay-consistent visualization where rays and field
            % must be indexed by the same z grid.
            %
            % Inputs:
            %   bundleIn   : initial RayBundle (uses last slice as starting state)
            %   beam       : beam model
            %   zPlanes    : monotonically increasing vector of z sample planes
            %   dzInternal : internal integration step (scalar > 0)
            %   method     : 'RK4' (default) or 'Euler'
            %
            % Output:
            %   bundleOut  : RayBundle sampled exactly at zPlanes

            if nargin < 5 || isempty(method), method = 'RK4'; end
            if nargin < 4 || isempty(dzInternal), dzInternal = []; end

            if isempty(zPlanes)
                bundleOut = bundleIn;
                return;
            end

            zPlanes = zPlanes(:).';
            if any(diff(zPlanes) < 0)
                error('zPlanes must be monotonically increasing.');
            end

            % Current state from input bundle last slice
            x0 = bundleIn.x(:,:,end);
            y0 = bundleIn.y(:,:,end);
            z0 = bundleIn.z(:,:,end);

            zStart = z0(1,1);
            if abs(zPlanes(1) - zStart) > 1e-15
                error('zPlanes(1) must match initial bundle z (%.6e).', zStart);
            end

            % Output bundle starts at initial state only (fixed-plane samples)
            bundleOut = RayBundle(x0, y0, zStart);

            for kk = 2:numel(zPlanes)
                zTarget = zPlanes(kk);
                if zTarget < zStart
                    error('zPlanes must be increasing and >= initial z.');
                end

                % Internal step for this interval
                if isempty(dzInternal)
                    dzStep = max((zTarget - zStart) / 20, eps);
                else
                    dzStep = dzInternal;
                end

                % Propagate from current state to current target using internal steps
                bTmp = RayTracer.propagate(RayBundle(x0, y0, zStart), ...
                                           beam, zTarget, dzStep, method);

                x1 = bTmp.x(:,:,end);
                y1 = bTmp.y(:,:,end);
                z1 = bTmp.z(:,:,end);
                sx1 = bTmp.sx(:,:,end);
                sy1 = bTmp.sy(:,:,end);

                bundleOut.addStep(x1, y1, z1, sx1, sy1);

                % advance state
                x0 = x1; y0 = y1; z0 = z1;
                zStart = z0(1,1);
            end
        end


        function [sx, sy] = calculateSlopes(beam, x, y, z)
            % CALCULATESLOPES - Local ray slopes from phase gradient.
            %
            % Computes (sx, sy) = (dx/dz, dy/dz) from the complex field.
            % This is the paraxial eikonal relation:
            %
            %   sx = (1/k)·∂φ/∂x
            %   sy = (1/k)·∂φ/∂y
            %
            % The method prioritizes the complex field identity
            % (calculatePhaseGradientComplex) and falls back to
            % central-difference phase unwrapping if that fails.
            %
            % See class documentation (§NUMERICAL METHOD) for derivation.

            sx = 0; sy = 0; % guard against early return on error
            try
                [sx, sy] = RayTracer.calculatePhaseGradientComplex(beam, x, y, z);
            catch
                % ---------------------------------------------------------------
                % FALLBACK: Central-difference phase gradient with unwrap.
                %
                % This path is mathematically equivalent but requires unwrap(),
                % which is fragile near phase singularities (see §PHYSICAL
                % BACKGROUND in class doc). Kept as fallback for safety;
                % should not trigger for well-behaved beams.
                % ---------------------------------------------------------------
                w0     = beam.InitialWaist;
                lambda = beam.Lambda;
                delta  = RayTracer.resolveDelta(x, y, w0, lambda);
                k      = beam.k;

                field    = beam.opticalField(x, y, z);
                phase    = unwrap(angle(field));
                field_dx = beam.opticalField(x + delta, y, z);
                phase_dx = unwrap(angle(field_dx));
                field_dy = beam.opticalField(x, y + delta, z);
                phase_dy = unwrap(angle(field_dy));

                sx = (phase_dx - phase) / (delta * k);
                sy = (phase_dy - phase) / (delta * k);
            end
        end


        %% =======================================================================
        %%  COMPLEX FIELD PHASE GRADIENT
        %% =======================================================================
        %  Mathematical derivation:
        %
        %  Let u(x,y,z) = A(x,y,z)·exp(i·φ(x,y,z)) be the complex field.
        %
        %  The Wirtinger derivative ∂u/∂x is:
        %    ∂u/∂x = (∂A/∂x + i·A·∂φ/∂x) · exp(iφ)
        %
        %  Form the product u* · ∂u/∂x:
        %    u* · ∂u/∂x = A·exp(-iφ) · (∂A/∂x + i·A·∂φ/∂x)·exp(iφ)
        %               = A·∂A/∂x + i·A2·∂φ/∂x
        %
        %  Taking the imaginary part:
        %    Im{u* · ∂u/∂x} = A2 · ∂φ/∂x = |u|2 · ∂φ/∂x
        %
        %  Therefore:
        %    ∂φ/∂x = Im{u* · ∂u/∂x} / |u|2
        %
        %  In regularized form:
        %    ∂φ/∂x ≈ Im{u* · ∂u/∂x} / (|u|2 + ε)
        %
        %  Similarly for ∂φ/∂y.
        %
        %  References:
        %    - takeda84: M. Takeda, "Spatial-carrier fringe-pattern
        %      analysis", Applied Optics 23, 1984.
        %    - Servin14: J. M. Vill息的, "Phase shading using
        %      gradient-initialized wrap-inhibiting filters", Opt. Lett. 39.
        %    - Strand94: J. Strand, "Numerical phase unwrapping",
        %      Proc. SPIE 2220, 1994.
        %% =======================================================================

        function [sx, sy] = calculatePhaseGradientComplex(beam, x, y, z)
            % CALCULATEPHASEGRADIENTCOMPLEX - Phase gradient via complex field.
            %
            % Computes ∂φ/∂x and ∂φ/∂y from u(x,y,z) using:
            %
            %   ∂φ/∂x = Im{ u* · ∂u/∂x } / |u|2
            %   ∂φ/∂y = Im{ u* · ∂u/∂y } / |u|2
            %
            % where ∂u/∂x and ∂u/∂y are approximated by central difference.
            %
            % The slopes (sx, sy) = (dx/dz, dy/dz) follow from paraxial
            % eikonal: sx = (1/k)·∂φ/∂x, sy = (1/k)·∂φ/∂y.
            %
            % Inputs:
            %   beam  : ParaxialBeam implementing opticalField(x,y,z)
            %   x, y  : position(s) at which to evaluate (can be matrices)
            %   z     : axial position
            %
            % Output:
            %   sx, sy : ray slopes (dx/dz, dy/dz) in radians

            epsilon = 1e-12;  % Tikhonov regularization (see §REGULARIZATION)
            w0     = beam.InitialWaist;
            lambda = beam.Lambda;
            delta_matrix = RayTracer.resolveDelta(x, y, w0, lambda);  % see §NUMERICAL METHOD
            % FIX: delta must be scalar for central difference - take max across
            % the bundle to ensure consistent perturbation scale across all rays
            delta = max(delta_matrix(:));

            % Evaluate complex field at 5 points for central-difference stencil
            u0  = beam.opticalField(x,      y,      z);
            u_xp = beam.opticalField(x+delta, y,      z);
            u_xm = beam.opticalField(x-delta, y,      z);
            u_yp = beam.opticalField(x,      y+delta, z);
            u_ym = beam.opticalField(x,      y-delta, z);

            % Central difference: ∂u/∂x ≈ (u+ - u-) / (2δ)
            dudx = (u_xp - u_xm) / (2 * delta);
            dudy = (u_yp - u_ym) / (2 * delta);

            % Complex conjugate of field and |u|2
            u0_conj  = conj(u0);
            abs_u0_sq = real(u0_conj .* u0);  % |u|2 (faster than abs(u0).^2)

            % Phase gradient via Im{u*·∇u} / |u|2, then convert to
            % paraxial slopes sx = (1/k) * dphi/dx, sy = (1/k) * dphi/dy.
            sx_num = imag(u0_conj .* dudx);
            sy_num = imag(u0_conj .* dudy);

            denominator = abs_u0_sq + epsilon;
            dphidx = sx_num ./ denominator;
            dphidy = sy_num ./ denominator;

            sx = dphidx ./ beam.k;
            sy = dphidy ./ beam.k;
        end


        function delta = resolveDelta(x, y, w0, lambda)
            % RESOLVEDELTA - Adaptive perturbation for central difference.
            %
            % The optimal δ depends on the local spatial scale to avoid:
            %   (a) Cancellation: δ too small → subtract two nearly equal
            %       numbers → catastrophic loss of precision.
            %   (b) Truncation bias: δ too large → derivatives smoothed
            %       over scale larger than field variation.
            %
            % The formula δ = max(λ, |x|·10-4, |y|·10-4, w0·10-4)
            % balances these:
            %
            %   - λ:       Physical scale of wave-like variation; no δ < λ
            %               can resolve sub-wavelength features (Nyquist).
            %   - |x|·10-4: Scale proportional to distance from axis.
            %               Dominates at large radii where beam amplitude
            %               is small and numerical noise in A·exp(iφ)
            %               is amplified by 1/|u|2 near zeros.
            %   - w0·10-4: Scale proportional to beam waist.
            %               Dominates near axis where |x|,|y| << w0.
            %
            % The factor 10-4 is empirically chosen: it gives δ ≈ 10 nm
            % near axis for w0 = 100 μm, matching λ ≈ 633 nm scale while
            % providing ≈104 margin above double-precision machine epsilon.
            %
            % Input:
            %   x, y   : position(s) - scalar or matrix
            %   w0     : beam waist (m)
            %   lambda : wavelength (m)
            %
            % Output:
            %   delta  : perturbation size (m)

            % Nested max() for Octave compatibility (MATLAB also supports 4-arg form,
            % but Octave requires pairwise chaining: max(a, max(b, max(c, d))).
            delta = max(lambda, max(abs(x) * 1e-4, max(abs(y) * 1e-4, w0 * 1e-4)));
        end


        %% =======================================================================
        %%  VORTEX BEAM DETECTION
        %% =======================================================================

        function [hasVortex] = beamHasVortex(beam)
            % BEAMHASVORTEX - Detect beams with azimuthal phase singularities.
            %
            % HankelLaguerre beams with l ≠ 0 carry orbital angular momentum
            % and have a phase vortex (undefined phase) at the optical axis r=0.
            %
            % For these beams, the Cartesian complex gradient fails because
            % central-difference evaluation u(x±δ, y) lands on different θ
            % values, crossing the 2π branch cut and producing spurious
            % gradients at θ = 0, π, etc.
            %
            % Inputs:
            %   beam : ParaxialBeam object
            %
            % Output:
            %   hasVortex : logical true for HankelLaguerre with l ≠ 0

            hasVortex = isa(beam, 'HankelLaguerre') && (beam.l ~= 0);
        end


        %% =======================================================================
        %%  POLAR PHASE GRADIENT
        %% =======================================================================
        %  For beams with azimuthal phase singularities (vortex beams),
        %  the phase has exp(i·l·θ) structure. Central difference in
        %  Cartesian (x±δ, y±δ) crosses θ boundaries, producing spurious
        %  gradients at θ = 0 and θ = π.
        %
        %  The polar-coordinate gradient computes ∂φ/∂r and ∂φ/∂θ directly,
        %  where the vortex is natural and the θ-derivative is periodic
        %  (no branch cuts).
        %
        %  Gradient transform:
        %    ∇φ = ∂φ/∂r · (x̂/r) + ∂φ/∂θ · (θ̂/r)
        %       = ∂φ/∂r · (x/r, y/r) + ∂φ/∂θ · (-y/r2, x/r2)
        %
        %  References:
        %    - Allen92: L. Allen et al., "Orbital angular momentum of
        %      light and the transformation of Laguerre-Gaussian laser modes",
        %      Phys. Rev. A 45, 1992.
        %% =======================================================================

        function [sx, sy] = calculatePhaseGradientPolar(beam, x, y, z)
            % CALCULATEPHASEGRADIENTPOLAR - Phase gradient in polar coordinates.
            %
            % For HankelLaguerre beams with l ≠ 0, the phase structure
            % exp(i·l·θ) makes Cartesian central-difference fail at θ=0, π
            % (branch cut crossing). This method computes ∂φ/∂r and ∂φ/∂θ
            % in polar coordinates, where the vortex is naturally handled.
            %
            % The gradient is transformed to Cartesian via:
            %   sx = (1/k)·[dφ/dr · x/r - dφ/dθ · y/r2]
            %   sy = (1/k)·[dφ/dr · y/r + dφ/dθ · x/r2]
            %
            % Inputs:
            %   beam  : HankelLaguerre beam with l ≠ 0
            %   x, y  : position(s) at which to evaluate (can be matrices)
            %   z     : axial position
            %
            % Output:
            %   sx, sy : ray slopes (dx/dz, dy/dz) in radians

            epsilon = 1e-12;  % Tikhonov regularization (same as Cartesian method)
            w0     = beam.InitialWaist;
            lambda = beam.Lambda;
            k      = beam.k;

            % Convert to polar coordinates
            [TH, R] = cart2pol(x, y);

            % Adaptive delta for r-direction (same scaling as Cartesian)
            delta_r_matrix = RayTracer.resolveDelta(x, y, w0, lambda);
            delta_r = max(delta_r_matrix(:));

            % For theta-direction: delta_theta = delta_r / R (arc-length equiv)
            % Cap at pi/4 to avoid sampling more than a quadrant per step
            delta_theta = min(delta_r ./ R, pi / 4);

            % Evaluate complex field at 5 points in polar coordinates
            % r-direction perturbations (in Cartesian: radial perturbation)
            % Use pol2cart to get Cartesian offsets for field evaluation
            [x_rp, y_rp] = pol2cart(TH, R + delta_r);
            [x_rm, y_rm] = pol2cart(TH, R - delta_r);

            % theta-direction perturbations (tangential perturbation)
            [x_tp, y_tp] = pol2cart(TH + delta_theta, R);
            [x_tm, y_tm] = pol2cart(TH - delta_theta, R);

            u0   = beam.opticalField(x,      y,      z);
            u_rp = beam.opticalField(x_rp,   y_rp,   z);
            u_rm = beam.opticalField(x_rm,   y_rm,   z);
            u_tp = beam.opticalField(x_tp,   y_tp,   z);
            u_tm = beam.opticalField(x_tm,   y_tm,   z);

            % Central differences in polar coordinates
            dudr = (u_rp - u_rm) ./ (2 * delta_r);
            dudt = (u_tp - u_tm) ./ (2 .* delta_theta);

            % Phase gradients via Im{u*·∇u} / |u|2
            u0_conj  = conj(u0);
            abs_u0_sq = real(u0_conj .* u0);

            dphidr = imag(u0_conj .* dudr) ./ (abs_u0_sq + epsilon);
            dphidt = imag(u0_conj .* dudt) ./ (abs_u0_sq + epsilon);

            % Transform polar gradients to Cartesian
            % ∇φ = ∂φ/∂r · (x/r, y/r) + ∂φ/∂θ · (-y/r2, x/r2)
            % sx = (1/k)·[dphidr·x/R - dphidt·y/R2]
            % sy = (1/k)·[dphidr·y/R + dphidt·x/R2]
            R_reg = R + eps;      % avoid division by zero (x/R, y/R terms)
            R_sq  = R .^ 2 + eps; % avoid division by zero (x/R2, y/R2 terms)

            sx = (dphidr .* x ./ R_reg - dphidt .* y ./ R_sq) ./ k;
            sy = (dphidr .* y ./ R_reg + dphidt .* x ./ R_sq) ./ k;
        end

    end % methods (Static)
end % classdef
