--鬼谷 skill3被动
--鬼谷引动天雷，对所有敌人造成300%攻击力的伤害，若命中的敌人被添加了诛邪印机，则会额外造成一次伤害
---@class W_GuiG_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_GuiG_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.atk = self:getParam(1)
	EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end


function M:spawn()
    M.super.spawn(self) 
end


function M:injureHandler(eventName, data)
    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if victim ~= nil then
       if skillConfig ~= nil and skillConfig.anim_name == "skill3" then
            local guigu_skill3 = victim.bufMgr:findBufByTag("guigu_skill3")
                 --local songshan_skill3 = victim.bufMgr:findBufByTag("pilitang_skill2")
            if table.nums(guigu_skill3) > 0 then

            TimeTools:delayTime(GlobalTools.base0_1,
                function()
                   local attackData = BattleTool:getBaseAttackData()
                    --伤害定点数计算
                    local damage = GlobalTools:Mul(self.atk, self.player.data.atk:getValue())
                    attackData["damage"] = damage
                    attackData["player"] = self.player
                    attackData["damageFront"] = GlobalTools.base1
                    attackData["damageLast"] = GlobalTools.base1
                    attackData["angerAir"] = GlobalTools.base0
                    attackData["type"] = 0
                    attackData["injureBuf"] = 0
                    attackData["damageType"] = 1
                    attackData["skillConfig"] = skillConfig
                    victim.bufMgr:removeBufByTag("guigu_skill3")
                    victim:injure( attackData)
                    self:changeValue(victim)
                end)
                
            end
        end
    end
end


function M:changeValue(ply,value)
    
end


function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M