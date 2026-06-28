--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:29:42
]]

--移动帧管理器
---@class MoveFrameManager @
local M = class("MoveFrameManager")
MoveGeneral = require("Battle.Ply.Fuc.MoveGeneral")
--移动帧的list
M.moveFrames = nil
--玩家
M.player = nil
--初始化 
function M:init( player )
    self.player = player
    self.moveFrames = Battle.List.new()
end

--加入一个移动帧
function M:addFrame( frame )
    self.moveFrames:add(frame)
end

--更新管理器
function M:update(dt)
    for i=self.moveFrames.Count,1,-1 do
        local frame = self.moveFrames:get(i-1)
        frame:update(dt)
    end
end

--移除
function M:removeMove(frame)
    self.moveFrames:remove(frame)
end

--清空数据
function M:clear()
   for i=self.moveFrames.Count,1,-1 do
        local frame = self.moveFrames:get(i-1)
        frame:destroy()
    end
    self.moveFrames:clear()
end

function M:destroy()
    self:clear()
end

return M