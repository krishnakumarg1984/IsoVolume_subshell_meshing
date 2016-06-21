% Given a sphere of radius R, this script computes the meshing points
% (radii from centre) and thickness of each subshell, such that all
% subshells have the same volume  (iso-volume discretisation).

% Copyright 2016 Krishnakumar Gopalakrishnan & Teng Zhang, Imperial College London
% $Revision: 1.00 $
% Author Info

% Krishnakumar Gopalakrishnan,  krishnak@vt.edu
% Teng Zhang,                   t.zhang@imperial.ac.uk
% Created : June 17, 2016
% Updated : June 21, 2016

clear;clc; close all; format compact; format shortG;
%% User Inputs

commandwindow;
R           = input('Enter overall radius of the sphere : ');
max_shells  = input('Enter maximum no. of shells needed : ');    % MAX. number of iso-volume shells needed. Otherwise may run forever
t_outer     = input('Enter thickness of outermost shell : ');
%% Compute no. of shells needed and quit if it exceeds the maximum allowed

N           = round(1/(1-((R-t_outer)/R)^3));                    % A quick formula to compute the total no. of shells
if N > max_shells
    fprintf('\nExceeded max. shells! \nReduce outer thickness or increase max_shells\n');
    input('Press any key to Quit .......');
    return ;
end
%% Compute Radius of the core (innermost shell)

t1      = (R^3 - (R-t_outer)^3)^(1/3); % Calculate innermost thickness, i.e. core radius (ideally). This will be re-adjusted later -- see comments after 2 sections below
%% Initialisations

shell_thicknesses    = t1*ones(N,1);    % This column vector holds the computed thicknesses of each shell. Initialised to t1, i.e. core radius.  Preallocating this for speed.
shell_thicknesses(N) = t_outer;         % Clearly, the last shell's thickness must be set to the user-entered value
cum_thickness        = t1;              % Cumulative thickness, measured from the core outwards. Initialised to t1, i.e. core radius
%% Main loop, computing thickness of each shell, starting from the centre and radiating outwards

shell_count = 1;                                                                             % Shell count = 1, before loop begins (as 1st shell thickness has been computed earlier)

for shell_count = 2:N-1                                                                      % Run loop for shells 2 till N-1. Last shell is user-entered value, and 1st shell's ideal thickness has been computed earlier
    thickness_update_function        = @(t) (cum_thickness + t)^3 - cum_thickness^3 - t1^3;  % Function to compute the next shell size
    shell_thicknesses(shell_count)   = fzero(thickness_update_function,t1);                  % Append the shell_sizes vector with the newly computed shell thickness
    cum_thickness                    = cum_thickness + shell_thicknesses(shell_count);       % Update the cumulative thickness to add the current calculated thickness
end
clear t1 thickness_update_function shell_count;

%% Adjustment of all inner shells to ensure we don't exceed the maximum radius (domain length)
% A quasi-iso volume approach is being adopted here, in order to enforce that outermost
% shell thickness is exactly that specified by user, and exactly covers the sphere's radius.
% The thickness of all inner shells are reduced in proportion to their computed values from above.

extra_thickness          = sum(shell_thicknesses) - R;
shell_thicknesses(1:N-1) = shell_thicknesses(1:N-1) - (extra_thickness*(shell_thicknesses(1:N-1)./cum_thickness));   % Proportionally distribute the extra thickness among the inner shells
clear cum_thickness extra_thickness;
%% Validate iso-volume implementation

shell_radii      = cumsum(shell_thicknesses);   % Compute radii of each shell (radius of each shell, is obv. measured from the centre of the sphere)

shell_volumes    = zeros(N,1);                  % Initialise the volume of each shell to zero(Pre-allocation for speed)
shell_volumes(1) = (4/3)*pi*shell_radii(1)^3;   % Volume of 1st shell (core-shell)

for n = 2:N
    shell_volumes(n) = (4/3)*pi*(shell_radii(n)^3 - shell_radii(n-1)^3);
end

clear n;
%% Pretty-print the results as a table to the command window

solution = table([0;shell_radii],[0;shell_thicknesses],[0;shell_volumes],'RowNames',['origin';strcat('shell_',cellstr(num2str((1:N)')))],'VariableNames',{'Radius_from_origin' 'Shell_Thickness' 'Shell_Volume'});
fprintf('\n');
disp(solution); clear solution;
fprintf('\nMost Repeating Sub-Shell Volume   : %.5f',mode(shell_volumes))
fprintf('\nMean Sub-Shell Volume             : %.5f \n',mean(shell_volumes))
fprintf('Median Sub-Shell Volume           : %.5f \n',median(shell_volumes))
fprintf('Standard Deviation                : %.5f \n',std(shell_volumes))
clear ans
%% Licensing Terms

%     BSD License for quasi_iso_volume_subshell
%     http://www.opensource.org/licenses/bsd-license.php
%
% This notice applies to the software packages
%
%     quasi_iso_volume_subshell (MATLAB script)
%
% made available at
%
%     https://github.com/krishnakumarg1984/IsoVolume_subshell_meshing/blob/master/quasi_iso_volume_subshell.m
%
% by
%     Dept. of Mechanical Engineering,
%     Imperial College London,
%     Exhibition Road
%     London SW7 2AZ
%     UNited Kingdom
%
%
% Copyright (c) 2016, Krishnakumar Gopalakrishnan and Teng Zhang, Imperial College London
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%
%     * Redistributions in binary form must reproduce the above
%       copyright notice, this list of conditions and the following
%       disclaimer in the documentation and/or other materials provided
%       with the distribution.
%
%     * Neither the name of Imperial College London nor the names of its
%       contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
