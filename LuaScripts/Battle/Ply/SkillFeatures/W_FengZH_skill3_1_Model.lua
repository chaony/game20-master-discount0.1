--風過·留痕：風之痕向敵人釋放一道劍氣，劍氣會在敵人和己方俠客之間隨機彈射，當劍氣命中敵人時，會對其造成300%攻擊力的傷害，
--當劍氣命中友軍時，會為其恢復200%攻擊力的血量和持續5秒的加速效果，釋放完該技能後，風之痕會切換為“魔流劍”形態，同時絕技變為“劍·魔流”
--劍·魔流：魔流劍迅速衝至敵人身後，隨後在敵人身前召喚一個“魔流分身”，分身會和魔流劍一起攻擊敵人，造成500%攻擊力的傷害和持續3秒的眩暈效果，（藏剑）
--釋放完該技能後，魔流劍會切換為“風之痕”形態，同時絕技變為“風過留痕”
--每次释放“风过留痕”后，风之痕会免疫控制效果3秒（霹雳效果：每额外上阵一位霹雳侠客，免疫控制的持续时间便会提升1秒）
--每次释放“劍·魔流”后，魔流剑会获得一个护盾，为其抵挡500%攻击力的伤害，持续8秒（霹雳效果：没额外上阵一位霹雳侠客，获得的护盾值便提升10%）

---@class W_FengZH_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FengZH_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.addBuff0 = self:getParam(1)       -- Buff[]  命中敌方buff
    self.addBuff1 = self:getParam(2)       -- Buff[]  命中己方buff
    self.addBuff2 = self:getParam(3)       -- Buff[] 免疫控制效果3秒
    self.addBuff3 = self:getParam(4)       -- Buff[]  魔流剑会获得一个护盾
    self.piliBuff1 = self:getParam(5)       -- Fix[1-10]  霹雳效果：每额外上阵一位霹雳侠客，免疫控制的持续时间便会提升1秒
    self.addShieldValue = self:getParam(6)       -- Fix[]  霹雳效果：没额外上阵一位霹雳侠客，获得的护盾值便提升10%
    self.skill3_stage = 1 --1“風之痕”形態 2 “魔流劍”形態
    self.friendCount = 0
    EventDispatcher:registerEvent("SkillEnd", {self,self.skillEndHandler})
    EventDispatcher:registerEvent("ShieldValue", {self,self.ShieldHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill0Item = self.player.plySkill:getSkillByName("skill0")
    if skill0Item ~= nil then
        self.skill0 = skill0Item.cur_skill_config.feature
    end
end

function M:spawnFinish()
    if self.player.master == nil and self.skill0 then
        if self.skill3_stage == 1 then
            self.player.bufMgr:addBufById(self.skill0.addBuff1, self.player, self.skill0)
        elseif self.skill3_stage == 2 then
            self.player.bufMgr:addBufById(self.skill0.addBuff2, self.player, self.skill0)
        end
    end
    M.super.spawnFinish(self)
end

function M:changeState()
    if self.skill3_stage == 1 then
        self.skill3_stage = 2
    else
        self.skill3_stage = 1
    end
    if self.skill0 ~= nil then
        self.skill0:changeState(self.skill3_stage)
    end
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.skill3_stage == 2 then
        self.skill.extra_anim_name = "skill3"
    elseif self.skill3_stage == 1 then
        if self.player.skyStar then
            self.skill.extra_anim_name = "skill3_2"
        else
            self.skill.extra_anim_name = "skill3_"..self.skill3_stage
        end
    end
    local friends = SelectTargetUtil:findPlayerByParam(self.player, {camp = "friend", ignoreSummon = true})
    local piliCnt = 0;
    for i = friends.Count, 1, -1 do
        local friend = friends:get(i-1)
        if friend and friend ~= self.player and table.indexof(Battle.EnumData.BATTLE_PLBDX_HERO_ID, tonumber(friend.plyData.id)) then
            piliCnt = piliCnt + 1
        end
    end
end

function M:killerAfterAttack(data)
    if data.attackData.skillConfig == self.skill and data.attackData.injureType == "skill" and data.victim then
        self:onHitPlayer(data.victim)

        -- 命中队友和敌方的音效不同
        if data.victim.camp == self.player.camp then
            --data.attackData.hitAudio = "skill3_heal"
        else
           -- data.attackData.hitAudio = "skill3_hit"
        end
    end
end

---@param target PlayerModel
function M:onHitPlayer(target)
    if self.player:get_camp() == target:get_camp() then -- 队友
        target.bufMgr:addBufById(self.addBuff1, self.player, self.skill)
    else
        target.bufMgr:addBufById(self.addBuff0, self.player, self.skill)
    end
end

---@param eventData Battle_HandleData_SkillEnd
function M:skillEndHandler(eventName, eventData)
    if self.player:equal(eventData.player) and eventData.skillConfig and eventData.skillConfig.anim_name == "skill3" and self.player.master == nil then
        if self.skill3_stage == 1 and self.addBuff2 > 0 then
            local buff = self.player.bufMgr:addBufById(self.addBuff2, self.player, self.skill)
            if buff then
                buff:addLastTime(GlobalTools:Mul(GlobalTools:ToFix(self.friendCount), self.piliBuff1))
            end
        elseif self.skill3_stage == 2 then
            local buff = self.player.bufMgr:addBufById(self.addBuff3, self.player, self.skill)
        end
        self:changeState()
    end
end

function M:ShieldHandler(eventName, data)
    local ply = data["ply"]
    local buf = data["shieldValue"]
    local isStart = data["isStart"]
    if isStart == true then
        if buf ~= nil then
            if buf.value > 0 then
                if ply:equal(self.player) and self.player.master == nil then
                    local per = GlobalTools:Mul(GlobalTools:ToFix(self.friendCount), self.addShieldValue)
                    buf.value = GlobalTools:Mul( buf.value, (GlobalTools.base1 + per) )
                end
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("ShieldValue", {self,self.ShieldHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.skillEndHandler})
    M.super.destroy(self)
end

return M
