--武当在战场上降下真武剑阵，并在持续时间内每秒对剑阵内的敌人造成150%攻击力的伤害和0.5秒的眩晕效果，若命中的敌人身上存在有护盾，则该技能造成的伤害提升100%。
--释放该绝技不会立即消耗所有内力，而是在真武剑阵持续期间，每秒消耗250点内力，当内力消耗完时，真武剑阵效果结束
---@class W_WDang_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_WDang_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    --每次消耗内力
    self.angerCost = self:getParam(1)
    --有护盾造成的伤害
    self.dmg = self:getParam(2)
    --每多放一次技能额外伤害
    self.extraDmg = self:getParam(3)
    --最大次数
    self.maxCount = self:getParam(4)
    --攻击受击不会回复怒气
    self.angerBuff = self:getParam(5)
    --敌方半场的群体buff
    self.enemyAreaBuff = self:getParam(6)
    --己方半场的群体buff
    self.friendAreaBuff = self:getParam(7)
    
    self.count = 0
    self.player.skill3ClearAnger = false
    self.start = false
    self.timer = GlobalTools.base1

    EventDispatcher:registerEvent("add_W_WDang_skill3", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_WDang_skill3", {self,self.removeBuffHandler})
end
--
----技能释放(仅当前技能调用)
function M:skillStart(data)
    M.super.skillStart(self, data)
    --self.start = true
    --self.timer = GlobalTools.base1
    --护盾击破
end

--技能结束(仅当前技能调用)
function M:skillEnd(data)
    M.super.skillEnd(self, data)
    --护盾击破
end

---@param data Battle_HandleData_AddBuff
function M:addBuffHandler(eventName, data)
    if self.player:equal(data.buff.player) then
        self.start = true
        self.timer = GlobalTools.base0
        self.player.bufMgr:addBufById(self.angerBuff, self.player)
    end
end

---@param data Battle_HandleData_AddBuff
function M:removeBuffHandler(eventName, data)
    if self.player:equal(data.buff.player) then
        self.start = false
        self.player.bufMgr:removeBufById(self.angerBuff)
        self.count = self.count + 1
        if self.count > self.maxCount then
            self.count = self.maxCount
        end
    end
end

--更新
function M:update(dt,unsdt)
    M.super.update(self, dt)
    if self.start == true then
        self.timer = self.timer - dt
        if self.timer <= GlobalTools.base0 then
            self.timer = GlobalTools.base1
            local anger = self.player.data:get_curAnger() - self.angerCost
            if anger <= GlobalTools.base0 then
                anger = GlobalTools.base0
                self.player.bufMgr:removeBufByTag("W_WDang_skill3")
                self.start = false
            end
            self.player.data:set_anger(anger)
        end
    end
end

--攻击者攻击结束处理
function M:killerAfterAttack(data)
    local dmg = data["damage"]
    local killer = data["killer"]
    local victim = data["victim"]
    local skill = data.attackData.skillConfig

    if killer ~= nil and killer:equal(self.player) and victim ~= nil and skill ~= nil and skill.anim_name == "skill3" then
        local shield = victim.bufMgr:findBufByType("Shield")
        if #shield > GlobalTools.base0 then
            data["damage"] = dmg + GlobalTools:Mul(dmg, self.dmg + GlobalTools:Mul(GlobalTools:ToFix(self.count), self.extraDmg))
        end
    end
end

function M:skillDispatch(data)
    if data.eventName == "skill3_AddBuff" then
        local sceneCenter = SelectTargetTool:findFixPoint(self.player, "sceneCenter")
        local enemyCamp = self.player:get_camp() * -1
        local enemys = SceneManager.curScene.plyMgr:getPlayers(enemyCamp)
        local hasPlayer = false
        for i = 1, enemys.Count do
            local enemy = enemys:get(i - 1)
            if (enemyCamp == -1 and enemy:get_position().x > sceneCenter.x) or (enemyCamp == 1 and enemy:get_position().x < sceneCenter.x) then
                hasPlayer = true
                break
            end
        end
        if hasPlayer == true then
            self.player.bufMgr:addBufById(self.enemyAreaBuff, self.player, self.skill)
        else
            self.player.bufMgr:addBufById(self.friendAreaBuff, self.player, self.skill)
        end

        if self.player.skyStar ~= nil then
            self.player.skyStar:triggerStart()
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_WDang_skill3", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_WDang_skill3", {self,self.removeBuffHandler})
    M.super.destroy(self)
end
return M