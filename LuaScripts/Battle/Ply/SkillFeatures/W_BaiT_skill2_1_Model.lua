--为自身施加持续8秒的护盾，抵挡相当于自身最大生命值20%的伤害，护盾持续期间，
--白驼每次释放普攻和技能都会为自身恢复生命值，恢复量相当于白驼最大生命值的5%。
---@class W_BaiT_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiT_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buffId = self:getParam(1)
    self.hasShield = false
    EventDispatcher:registerEvent("add_W_BaiT_skill2", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_BaiT_skill2", {self,self.removeBuffHandler})
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:spawn()
	 M.super.spawn(self)
end

function M:addBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) then
        self.hasShield = true
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.player) then
        self.hasShield = false
    end
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    if self.hasShield then
        local ply = data["player"]
        local config = data["skillConfig"]
        if self.player:equal(ply) then
            self.player.bufMgr:addBufById(self.buffId,self.player)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("add_W_BaiT_skill2", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_BaiT_skill2", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M