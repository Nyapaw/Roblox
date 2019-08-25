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
	
	
	-------
	
	This implements the Hunt-and-kill algorithm.
	https://developer.roblox.com/articles/Hunt-and-Kill
	
	-------
	
	[!] This script needs the 'Cell' ModuleScript parented into it in order to work! [!]
	
	API:
	
	Maze.new(<Int> sizeX, <Int> sizeY)
		Returns: <MazeObject>
		---
		Creates a new maze with sizeX (# of rows) and sizeY (# of columns).
		
	Maze:init()
		Returns: <void>
		---
		Calls the generation algorithm on the maze. You must run this in order to have an actual maze object.
		
	
	References for <MazeObject>:
		MazeObject.sX			: <Int> # of rows
		MazeObject.sY			: <Int> # of columns
		MazeObject.Map			: <Array(CellObject)> A two-dimentional matrix containing the list of <CellObject>
		
	References for <CellObject>:
		CellObject.availDirs	: <Array(Char)> The "available" walls that are existant of that cell. 
								  The possibility for characters found in this array are 'N', 'E', 'S', 'W'.
	
	
--]]


local Maze = {};
Maze.__index = Maze;

local Cell = require(script.Cell);
local Rand = Random.new();

local function tLen(Table)
	local tLen = 0;
	for _ in next, Table do
		tLen = tLen + 1;
	end;
	return tLen;
end;

Maze.new = function(sizeX, sizeY)
	if (sizeX < 1 or sizeY < 1) then
		return;
	end;
	
	local Self = {};
	Self.Map = {};
	
	local mazeInfo = {x = sizeX, y = sizeY};
	
	for X = 1, sizeX do
		Self.Map[X] = {};
		for Y = 1, sizeY do
			Self.Map[X][Y] = Cell.new(X, Y);
		end;
	end;
	
	Self.sX = sizeX;
	Self.sY = sizeY;
	
	return setmetatable(Self, Maze);
end;

Maze.toHunt = function(self)
	for X = 1, self.sX do
		for Y = 1, self.sY do
			local pCell = self.Map[X][Y];
			if (not pCell.Visited) then
				pCell.Visited = true;
				local visNeighbors = pCell:GetVisitedNeighbors(self);
				if (tLen(visNeighbors) ~= 0) then
					
					local pickedNeighbor = visNeighbors[Rand:NextInteger(1, #visNeighbors)];
					local relDir, oCell = pickedNeighbor.Dir, pickedNeighbor.Cell;
					oCell:DelInBetween(pCell, relDir);
					Maze.Traverse(oCell, self);
				end;
			end;
		end;
	end;
end;

Maze.Traverse = function(tCell, self)
	tCell.Visited = true;
	
	local Neighbors = tCell:GetUnvisitedNeighbors(self);
	
	if (tLen(Neighbors) == 0) then
		Maze.toHunt(self);
	else
		local pickedNeighbor = Neighbors[Rand:NextInteger(1, #Neighbors)];
		local relDir, oCell = pickedNeighbor.Dir, pickedNeighbor.Cell;
		oCell:DelInBetween(tCell, relDir);
		Maze.Traverse(oCell, self);
	end;
	
end;

function Maze:init()
	local sX, sY = self.sX, self.sY;
	local sPtX, sPtY = Rand:NextInteger(1, sX), Rand:NextInteger(1, sY);
	
	Maze.Traverse(self.Map[sPtX][sPtY], self);
end;

return Maze;
