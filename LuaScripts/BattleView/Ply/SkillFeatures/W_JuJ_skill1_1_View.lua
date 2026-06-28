--巨鲸 skill1 每隔8秒 巨鲸会使用海潮之力强化自身 
--使自己的下一次普工威力提升至180%攻击力且变为范围伤害
---@class W_JuJ_skill1_1_View : SkillFeatures_View @
---@field super SkillFeatures_View @SkillFeatures_View
local M = class("W_JuJ_skill1_1_View", SkillFeatures_View)


function M:init(player, skill, model)
    M.super.init(self, player, skill, model)
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

function M:spawn()
    M.super.spawn(self)
    if self.player.tranformHelper ~= nil and IsNull(self.player.tranformHelper) == false then
        self.wepon = self.player.tranformHelper:FindObj(self.player.tran, "jujing_weapon1")
    end
    if self.wepon ~= nil and IsNull(self.wepon) == false and  self.wepon.gameObject ~= nil and IsNull(self.wepon.gameObject) == false then
        self.wepon.gameObject:SetActive(false)
    end
end

--技能释放
function M:SkillEndHandler( eventName, data )
    if self.wepon ~= nil and IsNull(self.wepon) == false and self.wepon.gameObject ~= nil and IsNull(self.wepon.gameObject) == false  then
        self.wepon.gameObject:SetActive(false)
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end




return M