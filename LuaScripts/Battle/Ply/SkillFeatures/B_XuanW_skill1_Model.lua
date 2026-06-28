--玄武boss skill1
--荆棘护甲 进入防御5s期间自己无法攻击且自身防御提升50%，防御状态受到近战攻击时，会对攻击者造成100%自身防御力的伤害
---@class B_XuanW_skill1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("B_XuanW_skill1_Model", SkillFeatures_Model)


function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --防御提升buf
    self.atk = self:getParam(1)
    self.anim_time = self:getParam(2)
    self.cur_time = self.anim_time
    self.skill1_start = GlobalTools.base2;
    self.start = false
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

--技能结束
function M:skillEnd()
    --self.player.animator:changeState("skill1_end")
    self.skill1_start = GlobalTools.base2;
    self.cur_time = self.anim_time
    self.start = false
end

function M:skillStart()
    self.start = true
end

function M:update(dt,unsdt)
    M.super.update(self,dt,unsdt)
    if self.start == true then
        if self.skill1_start > 0  then
            self.skill1_start = self.skill1_start - dt
        end
        if self.skill1_start <= 0  then
            if self.cur_time > 0 then
                self.cur_time = self.cur_time - dt
                if self.cur_time <= 0 then
                    self.player.animator:changeState("skill1_end")
                    self.start = false
                end
            end
        end
    end
end

function M:injureHandler(eventName, data)

    local ply = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    local wantdata = data["wantdata"]
    local dmg = wantdata["damage"]
    if victim ~= nil and victim:equal(self.player) and ply:equal(self.player) == false then
        if ply ~= nil and ply.plyData.fight_type == 1 and self.skill ~= nil and self.skill.anim_name == "skill1"  then
            local attackData = BattleTool:getBaseAttackData()
            attackData["damage"] = self.player.data.atk:getValue()
            attackData["player"] = self.player
            attackData["damageFront"] = self.atk
            attackData["damageLast"] = GlobalTools.base1
            attackData["angerAir"] = GlobalTools.base0
            attackData["type"] = 3
            attackData["injureBuf"] = 0
            attackData["damageType"] = 1
            attackData["skillConfig"] = self.skill
            --local wantdata = {}
            --wantdata["damage"] = attackData["damage"]
            --wantdata["suck_value"]  = 0     
            ply:injure( attackData)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    self.skill1_start = GlobalTools.base2
    self.cur_time = self.anim_time
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
end






return M