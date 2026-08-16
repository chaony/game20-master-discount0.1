---@class BinaryHeap
local M = class("BinaryHeap")

function M:ctor(sortFunc)
    self.heap = {}
    self.sortFunc = sortFunc or function(a, b)
        return (a.G + a.H) < (b.G + b.H)
    end
end

function M:add(node)
    table.insert(self.heap, node)
    self:upadjust(#self.heap)
end

function M:popMin()
    if #self.heap == 0 then return nil end
    local min = self.heap[1]
    self.heap[1] = self.heap[#self.heap]
    table.remove(self.heap)
    if #self.heap > 0 then
        self:downadjust(1)
    end
    return min
end

function M:update(node)
    for i = 1, #self.heap do
        if self.heap[i] == node then
            self:upadjust(i)
            self:downadjust(i)
            break
        end
    end
end

function M:isEmpty()
    return #self.heap == 0
end

function M:clear()
    self.heap = {}
end

function M:contains(node)
    for i = 1, #self.heap do
        if self.heap[i] == node then
            return true
        end
    end
    return false
end

function M:upadjust(index)
    while index > 1 do
        local parentIndex = math.floor(index / 2)
        if self.sortFunc(self.heap[index], self.heap[parentIndex]) then
            self.heap[index], self.heap[parentIndex] = self.heap[parentIndex], self.heap[index]
            index = parentIndex
        else
            break
        end
    end
end

function M:downadjust(index)
    local size = #self.heap
    while index <= size do
        local left = index * 2
        local right = left + 1
        local smallest = index

        if left <= size and self.sortFunc(self.heap[left], self.heap[smallest]) then
            smallest = left
        end
        if right <= size and self.sortFunc(self.heap[right], self.heap[smallest]) then
            smallest = right
        end

        if smallest ~= index then
            self.heap[index], self.heap[smallest] = self.heap[smallest], self.heap[index]
            index = smallest
        else
            break
        end
    end
end

return M
