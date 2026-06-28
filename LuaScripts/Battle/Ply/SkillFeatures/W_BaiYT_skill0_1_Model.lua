--白玉堂迅速攻击当前敌人三次 前两次造成100%攻击力的内功伤害，最后一段会造成200%攻击力的内功伤害且必定暴击 
-- lv2 最后一击还会附加敌人最大生命值10%的伤害
---@class W_BaiYT_skill0_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BaiYT_skill0_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.maxDamage = self:getParam(1)--最大伤害量
    self.hpRate = self:getParam(2) -- 附加伤害 最大生命值10%的伤害
    --当前攻击次数
    self.curAtkCount = 0
    EventDispatcher:registerEvent("injure", {self,self.injureHandler})
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    self.curAtkCount = 0
end

---@param data Battle_HandleData_Injure
function M:injureHandler(eventName, data)
    local killer = data["killer"]
    local victim = data["victim"]
    local skillConfig = data["attackData"]["skillConfig"]
    if killer ~= nil and killer:equal(self.player) then
        if skillConfig ~= nil and skillConfig.anim_name == "skill0" then
            local my_damage = GlobalTools:Mul(victim.data:get_hp(), self.hpRate)
            local maxDmg = GlobalTools:Mul(self.player.data.atk:getValue(), self.maxDamage)
            if my_damage > maxDmg then
                my_damage = maxDmg
            end
            self.curAtkCount = self.curAtkCount + 1
            if self.curAtkCount == 3 then
                local attackData = table.shallow_copy(data["attackData"])
                attackData.prefabName = ""
                TimeTools:delayTime(GlobalTools.base0_1,function()
                    victim:beHitDirect(self.player, attackData, {damage = my_damage}, false, false)
                end)
                self.curAtkCount = 0
            end
        end
    end
end

-- 瞬移到敌人身后
function M:skill0Move(victim, flag)
    if victim ~= nil then
        if victim:isLive() ~= true then
            victim = nil
        end
        if victim ~= nil and SceneManager.curScene.getAreaPosition ~= nil then
            local pos = victim:get_position() - victim:getForward() * GlobalTools.base1
            if flag then
                pos = victim:get_position() + victim:getForward() * GlobalTools.base1
            end
            pos = SceneManager.curScene:getAreaPosition(pos)
            self.player:setPos(pos, true)
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill0_move" then
        local targetData = {
            ["count"] = "one",
            ["playerType"] = "player",
            ["camp"] = "myenemy",
            ["posIndex"] = "all",
            ["roleType"] = 0,
            ["priority"] = false,
            ["ignoreSummon"] = false,
            ["targetNoRepeat"] = false,
            ["campRace"] = "not",
            ["gender"] = "all",
            ["pos"] = "not",
            ["profession"] = "all",
            ["area"] = "all",
            ["areaWidth"] = 0,
            ["areaHeight"] = 0,
            ["areaAngle"] = 0,
            ["areaRadius"] = 0,
            ["forceSelect"] = false,
            ["selectLast"] = false,
            ["isFixPoint"] = false,
            ["useSelf"] = false,
            ["fixpoint"] = "enemyBackCenter"
        }
        local enemys = SelectTargetTool:findPlayerByType(targetData, self.player)
        local enemy = enemys:get(0)
        if enemy ~= nil then
            local forWard = BattleTool:checkPlayerAndTargetForward(self.player, enemy)
            if forWard == true then -- 面对敌人
                self:skill0Move(enemy)
            else
                self:skill0Move(enemy, true)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("injure", {self,self.injureHandler})
    M.super.destroy(self)
end

return M