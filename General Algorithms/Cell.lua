--[[
	
	Copyright 2019 Nyapaw ©
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	    http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	
--]]

local Cell = {};
Cell.__index = Cell;

local oppDir = {W = 'E', E = 'W', S = 'N', N = 'S'};

Cell.new = function(x, y, mazeInfo)
	local mX, mY = mazeInfo.x, mazeInfo.y;
	
	local Self = {};
	
	Self.x = x;
	Self.y = y;
	
	Self.Visited = false;
	Self.availDirs = {N = true, E = true, S = true, W = true};
	
	return setmetatable(Self, Cell);
end;

function Cell:DelInBetween(oCell, Side)
	self.availDirs[Side] = nil;
	oCell.availDirs[oppDir[Side]] = nil;
end;

function Cell:GetUnvisitedNeighbors(fMap)
	local Map = fMap.Map;
	local tX, tY = self.x, self.y;
	local Neighbors = {};
	
	for Dir in next, {N = true, E = true, S = true, W = true} do
		table.insert(Neighbors, 
			(tX > 1 and Dir == 'W' and not Map[tX - 1][tY].Visited) and {Dir = 'W', Cell = Map[tX - 1][tY]} or
			(tX < fMap.sX and Dir == 'E' and not Map[tX + 1][tY].Visited) and {Dir = 'E', Cell = Map[tX + 1][tY]} or
			(tY > 1 and Dir == 'N' and not Map[tX][tY - 1].Visited) and {Dir = 'N', Cell = Map[tX][tY - 1]} or
			(tY < fMap.sY and Dir == 'S' and not Map[tX][tY + 1].Visited) and {Dir = 'S', Cell = Map[tX][tY + 1]} or
			nil
		);	
	end;
	
	return Neighbors;
end;

function Cell:GetVisitedNeighbors(fMap)
	local Map = fMap.Map;
	local tX, tY = self.x, self.y;
	local Neighbors = {};
	
	for Dir in next, {N = true, E = true, S = true, W = true} do
		table.insert(Neighbors, 
			(tX > 1 and Dir == 'W' and Map[tX - 1][tY].Visited) and {Dir = 'W', Cell = Map[tX - 1][tY]} or
			(tX < fMap.sX and Dir == 'E' and Map[tX + 1][tY].Visited) and {Dir = 'E', Cell = Map[tX + 1][tY]} or
			(tY > 1 and Dir == 'N' and Map[tX][tY - 1].Visited) and {Dir = 'N', Cell = Map[tX][tY - 1]} or
			(tY < fMap.sY and Dir == 'S' and Map[tX][tY + 1].Visited) and {Dir = 'S', Cell = Map[tX][tY + 1]} or
			nil
		);	
	end;
	
	return Neighbors;
end;

return Cell;
