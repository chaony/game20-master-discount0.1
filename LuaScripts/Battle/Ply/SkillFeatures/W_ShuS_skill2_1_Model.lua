-- 蜀山每次释放普攻的同时，还会发射出一道剑羽攻击当前目标，剑羽会造成30%普攻伤害，
-- 当蜀山的普攻造成暴击时，发射5道剑羽攻击敌方（多个英雄平均分配，不打宠物）

---@class W_ShuS_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_ShuS_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    
    self.shootNum = self:getParam(1)   -- Fix[0-200]  -- 暴击后发射n道剑羽攻击敌方
    self.addBuff1 = self:getParam(2)    -- Buff[] -- 印记
    self.damageLast = self:getParam(3)    -- Fix[0-2] -- 剑羽的后伤害百分比

    if self.shootNum > 10 then
        Logger.logError(self.shootNum, "蜀山的飞羽不能超过10")
        self.shootNum = Mathf.Min(self.shootNum, 10)
    end
end

--- 普攻还发射一道剑羽
---@param data AnimEvtFrame_Model
function M:skillDispatch(data)
    if data.eventName == "ShuS_attack1_hit" then
        self.player:set_forceSkillConfig(self.skill)
        self:shootOnce()
        self.player:set_forceSkillConfig(nil);
    end
end

function M:killerBeforeAttack(attackData, victim)
    if attackData.skillConfig == self.skill then
        if attackData.injureType ~= "buff" then     -- 由技能2引爆的buff不享受此效果
            attackData.damageLast = attackData.damageLast + self.damageLast
        end
    end
end

--攻击结束处理,如果暴击，则发射5记剑羽(平均分配给敌方侠客)
---@param afterAttackData Battle_HandleData_Attack
function M:killerAfterAttack(afterAttackData)
    if afterAttackData.isCrit then
        local skillConfig = afterAttackData.attackData.skillConfig
        if skillConfig and skillConfig.anim_name == "attack1" then
            self.player:set_forceSkillConfig(self.skill)
            self.isTriggerCrit = true
            
            do
                local enemys = self.player.plyMgr:getPlayers(-self.player.camp)
                for i = 1, self.shootNum do
                    if enemys.Count > 0 then
                        local index = (i-1)%enemys.Count
                        self.atkTarget = enemys:get(index)
                        self:shootOnce()
                    end
                end
            end

            self.player:set_forceSkillConfig(nil);
            self.isTriggerCrit = false
        end
    end
end

function M:shootOnce()
    if self.player.evtMgr ~= nil then       -- 如果死亡了就没有事件管理器了
        if self:isInAir() then
            self.player.evtMgr:commonEventWork( "Shoot", 2)
        else
            self.player.evtMgr:commonEventWork( "Shoot", 1)
        end
    end
end

function M:isInAir()
    if not self.skill3 then
        local skill3 = self.player.plySkill:getSkillByName("skill3")
        if skill3 and skill3.cur_skill_config then
            self.skill3 = skill3.cur_skill_config.feature
        end
    end
    return self.skill3 and self.skill3:isInAir()
end

---@param data Battle_List
function M:findPlayer(data)
    if self.isTriggerCrit and self.atkTarget then
        data:clear()
        data:add(self.atkTarget)
        return data
    end
    return data
end

return M