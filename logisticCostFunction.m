## Copyright (C) 2017 Uche Ofuonye
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} logisticCostFunction (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Uche Ofuonye <ofuon001@Ochmandada.local>
## Created: 2017-01-09

function [jVal, gradient] = logisticCostFunction (theta)
  jVal = (theta(1) -5)^2 + (theta(2) -5) ^2;
  gradient = zeros(2,1);
  gradient(1) = 2*(theta(1)-5);
  gradient(2) = 2*(theta(2)-5);
endfunction
