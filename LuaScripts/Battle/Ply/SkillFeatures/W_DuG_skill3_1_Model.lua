--独孤在敌人另一侧位置召唤一个影分身，影分身会拥有独孤70%的属性，且会持续嘲讽当前目标，当分身死亡时，会产生爆炸并对周围造成200%攻击力的伤害，释放该技能时，
--若场上已经存在了一个影分身，则会使该影分身立刻爆炸，并在原地召唤新的分身
---@class W_DuG_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DuG_skill3_1_Model", SkillFeatures_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.attrRate = self:getParam(1) -- 继承属性百分比
    self.chaofengBuff = self:getParam(2) -- 嘲讽buff
    self.noSKillBuff = self:getParam(3) -- noSKillBuff
    self.caizhiBuff = self:getParam(4) -- 修改召唤物材质
    --EventDispatcher:registerEvent("SendForFinish", {self,self.sendForHandler})
end


function M:spawn()
    M.super.spawn(self)
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

-- 检查独孤召唤物个数
function M:checkAndDestroySummon()
    if self.player.summonList.Count > 0 then
        --删除宠物列表 
        for i = 1, self.player.summonList.list.Count do
            local key = self.player.summonList.list:get(i-1)
            local plys = self.player.summonList:get(key)
            for i, v in ipairs(plys) do
                v:realDead()
                --v:destroy()
                return true;
            end
        end
    end
end

--技能开始
function M:skillStart(data)
    M.super.skillStart(self, data)
    if self:checkAndDestroySummon() then
        self.player.bufMgr:addBufById(self.buffData, self.player, self.skill) -- 给自己加回血buffd
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
        self.summon.data.hp:setInitialValue(self.summon.data:getCopyData(self.player.data.hp, true, self.attrRate))
        self.summon.data.atk:setInitialValue(self.summon.data:getCopyData(self.player.data.atk, true, self.attrRate))
        self.summon.data.def:setInitialValue(self.summon.data:getCopyData(self.player.data.def, true, self.attrRate))
        self.summon.data:set_curHp(self.summon.data:get_hp())
        self.summon:setPos(self.player.position + self.player:getForward() * GlobalTools.base2);
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