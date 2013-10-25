% splitcsv
% Returns a cell array of cell strings from parsing a csv file
%
% Usage:
%   >>  values = splitcsv(filename)
%
% Description:
% values = splitcsv(filename) opens and reads the csv file specified by
% filename and returns the individual lines of the file as elements of the
% values cell array. Each element of values is a cellstr array giving the
% individual comma-separated tokens. If the file doesn't exist or there is
% an error, values is an empty cell array.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for splitcsv:
%
%    doc splitcsv
%
% See also: tagcsv, tagcsv_input, pop_tagcsv
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: splitcsv.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function values = splitcsv(filename)
    fid = '';
    try 
        values = {};
        fid = fopen(filename);
        lineNum = 0;
        tline = fgetl(fid);
        while ischar(tline)   
            lineNum = lineNum + 1;
            values{lineNum} = strtrim(regexp(tline, ',', 'split')); %#ok<AGROW>
            tline = fgetl(fid);
        end   
    catch ME %#ok<NASGU>
        values = {};
    end 
    
    try % Attempt to close the file regardless of errors
        fclose(fid);
    catch ME %#ok<NASGU>
    end
end % splitcsv