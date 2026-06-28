---@class W_TianL_skill3_Model : SkillFeatures_Model
local M = class("W_TianL_skill3_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.cureRate = self:getParam(1)
end

function M:spawn()
    M.super.spawn(self)
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("add_W_TianL_skill3", {self,self.addBuff})
end

function M:SkillEnterHandler(eventName, data)
    local ply = data["player"]
    local config = data["skillConfig"]
    if self.player:equal(ply) and config ~= nil and "attack1" == config.anim_name then
        local buffs = self.player.bufMgr:findBufByTag("W_TianL_skill3")
        if #buffs > 0 then
            if config.extra_anim_name ~= nil then
                config.extra_anim_name = config.extra_anim_name.."_skill3"
            else
                config.extra_anim_name = config.anim_name.."_skill3"
            end
        end
    end
end

function M:addBuff(eventName, data)
    local buf = data.buff
    if buf ~= nil and buf.player ~= nil and self.player:equal(buf.player) then
        local hp_cha = self.player.data:get_hp() - self.player.data:get_curHp()
        local cureHp = GlobalTools:Mul( hp_cha, self.cureRate )
        self.player:cure("fix", self.player, cureHp, self.skill, false)
    end
end

function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("add_W_TianL_skill3", {self,self.addBuff})

end

return M