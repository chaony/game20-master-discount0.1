--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-13 18:20:47
]]
---@class LineManager_Model @连线管理
---@field lineList Battle_List<Line_Model>
local M = class("LineManager_Model")

--连线数组
M.lineList = nil

--最大连线数
M.maxNum = 1000

--我的管理者
M.player = nil
--初始化
function M:init(player)
    self.maxNum = 1000
    self.player = player
    self.lineList = Battle.List.new()
end

--加入一条连线
---@param line Line_Model
function M:addLine(line)
    self.lineList:add(line)
    if self.lineList.Count > self.maxNum then
        local line = self.lineList:get(0)
        line:destroy()
    end
end

--移除连线
function M:removeLine(line)
    self.lineList:remove(line)
end

--清除所有子弹
function M:clear()
    for i = self.lineList.Count, 1, -1 do
        self.lineList:get(i-1):destroy()
    end
    self.lineList:clear()
end

function M:update(dt)
    if self.lineList.Count > 0 then
        for i=self.lineList.Count,1,-1 do
            self.lineList:get(i-1):update(dt)
        end
    end
end

function M:destroy()
    self:clear()
end

return M