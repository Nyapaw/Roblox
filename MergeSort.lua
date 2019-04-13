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
	
	
	
	MergeSort.Sort(<Table> Array)
		Sorts the array lexicographically (string) or numerically (number) from least to greatest.
		
	MergeSort.Sort(<Table> Array, [<Callback> SortingFunction])
		Sorts the array with a callback; given two parameters, the function must return a boolean from comparing one to the other.
		Sorts in chronological order if first is greater than second, reverse vise-versa.
	
	
	
--]]

local MergeSort = {};

local function Merge(refArray, Array, lowerHalf, upperHalf, Callback)
    local lC, rC = 1, 1;
    
	--// Note that these functions aren't used to save lines of code, it makes unnecessary calls.
	--// https://devforum.roblox.com/t/why-i-dont-sleep-micro-macro-optimizing-mega-guide/71543
	
	--[[
		
	local function add_rC()
        table.insert(Array, upperHalf[rC]);
        rC = rC + 1;
    end;
    
    local function add_lC()
        table.insert(Array, lowerHalf[lC]);
        lC = lC + 1;
    end;

	]]

    while ((lC + rC) < (#lowerHalf + #upperHalf + 2)) do
        if (rC > #upperHalf) then
            while (lC <= #lowerHalf) do
                table.insert(Array, lowerHalf[lC]); --// add_lC()
                lC = lC + 1;
            end;
            break;
        elseif (lC > #lowerHalf) then
            while (rC <= #upperHalf) do
                table.insert(Array, upperHalf[rC]); --// add_rC()
                rC = rC + 1;
            end;
            break;
        end;
        
        if (Callback) then
            if (Callback(lowerHalf[lC], upperHalf[rC])) then
                table.insert(Array, lowerHalf[lC]);
                lC = lC + 1;
            else
                table.insert(Array, upperHalf[rC]);
                rC = rC + 1;
            end;
        else
            if (lowerHalf[lC] < upperHalf[rC]) then
                table.insert(Array, lowerHalf[lC]);
                lC = lC + 1;
            else
                table.insert(Array, upperHalf[rC]);
                rC = rC + 1;
            end;    
        end;
        
    end;
    
end;

local function arrFromRange(Array, lowerB, upperB)
    local Arr = {};
    for i = lowerB, upperB do
        table.insert(Arr, Array[i]);
    end;
    return Arr;
end;

local function Sort(refArray, lowerB, upperB, Callback)
    if (lowerB >= upperB) then return arrFromRange(refArray, lowerB, upperB); end;

    local mPt = math.floor((lowerB + upperB)*.5);
    
    local lArr = Sort(refArray, lowerB, mPt, Callback);
    local rArr = Sort(refArray, mPt + 1, upperB, Callback);
                
    local tempArr = {};
    Merge(refArray, tempArr, lArr, rArr, Callback);
        
    return tempArr;
end;

function MergeSort.Sort(Array, Callback)
    return Sort(Array, 1, #Array, Callback);
end;

return MergeSort;
