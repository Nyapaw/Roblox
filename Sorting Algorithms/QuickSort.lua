-- LR pointers

local quick = {};

local function partition(arr, low, high, callback)
    local pivot = arr[high]; -- given arr[low] -> arr[high], splits the array between this pivot.

    local j = low - 1;

    for i = low, high - 1 do
        if callback and callback(arr[i], pivot) or arr[i] < pivot then
            j = j + 1;
            arr[i], arr[j] = arr[j], arr[i];
        end;
    end;

    arr[j + 1], arr[high] = arr[high], arr[j + 1]; -- swap high with the "median" of the two arrays

    return j + 1; -- Returns the index splitting the two sorted partitions
end;

local function sort(arr, low, high, callback)
    local i = partition(arr, low, high, callback);

    sort(arr, low, i - 1, callback);
    sort(arr, i + 1, high);
end;

quick.sort = function(arr, callback)
    return sort(arr, 1, #arr, callback)
end;

return quick;
