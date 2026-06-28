--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:38:51
]]

--加速
---@class BufWorkSpeedUp : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkSpeedUp", BufWork_Model)

function M:initFinish()
    self.isSpeed = self.playerBuf:checkParam("SlowDownOrSpeedUp")
    self.value = self.playerBuf:checkParam("speed")
    if self.isSpeed == true then
    	self.playerBuf.player.data.haste:addToAddList(self.value)
    elseif self.isSpeed == false then
    	self.playerBuf.player.data.haste:addToAddList(-self.value)
    end
end

function M:stop()
    M.super.stop(self)
 	if self.isSpeed == true then
    	self.playerBuf.player.data.haste:removeFromAddList(self.value)
    elseif self.isSpeed == false then
    	self.playerBuf.player.data.haste:removeFromAddList(-self.value)
    end
end

return M