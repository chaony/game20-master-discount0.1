--角色的专属装备
-- 藏剑 释放绝技后，添加一个时长为5秒的提升自身暴击率和暴击伤害50%的buf

---@class W_CangJ_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_CangJ_Trait0", PlayerTrait)

M.buffId = 0
function M:init()
    M.super.init(self)
	self.buffId = self:getValue(1)

	EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

--技能释放
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if ply == self.player  and ply:isLive() == true then
        if config ~= nil then  
            if config.anim_name == "skill3" then
            	self.player.bufMgr:addBufById(self.buffId, self.player)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
    M.super.destroy(self)
end

return M