local Maze = {};
Maze.__index = Maze;

local Cell = require(script.Cell);
local Rand = Random.new(tick());

local table = require(script.Parent.table);
local oppDir = {W = 'E', E = 'W', S = 'N', N = 'S'};

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

Maze.toHunt = function(self) -- Hunt and kill
	for X = 1, self.sX do
		for Y = 1, self.sY do
			local pCell = self.Map[X][Y];
			if (not pCell.Visited) then
				pCell.Visited = true;
				local visNeighbors = pCell:GetVisitedNeighbors(self);
				
				if (#(visNeighbors) ~= 0) then					
					local pickedNeighbor = visNeighbors[Rand:NextInteger(1, #visNeighbors)];
					local relDir, oCell = pickedNeighbor.Dir, pickedNeighbor.Cell;
					pCell:DelInBetween(oCell, relDir);
					Maze.Traverse(oCell, self);
				end;
			end;
		end;
	end;
end;

Maze.Traverse = function(tCell, self)
	tCell.Visited = true;
	
	local Neighbors = tCell:GetUnvisitedNeighbors(self);
	
	if (#(Neighbors) == 0) then
		Maze.toHunt(self);
	else
		local pickedNeighbor = Neighbors[Rand:NextInteger(1, #Neighbors)];
		local relDir, oCell = pickedNeighbor.Dir, pickedNeighbor.Cell;
		tCell:DelInBetween(oCell, relDir);
		Maze.Traverse(oCell, self);
	end;
end;

function Maze:wipeFilled()
	for _, v in next, self.Map do
		for _, k in next, v do
			k.Filled = false;
		end;
	end;
end;

function Maze.Search(oMaze, origCell)
	oMaze:wipeFilled();
	
	local cPath;
		
	local function Search(tCell, Path)
		if (tCell.isRoom) then
			if (tCell.outRef ~= origCell.outRef) then
				return;
			end;
		end;
		
		table.insert(Path, tCell);
		
		tCell.Filled = true;
		
		if (tCell.isRoom) then
			return;
		end;
		
		local Neighbors = tCell:GetNonRoomNeighbors(oMaze);
				
		for _, v in next, Neighbors do
			local relDir, Cell = v.Dir, v.Cell;
			
			if (Cell.Door and origCell.outRef ~= Cell.outRef) then
				table.insert(Path, Cell);
				cPath = Path;
				break;
			end;
		end;
				
		if (not cPath) then
			for _, v in next, Neighbors do	
				if ((not v.Cell.Filled or v.isPath)) then 
					Search(v.Cell, table.shallow(Path));
				end;
			end;
		end;
	end;
	
	local look = origCell.Door;
	local lookCell = origCell:getCellOfDirection(oMaze.Map, look);
	lookCell.isMaze = true;
	
	Search(lookCell, {origCell});
	
	if (cPath) then
		for _, v in next, cPath do
			v.isPath = true;
		end;
	end;
	
end;

function Maze:huntAndKill()
	local sX, sY = self.sX, self.sY;
	
	for i = 1, sX do
		for j = 1, sY do
			local Cell = self.Map[i][j];
			if (not Cell.isRoom) then
				Maze.Traverse(Cell, self);
				return;
			end
		end;
	end;
end;

function Maze:Recursive()
	self.unfixedCells = {}; -- internal
	
	local uCells = self.unfixedCells;
	
	local sX, sY = self.sX, self.sY;
	local Map = self.Map;
	
	for i = 1, sX do
		for j = 1, sY do
			local Cell = Map[i][j];
			if (not Cell.isRoom) then
				table.insert(uCells, Cell);
			end;
		end;
	end;
	
	while (#uCells > 0) do
		local curCell = uCells[#uCells];
		curCell.Visited = true;
				
		local Neighbors = curCell:GetUnvisitedNeighbors(self);
		if (#Neighbors ~= 0) then
			local pickedNeighbor = Neighbors[Rand:NextInteger(1, #Neighbors)];
			
			local relDir, oCell = pickedNeighbor.Dir, pickedNeighbor.Cell;
			curCell:DelInBetween(oCell, relDir);
			
			table.insert(uCells, oCell);
		else
			table.remove(uCells);
		end;
	end;
end;

function Maze:searchForDoor(House)
	local Doors = House.Doors;
	
	for _, v in next, Doors do
		if (not v.Filled) then
			Maze.Search(House.Maze, v);
		end;
	end;
	
	for _, v in next, Doors do
		if (not v.isPath) then
			local look = v.Door;
			local lookCell = v:getCellOfDirection(self.Map, look);
			
			v.availDirs[look] = true;
			lookCell.availDirs[oppDir[look]] = true;
		end;
	end;
end;

return Maze;
