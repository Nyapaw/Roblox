You should arrange the dependency tree like this.

![Files](https://user-images.githubusercontent.com/45115274/64079691-55a12000-cc9f-11e9-88de-e3fed3175bc2.png)

API: 

(You can change settings in Settings.lua)

**Dungeon.new(int X, int Y)** - Makes a new dungeon. Returns <Dungeon> with non initialized cells.
  
**Dungeon:init()** - Run the dungeon algorithm
