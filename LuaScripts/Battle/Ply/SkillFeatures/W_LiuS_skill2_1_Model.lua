--六扇连续向前射出三箭，攻击同一个目标，每支箭会造成100%攻击力的
--外功伤害，若攻击的目标已经被施加了“悬赏”标记，则该技能必定暴击。

--六扇改 【六扇每释放过一次悬赏标记】 
--等级1:【六扇每释放过一次悬赏标记】，六扇的【攻击力】就提升【10%】
--等级2:【六扇每释放过一次悬赏标记】，六扇的攻速还会提升40点
--等级3:【六扇每释放过一次悬赏标记】，六扇的暴击伤害还会提升【20%】
--等级4:【六扇每释放过一次悬赏标记】，六扇的暴击伤害还会提升【40%】

--六扇改2 【六扇每释放过一次悬赏标记】
--等级1:【六扇每释放过一次悬赏标记】，六扇首次释放"悬赏令"时，六扇获得30%的攻击力提升，之后每额外释放一次悬赏标记，获得的攻击提升效果便额外提升5%
--等级2:【六扇每释放过一次悬赏标记】，六扇首次释放"悬赏令"时，六扇还会额外获得20点攻速提升，之后每额外释放一次悬赏，攻速便额外提升5点
--等级3:【六扇每释放过一次悬赏标记】，六扇首次释放"悬赏令"时，六扇还会额外获得10%暴击伤害，之后每额外释放一次悬赏，暴击伤害便额外提升2%
--等级4:【六扇每释放过一次悬赏标记】，六扇首次释放"悬赏令"时，六扇还会额外获得20%暴击伤害，之后每额外释放一次悬赏，暴击伤害便额外提升4%

---@class W_LiuS_skill2_1_Model : SkillFeatures_Model
local M = class("W_LiuS_skill2_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.first_atk_buff = self:getParam(1) --首次提升攻击
    self.first_speed_buff = self:getParam(2) --首次提升攻速
    self.first_crit_buff = self:getParam(3) --首次提升爆伤

    self.atk_buff = self:getParam(4) --每次提升buff（第一次会使用首次）
    self.speed_buff = self:getParam(5) --每次提升buff（第一次会使用首次）
    self.crit_buff = self:getParam(6) --每次提升buff（第一次会使用首次）
    self.victimList = {}

    self.useSkill1Cnt = 0;
    
    EventDispatcher:registerEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
    EventDispatcher:registerEvent("remove_W_LiuS_skill1", {self,self.removeBuffHandler})
end

function M:spawn()
    M.super.spawn(self)
end

----攻击者的攻击开始处理
--function M:killerBeforeAttack(attackData, victim)
--    if victim ~= nil then
--        local skillConfig = attackData.skillConfig
--        if skillConfig == self.skill then
--            local buffs = victim.bufMgr:findBufByTag("W_LiuS_skill1")
--            if #buffs > 0 then
--                attackData["mustCrit"] = true
--            end
--        end
--    end
--end

function M:addBuffHandler(eventName, data)
    local buff = data.buff
    if buff ~= nil and self.player:equal(buff.source) then
        --if self.victimList[buff.player.playerInstanceId] == nil then
        --    self.victimList[buff.player.playerInstanceId] = 0
        self.useSkill1Cnt = self.useSkill1Cnt + 1
        if (self.useSkill1Cnt == 1) then
            self.player.bufMgr:addBufById(self.first_atk_buff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.first_speed_buff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.first_crit_buff, self.player, self.skill)
        else
            self.player.bufMgr:addBufById(self.atk_buff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.speed_buff, self.player, self.skill)
            self.player.bufMgr:addBufById(self.crit_buff, self.player, self.skill)
        end
        --end
        --self.victimList[buff.player.playerInstanceId] = self.victimList[buff.player.playerInstanceId] + 1
    end
end

function M:removeBuffHandler(eventName, data)
    local buff = data.buff
    if buff ~= nil and self.player:equal(buff.source) then
        --if self.victimList[buff.player.playerInstanceId] ~= nil then
        --    self.victimList[buff.player.playerInstanceId] = self.victimList[buff.player.playerInstanceId] - 1
        --    if self.victimList[buff.player.playerInstanceId] <= 0 then
        --        self.player.bufMgr:removeBufById(self.critrate_buff, false, true)
        --        self.player.bufMgr:removeBufById(self.speed_buff, false, true)
        --        self.player.bufMgr:removeBufById(self.crit_buff, false, true)
            --end
        --end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_W_LiuS_skill1", {self,self.addBuffHandler})
    EventDispatcher:unRegisterEvent("remove_W_LiuS_skill1", {self,self.removeBuffHandler})
    M.super.destroy(self)
end

return M