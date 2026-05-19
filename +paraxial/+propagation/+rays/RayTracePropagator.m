classdef RayTracePropagator < IPropagator
    % RayTracePropagator - Phase-gradient ray tracing via RayTracer (Strategy)
    % Compatible with GNU Octave and MATLAB
    %
    % Constructor:
    %   prop = RayTracePropagator(grid)
    %   prop = RayTracePropagator(grid, method)
    %   prop = RayTracePropagator(grid, method, dz)
    %   prop = RayTracePropagator(grid, method, dz, z0)
    %
    % Usage:
    %   bundle = prop.propagate(beam, z_final)
    %
    % Strategy (Phase-gradient ray tracing):
    %   1. Seed a ray bundle on the grid at z = z0.
    %   2. At each z step, compute local phase gradients:
    %        sx = (1/k) * d(phase)/dx,   sy = (1/k) * d(phase)/dy
    %      using beam.opticalField() at offset positions (finite difference).
    %   3. Advance rays by Euler or RK4 integration over dz steps.
    %   4. Return the RayBundle containing (x, y, z, sx, sy) at all steps.
    %
    % This wraps RayTracer.propagate() with the IPropagator interface.
    %
    % When to use:
    %   - Wavefront tracking, geometric optics visualization.
    %   - When you need the ray trajectories, not just the final field.
    %   - For understanding caustics, focusing, or aberration patterns.
    %
    % Parameters:
    %   method: 'RK4' (default) or 'Euler'
    %   dz:     integration step size in z (default: z_final / 100)
    %   z0:     initial z plane (default 0)

    properties
        Grid    % GridUtils object — defines initial ray sampling
        Method  % Integration method: 'RK4' or 'Euler'
        dz      % Step size (m); [] means auto (z_final/100)
        z0      % Initial z plane (default 0)
    end

    methods
        function obj = RayTracePropagator(grid, method, dz, z0)
            % Constructor
            % grid:   GridUtils object
            % method: 'RK4' (default) or 'Euler'
            % dz:     step size (default auto = z_final/100)
            % z0:     initial z plane (default 0)
            obj.Grid = grid;
            if nargin >= 2 && ~isempty(method)
                obj.Method = method;
            else
                obj.Method = 'RK4';
            end
            if nargin >= 3 && ~isempty(dz)
                obj.dz = dz;
            else
                obj.dz = [];
            end
            if nargin >= 4
                obj.z0 = z0;
            else
                obj.z0 = 0;
            end
        end

        function bundle = propagate(obj, beam, z_final)
            % propagate - Trace rays from z0 to z_final.
            %
            % Parameters:
            %   beam    (ParaxialBeam): beam whose phase gradient drives the rays
            %   z_final (scalar):       target z (m)
            %
            % Returns:
            %   bundle (RayBundle): ray positions and slopes at all integration steps
            [X, Y] = obj.Grid.create2DGrid();

            % Resolve step size
            if isempty(obj.dz)
                dz_step = (z_final - obj.z0) / 100;
            else
                dz_step = obj.dz;
            end

            bundle = RayBundle(X, Y, obj.z0);
            bundle = RayTracer.propagate(bundle, beam, z_final, dz_step, obj.Method);
        end
    end
end
