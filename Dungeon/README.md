You should arrange the dependency tree like this.

![Files](https://user-images.githubusercontent.com/45115274/64079691-55a12000-cc9f-11e9-88de-e3fed3175bc2.png)

API: 

(You can change settings in Settings.lua)

**Dungeon.new(int X, int Y)** - Makes a new dungeon. Returns a Dungeon object with non initialized cells.
  
**Dungeon:init()** - Run the dungeon algorithm

**Dungeon.Map** -> A 2D matrix of Cells in X, Y order.

**Cell.availDirs** -> A dictionary of directions (N, E, S, W as keys) that are walled.

I also included a .rbxl file of the examples shown here with the 3D cells.
https://devforum.roblox.com/t/dungeon-generation-a-procedural-generation-guide/342413/1
