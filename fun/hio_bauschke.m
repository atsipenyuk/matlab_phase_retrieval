function [g_new, error] = hio_bauschke(g, A, beta, pObj, varargin)
% hio - Hybrid Input-Output algorithm (Bauschke' variant)
%
% Synopsis ([]s are optional)
%   [g_new, error] = hio(g, A, [beta], [pObj], [varargin])
%
% Description
%   Performs a phase retrieval update step and calculates the error
%   (energy) corresponding to the hybrid input-output update, as 
%   described in [Bauschke] (cf [Bauschke, Remark 4.1]), but using
%   the positivity constraint instead of the support constraint.
%
% Inputs ([]s are optional)
%   (ndarray) g      Current  approximation to the solution of the
%                    phase retrieval problem
%   (ndarray) A      Phase retrieval data (square root of the
%                    measured intensity)
%   (scalar)  [beta = 0.7]
%                    Update parameter, default value (no explanation).
%   (func)    [pObj = @pP]
%                    handle to the projection onto the object space
%                    (non-negativity, atomicity, etc.). pObj must
%                    take g as the first argument, may contain
%                    optional arguments specified in varargin.
%   (...)     [varargin]
%                    optional arguments passed to pObj --- if
%                    submitted, pObj is  called as pObj(g, varargin)
%
% Outputs ([]s are optional)
%   (ndarray) g_new  Updated approximation to the solution of the 
%                    phase retrieval problem
%   (scalar)  error  Error (energy) corresponding to the updated 
%                    approximation
%
% Examples
%   %% 1D, two gaussians
%   x = [-20:0.2:20];
%   g = exp(-x.^2);
%   shift = fix(length(g)/4);
%   g_sol = circshift(g, [0, shift]) + circshift(g, [0, -shift]);
%   A = abs(fftn(g_sol));
%   g_new = A;
%   E = [];
%   for i=1:1:200
%       % Stabilizing ER step, cf. [Fienup], p. 2765
%       % (May be omitted)
%       [g_new, error] = er(g_new, A); 
%       E = [E error];
%       [g_new, error] = hio_bauschke(g_new, A);
%       E = [E error];
%   end
%   plot(E);
%   plot(g_new);
%
%   %% 2D, two gaussians
%   [x1, x2] = ndgrid([-20:0.2:20], [-20:0.2:20]);
%   g = exp(-x1.^2 - x2.^2);
%   shift = fix(length(g)/4);
%   g_sol = circshift(g, [0, shift]) + circshift(g, [0, -shift]);
%   A = abs(fftn(g_sol));
%   g_new = A;
%   E = [];
%   for i=1:1:200
%       % Stabilizing ER step, cf. [Fienup], p. 2765
%       % (May be omitted)
%       [g_new, error] = er(g_new, A); 
%       E = [E error];
%       [g_new, error] = hio_bauschke(g_new, A);
%       E = [E error];
%   end
%
%   %% 3D, two gaussians
%   [x1, x2, x3] = meshgrid([-20:0.5:20], [-20:0.5:20],  [-20:0.5:20]);
%   g = exp(-x1.^2 - x2.^2 - x3.^2);
%   shift = fix(length(g)/4);
%   g_sol = circshift(g, [0, shift, shift]) + ...
%           circshift(g, [0, -shift, 0]);
%   A = abs(fftn(g_sol));
%   g_new = A;
%   E = [];
%   for i=1:1:60
%       [g_new, error] = hio_bauschke(g_new, A);
%       E = [E error];
%   end
%   plot_isosurface(x1,x2,x3,fftshift(g_sol));
%   plot_isosurface(x1,x2,x3,g_new);
%
%
% See also
%   er
%   bio
%   hio_fienup
%   dmap
%   
% Requirements
%   pM (modulus projection)
%   pP (non-negative projection)
%
% References
%   J. R. Fienup, “Phase retrieval algorithms: a comparison,” 
%       Applied Optics, vol. 21, pp. 2758–2769, 1982.
%   H. H. Bauschke, P. L. Combettes, and R. D. Luke, “Phase 
%       retrieval, error reduction algorithm, and Fienup 
%       variants: a view from convex optimization,”
%       J. Opt. Soc. Am. A., vol. 19, pp. 1334–1345, 2002.
%   doc/phase_retrieval_algorithms.pdf
%
% Authors
%   Arseniy Tsipenyuk <tsipenyu(at)ma.tum.de>
%
% License
%   See Phase nRetrieval Sandbox root folder.
%
% Changes
%   2016-06-01  First Edition
%   2016-06-07  Added pObj support
    if nargin == 2
        beta = 0.7;
        pObj = @pP;
    end
    
    if nargin == 3
        pObj = @pP;
    end
    
    % Calculate the update
    pM_g = pM(g, A);
    one_minus_beta_pM_g = g - beta * pM_g;

    if nargin <= 4
        g_new = pObj(pM_g) + one_minus_beta_pM_g ...
                - pObj(one_minus_beta_pM_g);
    else
        g_new = pObj(pM_g, varargin{:}) + one_minus_beta_pM_g ...
                - pObj(one_minus_beta_pM_g, varargin{:});

    end
    error = eM(g_new, A);
end