local Dungeon = {};
Dungeon.__index = Dungeon;

local Maze = require(script.Maze);
setmetatable(Dungeon, Maze);

local Rand = Random.new();

local House = require(script.House);
local Sett = require(script.Settings);

local oppDir = {W = 'E', E = 'W', S = 'N', N = 'S'};
local table = require(script.table);

Dungeon.new = function(sX, sY)
	local Self = Maze.new(sX, sY);
	
	Self.House = House.new(Self);
	
	return setmetatable(Self, Dungeon);
end;

function Dungeon:init()
	local oHouse = self.House;
	local Map = self.Map;
	local sX, sY = self.sX, self.sY;
	
	for i = 1, Sett.MAX_ROOM_TRIES do
		local szX = Rand:NextInteger(Sett.MIN_ROOM_SIZE.x, Sett.MAX_ROOM_SIZE.x);
		local szY = Rand:NextInteger(Sett.MIN_ROOM_SIZE.y, Sett.MAX_ROOM_SIZE.y);
			
		local Pos = {
			x = Rand:NextInteger(1, sX - szX - 1);
			y = Rand:NextInteger(1, sY - szY - 1);
		};
				
		local Coords = {Pos.x, Pos.y, Pos.x + szX, Pos.y + szY};
				
		local OK = oHouse:possible(unpack(Coords));
		
		if (OK) then
			oHouse:add(unpack(Coords));
		end;
		
		if (#oHouse.Rooms >= Sett.MAX_ROOMS) then break end;
	end;
	
	self:Recursive();
	
	if (#oHouse.Rooms > 1) then
	
		for _, v in next, oHouse.Rooms do
			local Outsiders = v.Outsiders;
			
			local Tries = 0;
			for i = 1, 2 do
				local selRoom;
				
				repeat
					local Cand = Outsiders[Rand:NextInteger(1, #Outsiders)];
					if (not Cand.Door) then
						
						local Dir do
							if (Cand.onlyDir) then
								Dir = Cand.onlyDir;
							else
								local availDirs = table.keys(Cand.availDirs);
								Dir = availDirs[Rand:NextInteger(1, #availDirs)];
							end	
						end 
																								
						local Opp = Cand:getCellOfDirection(Map, Dir);
						
						Cand:DelInBetween(Opp, Dir);
						Cand.Door = Dir;
						
						table.insert(oHouse.Doors, Cand);
						break;
					end;
					
					Tries = Tries + 1;
				until Tries >= Sett.ROOM_BORDER_RETRIES;
				
				if (Tries >= Sett.ROOM_BORDER_RETRIES) then return end;
			end;
		end;
		
		self:searchForDoor(oHouse);
		
	end;
	
	for i = 1, sX do
		for j = 1, sY do
			local Cell = Map[i][j];
			if (not Cell.isRoom and not Cell.isPath) then
				local Dirs = Cell.availDirs; -- Avoid new table creation
				
				Dirs.W = false;
				Dirs.E = false;
				Dirs.S = false;
				Dirs.N = false;
				
				local Neighbors = Cell:GetNonRoomNeighbors(self);
				
				for _, v in next, Neighbors do
					local Dir, oCell = v.Dir, v.Cell;
					
					if (oCell.isPath) then
						oCell.availDirs[oppDir[Dir]] = true;
						break;
					end
				end;
			end;
		end;
	end;
end;

return Dungeon;
