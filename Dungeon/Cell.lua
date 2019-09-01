local Cell = {};
Cell.__index = Cell;

local oppDir = {W = 'E', E = 'W', S = 'N', N = 'S'};

Cell.new = function(x, y)	
	local Self = {};
	
	Self.x = x;
	Self.y = y;
	
	Self.Visited = false;
	Self.isRoom = false;
	Self.availDirs = {N = true, E = true, S = true, W = true};
	
	Self.closeToRoom = false;
	Self.Door = false;
	Self.Filled = false;
	
	Self.outRef = nil;
	
	return setmetatable(Self, Cell);
end;

function Cell:DelInBetween(oCell, Side)
	self.availDirs[Side] = nil;
	oCell.availDirs[oppDir[Side]] = nil;
end;

function Cell:getFacingDir(oCell)
	return  self.x > oCell.x and 'W'
		or  self.x < oCell.x and 'E'
		or  self.y > oCell.y and 'N'
		or						 'S';
end;

function Cell:isOpenWithCell(oCell)
	local Dir = self:getFacingDir(oCell);
	
	return (not self.availDirs[Dir]) and (not oCell.availDirs[oppDir[Dir]]);
end;

function Cell:getCellOfDirection(Map, Dir)	
	local tX, tY = self.x, self.y;
		
	return 	Dir == 'W' and Map[tX - 1] and Map[tX - 1][tY] or
			Dir == 'E' and Map[tX + 1] and Map[tX + 1][tY] or
			Dir == 'N' and Map[tX][tY - 1] or
			Dir == 'S' and Map[tX][tY + 1];
end;

function Cell:GetUnvisitedNeighbors(fMap)
	local Map = fMap.Map;
	local tX, tY = self.x, self.y;
	local Neighbors = {};
	
	for Dir in next, {N = true, E = true, S = true, W = true} do		
		local oCell = self:getCellOfDirection(Map, Dir);
		
		if (oCell and not oCell.Visited) then
			table.insert(Neighbors, {Dir = Dir, Cell = oCell});
		end;
	end;
	
	return Neighbors;
end;

function Cell:GetVisitedNeighbors(fMap)
	local Map = fMap.Map;
	local tX, tY = self.x, self.y;
	local Neighbors = {};
	
	for Dir in next, {N = true, E = true, S = true, W = true} do		
		local oCell = self:getCellOfDirection(Map, Dir);
		
		if (oCell and oCell.Visited and not oCell.isRoom) then
			table.insert(Neighbors, {Dir = Dir, Cell = oCell});
		end;
	end;
	
	return Neighbors;
end;

function Cell:GetNonRoomNeighbors(fMap)
	local Map = fMap.Map;
	local tX, tY = self.x, self.y;
	local Neighbors = {};
	
	for Dir in next, {N = true, E = true, S = true, W = true} do		
		local oCell = self:getCellOfDirection(Map, Dir);

		if (oCell and (not oCell.isRoom or oCell.outRef) and self:isOpenWithCell(oCell)) then
			table.insert(Neighbors, {Dir = Dir, Cell = oCell});			
		end;
	end;
	
	return Neighbors;
end;


return Cell;
