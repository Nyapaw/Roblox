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
	
	(Note: 	Insertion Sort is a generally slower algorithm compared to other algorithms like Merge Sort and Quicksort. 
			However, it manages memory better than Merge Sort.)
	
	
	InsertionSort.Sort(<Table> Array)
		Sorts the array lexicographically (string) or numerically (number) from least to greatest.
		
	InsertionSort.Sort(<Table> Array, [<Callback> SortingFunction])
		Sorts the array with a callback; given two parameters, Sorts the array with a callback; given two parameters,
		the function must return a boolean from comparing the first is greater than the second.
	
	InsertionSort.Sort(<Table> Array, [<Callback> SortingFunction], [<Boolean> ReverseSort])
		Sorts the array in reverse instead of chronological order, if ReverseSort is true.
	
--]]

local InsertionSort = {};

local function Sort(Array, Index, Callback)
	if (Index <= 1) then return end;
		
	Sort(Array, Index - 1, Callback); -- Index 2 will always run first (if it exists)
	
	local tIndex = Index;
		
	while (tIndex > 1) do
		if ((Callback and Callback(Array[tIndex - 1], Array[tIndex])) or (Array[tIndex - 1] > Array[tIndex])) then
			Array[tIndex], Array[tIndex - 1] = Array[tIndex - 1], Array[tIndex];
			tIndex = tIndex - 1;
		else
			break;
		end;
	end;
end;

local function Reverse(Array)
	for i = 1, math.floor(#Array * .5) do
		Array[i], Array[#Array - i + 1] = Array[#Array - i + 1], Array[i];
	end;
end;

InsertionSort.Sort = function(Array, Callback, SortReverse)
	Sort(Array, #Array, Callback);
	if (SortReverse) then Reverse(Array) end;
	return Array;
end;

return InsertionSort;