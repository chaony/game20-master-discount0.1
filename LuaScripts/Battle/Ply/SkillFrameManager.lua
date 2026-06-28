--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:33:41
]]

--技能帧管理器
---@class SkillFrameManager @
local M = class("SkillFrameManager")

--所有的技能帧
M.skillFrames = nil
--玩家
M.player = nil
--初始化 
function M:init( player )
    self.player = player
    self.skillFrames = Battle.List.new()
end

--加入一个技能帧
function M:addFrame( frame )
    self.skillFrames:add(frame)
end

--更新技能管理器
function M:update(dt,unsdt)
    for i=self.skillFrames.Count,1,-1 do
        local frame = self.skillFrames:get(i-1)
        if frame.finish == true then
            frame:destroy()
            self.skillFrames:removeAt(i-1)
        else
            frame:update(dt,unsdt)	
        end
         
    end
end

function M:setPosition( )
	
end


--销毁
function M:destroy()
    for i=self.skillFrames.Count,1,-1 do
        local frame = self.skillFrames:get(i-1)
        frame:destroy() 
    end
end

return M