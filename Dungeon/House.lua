local House = {};
House.__index = House;

local Room = require(script.Room);
local Sett = require(script.Parent.Settings);

local l = Sett.ROOM_BORDER_LENIANCY;

House.new = function(Maze)
	local Self = {};
	
	Self.Maze = Maze;
	Self.Rooms = {};
	Self.Doors = {};
	
	return setmetatable(Self, House);
end;

function House:add(...)
	table.insert(self.Rooms, Room.new(self.Maze, ...));
end;

function House:possible(x1, y1, x2, y2)
	local Maze 	= self.Maze;
	
	local sX	= Maze.sX;
	local sY	= Maze.sY;
	local Map	= Maze.Map;
	
	if (Map[x1][y1].closeToRoom or 
		Map[x2][y1].closeToRoom or
		Map[x1][y2].closeToRoom or
		Map[x2][y2].closeToRoom) then 
	
		return false;
	end;
	
	return true;
end;

return House;
