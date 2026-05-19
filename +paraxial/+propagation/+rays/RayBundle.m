classdef RayBundle < handle
    % RayBundle Class to manage a set of optical rays.
    %
    % Properties:
    %   x, y, z - Coordinates (m)
    %   r, theta - Polar coordinates (rad, m)
    %   slopes - Local slopes (dx/dz, dy/dz, etc.)
    
    properties
        x % x-coordinates (Ny x Nx x Nz)
        y % y-coordinates (Ny x Nx x Nz)
        z % z-coordinates (Ny x Nx x Nz)
        sx % dx/dz slopes
        sy % dy/dz slopes
        sz % dz/dz (always 1 for standard paraxial, but tracking for generality)
        ht % Hankel type per ray (Ny x Nx x Nz), default 1
    end
    
    properties (Dependent)
        r     % radial coordinates — computed from x,y at last z-slice
        theta % angular coordinates — computed from x,y at last z-slice
        Nx
        Ny
        Nz
    end
    
    methods
        function obj = RayBundle(x0, y0, z0)
            % Initialize a bundle of rays at a starting z plane
            % x0, y0 are matrices/arrays of initial coordinates
            if nargin > 0
                obj.x = x0;
                obj.y = y0;
                obj.z = z0 * ones(size(x0));
                obj.sx = zeros(size(x0));
                obj.sy = zeros(size(x0));
                obj.sz = ones(size(x0));
                obj.ht = ones(size(x0));
            end
        end
        
        function val = get.r(obj)
            val = sqrt(obj.x(:,:,end).^2 + obj.y(:,:,end).^2);
        end
        function val = get.theta(obj)
            [val] = cart2pol(obj.x(:,:,end), obj.y(:,:,end));
        end
        
        function val = get.Nx(obj)
            val = size(obj.x, 2);
        end
        function val = get.Ny(obj)
            val = size(obj.x, 1);
        end
        function val = get.Nz(obj)
            val = size(obj.x, 3);
        end
        
        function addStep(obj, x, y, z, sx, sy, ht)
            obj.x = cat(3, obj.x, x);
            obj.y = cat(3, obj.y, y);
            obj.z = cat(3, obj.z, z);
            obj.sx = cat(3, obj.sx, sx);
            obj.sy = cat(3, obj.sy, sy);
            if nargin >= 7
                obj.ht = cat(3, obj.ht, ht);
            else
                obj.ht = cat(3, obj.ht, obj.ht(:,:,end));
            end
        end
    end
    
    methods (Static)
        function bundle = createGrid(Nx, Ny, Dx, Dy, z0)
            if nargin < 5, z0 = 0; end
            [X, Y] = meshgrid(linspace(-Dx/2, Dx/2, Nx), linspace(-Dy/2, Dy/2, Ny));
            bundle = RayBundle(X, Y, z0);
        end
        
        function bundle = createConcentric(Nr, Ntheta, maxR, z0)
            if nargin < 4, z0 = 0; end
            r_vals = linspace(0, maxR, Nr);
            th_vals = linspace(0, 2*pi, Ntheta+1);
            th_vals(end) = []; % avoid duplicate at 0/2pi
            [R, TH] = meshgrid(r_vals, th_vals);
            [X, Y] = pol2cart(TH, R);
            bundle = RayBundle(X, Y, z0);
        end
        
        function bundle = createCrosshairs(N, L, z0)
            if nargin < 3, z0 = 0; end
            vals = linspace(-L/2, L/2, N);
            x_line = [vals, zeros(1, N)];
            y_line = [zeros(1, N), vals];
            bundle = RayBundle(x_line, y_line, z0);
        end

        function bundle = createCircularContour(Ntheta, radius, z0, x0, y0)
            if nargin < 3, z0 = 0; end
            if nargin < 4, x0 = 0; end
            if nargin < 5, y0 = 0; end

            theta = linspace(0, 2*pi, Ntheta + 1);
            theta(end) = [];
            [X, Y] = pol2cart(theta, radius * ones(size(theta)));
            bundle = RayBundle(X + x0, Y + y0, z0);
        end

        function bundle = createRectangularContour(pointsPerEdge, width, height, z0, x0, y0)
            if nargin < 4, z0 = 0; end
            if nargin < 5, x0 = 0; end
            if nargin < 6, y0 = 0; end

            top_x = linspace(-width/2, width/2, pointsPerEdge);
            top_y = (height/2) * ones(1, pointsPerEdge);

            right_x = (width/2) * ones(1, pointsPerEdge);
            right_y = linspace(height/2, -height/2, pointsPerEdge);

            bottom_x = linspace(width/2, -width/2, pointsPerEdge);
            bottom_y = (-height/2) * ones(1, pointsPerEdge);

            left_x = (-width/2) * ones(1, pointsPerEdge);
            left_y = linspace(-height/2, height/2, pointsPerEdge);

            X = [top_x, right_x, bottom_x, left_x] + x0;
            Y = [top_y, right_y, bottom_y, left_y] + y0;
            bundle = RayBundle(X, Y, z0);
        end

        function bundle = createSquareGrid(Nx, Ny, size, z0)
            % CREATESQUAREGRID — Uniform rectangular grid bundle.
            %
            % Inputs:
            %   Nx, Ny : grid dimensions (number of rays along x and y)
            %   size  : side length of the square domain (m)
            %   z0    : initial z position (default: 0)
            %
            % Output:
            %   bundle : RayBundle with Nx*Ny rays in a regular grid

            if nargin < 4, z0 = 0; end

            [X, Y] = meshgrid(linspace(-size/2, size/2, Nx), linspace(-size/2, size/2, Ny));
            bundle = RayBundle(X, Y, z0);
        end

        function bundle = createGaussianWeighted(Nx, Ny, w0, sigma, z0)
            % CREATEGAUSSIANWEIGHTED — Grid bundle with Gaussian intensity weighting.
            %
            % Rays are sampled on a regular grid and weighted by a Gaussian
            % intensity profile. This samples more rays near the beam axis where
            % the field amplitude is highest, improving representativeness for
            % beams whose energy is concentrated near the center.
            %
            % Inputs:
            %   Nx, Ny  : grid dimensions (number of rays along x and y)
            %   w0      : beam waist for Gaussian weighting (m)
            %   sigma   : fraction of w0 for grid half-width (default: 1.0)
            %             The grid spans [-sigma*w0, sigma*w0] in both dimensions.
            %   z0      : initial z position (default: 0)
            %
            % Output:
            %   bundle  : RayBundle with Nx*Ny rays on a regular grid,
            %             weighted by exp(-r^2/w0^2)

            if nargin < 5, z0 = 0; end
            if nargin < 4, sigma = 1.0; end

            range = sigma * w0;
            [X, Y] = meshgrid(linspace(-range, range, Nx), linspace(-range, range, Ny));
            bundle = RayBundle(X, Y, z0);
        end
    end
end
