local Room = {};
setmetatable(Room, {__index = Room});

local Sett = require(script.Parent.Parent.Settings);
local l = Sett.ROOM_BORDER_LENIANCY;
local r = Sett.ROOM_BORDER

local function ir(min, max, num)
	return num >= min and num <= max;
end;

local function assign(Self, Cell, Dir)
	table.insert(Self.Outsiders, Cell);
	Cell.outRef = Self;
	Cell.onlyDir = Dir;
end

Room.new = function(Maze, x1, y1, x2, y2)
	local Self = {};
	
	local sX	= Maze.sX;
	local sY	= Maze.sY;
	
	Self.ref = Maze;
	Self.tl = {x = x1, y = y1};
	Self.br = {x = x2, y = y2};
		
	Self.Outsiders = {};
		
	local Map = Maze.Map;
		
	for x = math.max(1, x1 - l), math.min(x2 + l, sX) do
		for y = math.max(1, y1 - l), math.min(y2 + l, sY) do
			local Cell = Map[x][y];
			
			if not (x < x1 or y < y1 or x > x2 or y > y2) then
				Cell.Visited = true;
				Cell.isRoom = true;
				
				do
					local Dirs = Cell.availDirs;
					
					if (x ~= x1) then Dirs.W = nil; end;
					if (x ~= x2) then Dirs.E = nil; end;
					if (y ~= y1) then Dirs.N = nil; end;		
					if (y ~= y2) then Dirs.S = nil; end;
				end;	
			end;
			
			Cell.closeToRoom = true;
			
			if (x >= 1 and y >= 1 and x <= sX and y <= sY) then
			
				if (x > 1 and y > 1 and x < sX and y < sY) then
					if (
						(x == x1 and ir(y1, y2, y)) or
						(y == y1 and ir(x1, x2, x)) or
					 	(x == x2 and ir(y1, y2, y)) or
						(y == y2 and ir(x1, x2, x)) )
					then
						table.insert(Self.Outsiders, Cell);
						Cell.outRef = Self;
					end;
				end;
				
				do -- This section is poorly optimized. I can do better maybe.
					local d = Cell.availDirs;
					
					if (x == x1 and x == 1) or (x == x2 and x == sX) then
						if (y == y2 and d.S and y ~= sY) then
							assign(Self, Cell, 'S');
						end;
						
						if (y == y1 and d.N and y ~= 1) then
							assign(Self, Cell, 'N');
						end;
					end;
						
					if (y == y1 and y == 1) or (y == y2 and y == sY) then
						if (x == x2 and d.E and x ~= sX) then
							assign(Self, Cell, 'E');
						end
						
						if (x == x1 and d.W and x ~= 1) then
							assign(Self, Cell, 'W');
						end
					end;
				end;
			
			end;

		end;
	end;
		
	return setmetatable(Self, Room);
end;

return Room;
