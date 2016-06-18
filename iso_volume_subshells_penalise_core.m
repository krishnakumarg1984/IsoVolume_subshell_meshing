% Given a sphere of radius R, this script computes the meshing points
% (radii from centre) and thickness of each subshell, such that all
% subshells have the same volume  (iso-volume discretisation).

% Copyright 2016 Krishnakumar Gopalakrishnan & Teng Zhang, Imperial College London
% $Revision: 1.00 $
% Author Info
 
% Krishnakumar Gopalakrishnan,  krishnak@vt.edu
% Teng Zhang,                   t.zhang@imperial.ac.uk
% Created : June, 2016

clear;clc; close all; format compact; format short;

max_shells = 100;  % MAX. number of iso-volume shells needed. Otherwise may run forever
%% User Inputs 

R       = input('Enter overall radius of the sphere : ');  
t_outer = input('Enter thickness of outermost shell : ');                       

%% Compute Radius of the core (innermost shell)

t1      = (R^3 - (R-t_outer)^3)^(1/3);          % Calculate innermost thickness, i.e. core radius

%% Initialisations 
shell_thicknesses   = t1*ones(max_shells,1);    % This column vector holds the computed thicknesses of each shell. Initialised to t1, i.e. core radius.  Preallocating this for speed.
cum_thickness       = t1;                       % Cumulative thickness, measured from the core outwards. Initialised to t1, i.e. core radius

%% Main loop, computing thickness of each shell, starting from the centre and radiating outwards

shell_count = 1;    % Shell count = 1, before loop begins (as 1st shell thickness has been computed earlier)

while cum_thickness < R                                                                     % run loop until cumulative thickness exceeds or equals sphere's total radius
    if shell_count >= max_shells
        disp('Exceeded max. shells. Reduce outer thickness or increase max_shells ....');
        choice = input('Press "y" to continue with the computation, any other key to quit ....','s');
            if choice == 'y'
                clear choice;
                break;
            else
                clear choice;
                return ;                
            end
    end
    shell_count                      = shell_count + 1;                                      % Need to compute thickness of 2nd shell onwards, in the loop
    thickness_update_function        = @(t) (cum_thickness + t)^3 - cum_thickness^3 - t1^3;  % Function to compute the next shell size
    shell_thicknesses(shell_count)   = fzero(thickness_update_function,t1);                  % Append the shell_sizes vector with the newly computed shell thickness
    cum_thickness                    = cum_thickness + shell_thicknesses(shell_count);       % Update the cumulative thickness to add the current calculated thickness
end 

shell_thicknesses(shell_count+1:end) = []; % Remove the 

%% Adjustment of core shell to ensure we don't exceed the maximum radius (domain length)
% Note: This will always result in inner shell's thickness being smaller
% than that needed to maintain equal volumes, while enforcing iso-shells
% in all other sub-shells. 

if cum_thickness > R
  shell_thicknesses(end)   = t_outer;
  extra_thickness          = sum(shell_thicknesses) - R;
  shell_thicknesses(1)     = shell_thicknesses(1) - extra_thickness;   % Add the extra thickness to core shell
end
clear cum_thickness;
%% Validate iso-volume implementation 

shell_radii   = cumsum(shell_thicknesses);            % Compute radii of each shell, measured from the centre of the sphere

shell_volumes = zeros(shell_count,1);                 % Initialise the volume of each shell to zero(Pre-allocation for speed)
for n = 1:shell_count                  
    if n == 1   
        shell_volumes(n) = (4/3)*pi*shell_radii(n)^3; % Volume of 1st shell (core-shell)
    else
        shell_volumes(n) = (4/3)*pi*(shell_radii(n)^3 - shell_radii(n-1)^3); 
    end
end
clear n
%% Pretty-print the results as a table to the command window

table([1:shell_count]',shell_radii,shell_thicknesses,shell_volumes,'VariableNames',{'Shell_Number','Radius_from_origin' 'Shell_Thickness' 'Shell_Volume'})

fprintf('\nMean Sub-Shell Volume : %.4f \n',mean(shell_volumes))
fprintf('Standard Deviation    : %.4f \n',std(shell_volumes))