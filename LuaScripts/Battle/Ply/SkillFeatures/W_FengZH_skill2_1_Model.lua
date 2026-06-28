--該技能只有在處於“風之痕”狀態時才可以使用；風之痕會在敵人身後召喚一個“狂風分身”，
--狂風分身會擁有風之痕70%的屬性值，但只普通攻擊，狂風分身會持續嘲諷周圍的敵人。
--當狂風分身死亡時會引發爆炸，對周圍的敵人造成200%攻擊力的傷害，同一時間只能存在一個狂風分身，
--釋放時若場上已經存在狂風分身，則釋放該技能會為該分身恢復滿血量，並使其屬性值提升10%
--LV3 分身死亡時，還會為風之痕恢復20%最大生命值的血量
---@class W_FengZH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_FengZH_skill2_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.attrRate = self:getParam(1) -- 继承属性百分比
    self.chaofengBuff = self:getParam(2) -- 嘲讽buff
    self.noSKillBuff = self:getParam(3) -- noSKillBuff
    self.caizhiBuff = self:getParam(4) -- 修改召唤物材质
    self.addAttrRate = self:getParam(5) --属性提升10%
    self.cureHpBuff = self:getParam(6) --恢复最大血量
    self.maxAddAtrRate = self:getParam(7) --属性提升上限
    self.final_add = self.attrRate
    --EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end

function M:spawn()
    M.super.spawn(self)
    local skill3Item = self.player.plySkill:getSkillByName("skill3")
    if skill3Item ~= nil then
        self.skill3 = skill3Item.cur_skill_config.feature
    end
    if self.player.summonList.Count > 0 then
        --删除宠物列表 
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                self.player.plyMgr:destoryPlayer(v)
            end
        end
        self.player.summonList:clear();
    end
    -- 宠物配置
    local frame = self.player.evtMgr:getCommonEvent("Sendfor", 1)
    self.summonData = table.copy(frame.data)
end

-- 检查召唤物个数
function M:checkAndDestroySummon()
    if self.player.summonList.Count > 0 then
        --删除宠物列表 
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                v:realDead()
                return true;
            end
        end
        
    end
end


function M:canUse()
    return self.player.master == nil and self.skill3 and self.skill3.skill3_stage == 1
end

--技能开始
function M:skillEnd(data)
    M.super.skillEnd(self, data)
    if self:checkAndDestroySummon() and self.summon ~= nil then
        self.player.bufMgr:addBufById(self.cureHpBuff, self.player, self.skill) -- 给自己加回血buffd
        self.final_add = self.final_add + self.addAttrRate
        if self.maxAddAtrRate > 0 then
            self.final_add = math.min(self.final_add, self.maxAddAtrRate)
        else
            self.final_add = self.attrRate + self.addAttrRate
        end
    end
    local SendForFuncframe = require("Battle.Ply.Fuc.SendForFunc").new()
    SendForFuncframe:init(self.summonData, self.player)
    self.summon = SendForFuncframe.player
    if self.summon ~= nil then
        self.summon.data:set_level( self.player.data:get_level() )
        self.summon.data:set_evo( self.player.data:get_evo() )
        self.summon.plySkill:refreshSkill(nil)
        self.summon.bufMgr:addBufById(self.noSKillBuff, self.player, self.skill)
        self.summon.bufMgr:addBufById(self.caizhiBuff, self.player, self.skill)
        self.summon.data.hp:setInitialValue(self.summon.data:getCopyData(self.player.data.hp, true, self.final_add ))
        self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(self.player.data.atk, true, self.final_add ))
        self.summon.data.def:setInitialValue(self.summon.data:getCopyData(self.player.data.def, true, self.final_add ))
        self.summon.data:set_curHp(self.summon.data:get_hp())
        --self.summon:setPos(self.player.position + self.player:getForward() * GlobalTools.base2);
        --self.summon.aiEngine:changeState("idle")
        self.summon:ShowHpBar(true)
        --self:setForward(self.summon)
    end
    
end

--设置召唤物方向
function M:setForward(present_Target)
    local final_dir = self.player.position - present_Target.position
    final_dir = final_dir * -GlobalTools.base1
    present_Target:setForward( final_dir )
end

function M:destroy()
    --EventDispatcher:unRegisterEvent("SendForFinish", {self,self.sendForHandler})
    M.super.destroy(self)
end

return M