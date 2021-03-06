function [x_pcs, F_pcs] = splitMass(num_mass_pieces, x_list, f_list)
% SPLITMASS Split density function into points with the same partial mass
%
%   [x_pcs, F_pcs] = splitMass(num_mass_pieces, x_list, f_list). Given
%   discretized function f_list defined on points of x_list.  Let M be
%   the total mass of f_list. Cut M into num_mass_pieces and return
%   the coordinates of the rightmost edge of each mass piece. I.e.,
%   return F^{-1}(y) where F is the cumulative distribution of f_list,
%   F^{-1} is its inverse, and y are equidistant points between 0 and
%   M.
%
%   numm_mass_pieces = integer, number of pieces into which the
%   density will be split.
%
%   x_list = coordinates at which the density function is
%   discretized
%
%   f_list = values of the density function
%
%   x_pcs = right-hand side coordinates of the mass pieces into
%   which the density is split
%
%   F_pcs = cumulative distribution function of the given density
%   evaluated at points x_pcs. It is merely an equidistant list
%   from M/num_mass_pieces to M.
%
%   Arseniy Tsipenyuk, TUM M7
%   May 9th, 2016

    
    F_list = indefiniteIntegral(x_list, f_list);
    M = F_list(end);
 
    % CDF corresponding to the points on the x axis that we want to find
    F_pcs = linspace(M / num_mass_pieces, M, num_mass_pieces);
    
    % Indices that tells us between which points on the x_list lies
    % each F_pcs value
    bubbles = zeros(1, num_mass_pieces);
    x_pcs = zeros(1, num_mass_pieces);
    for i = 1 : 1 : num_mass_pieces
        bubbles(i) = sum(F_list <= F_pcs(i));
        % If the last mass piece ends on the rightmost edge of the
        % density, we must shift bubble index one down so we stay
        % in the allowed range for the density. (Effect appears for
        % flat CDF on the rightmost edge of the graph. Not a mathematical
        % effect - just an ugly code subtlety.)
        if bubbles(i) == length(x_list)
            bubbles(i) = bubbles(i) - 1;
        end
            
        x_pcs(i) = solveLinear(x_list(bubbles(i)), x_list(bubbles(i)+1),...
                               F_list(bubbles(i)), F_list(bubbles(i)+1),...
                               F_pcs(i));

    end
end
            

%==== Function used to solve linear equation with two known points ======
function x = solveLinear(x1, x2, f1, f2, f)
    % Childproofing
    if x1 == x2
        error('Points on the x-axis must be different.')
    end
    if ~( (f1 <= f) && (f <= f2))
        error(['One must have f1 <= f <= f2; provided: '...
               num2str(f1) ' <= ' num2str(f) ' <= ' num2str(f2) '. ']);
    end
    if (f1 == f2) && (f1 == f)
        x = x2;
        disp('Warning: flat cumulative distribution.');
        return;
    end        
    
    a = (f2 - f1) / (x2 - x1);
    b = f1 - a * x1;
    x = (f - b) / a;
end % solveLinear
%==========================================================================

