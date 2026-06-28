--被动的，九天每损失相当于自身生命值10%的血量，便会为一名最虚弱(生命百分比最少)的友军(除自己)施加恢复效果，恢复量相当于九天攻击力的200%
---@class W_JiuT_skill3_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_JiuT_skill3_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.lostRate = self:getParam(1) -- 每累积损失多少加一层
    self.hpRecoverRate = self:getParam(2) -- 治疗百分比
    self.addNum = 0 -- 加了多少层buff
    self.oldTotalLostHp = 0  -- 按比例累计损失血量
    self.lost_hp_num = 0
    self.hp_max = 0
end

function M:spawnFinish()
    self.hp_max = self.player.data:get_hp() -- 获取血量上限
    self.lost_hp_num = GlobalTools:Mul(self.hp_max, self.lostRate) -- 每层每次损失的血量
end

function M:update(dt,unsdt)
    M.super.update(self, dt, unsdt)
    if self.lost_hp_num and self.lost_hp_num ~= 0 then
        local hp_max = self.hp_max -- 获取血量上限
        local lastTotalLostHp = self.player.totalLostHp or 0 -- 累计损失血量
        local lostRate = GlobalTools:Div((lastTotalLostHp - self.oldTotalLostHp),hp_max) -- (累计损失血量 - 上次累计损失血量 ) / 血量上限 = 当前损失血量的比例
        local curAddBuffNum = GlobalTools:Div(lostRate, self.lostRate) -- (当前损失血量的比例 / 每累积损失多少加一层) = 要加多少层
        local num = math.floor(GlobalTools:ToFloat(curAddBuffNum)) -- 定点数转浮点数
        if num > 0 then
            self.oldTotalLostHp = self.oldTotalLostHp + GlobalTools:Mul(self.lost_hp_num, GlobalTools:ToFix(num))
            local weakFriend = nil -- 最虚弱的友军
            local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
            local hpRate = GlobalTools:ToFix(100) -- 当前血量比例
            for i = friends.Count, 1, -1 do
                ---@type PlayerModel
                local player = friends:get(i-1)
                if player.master == nil and player:equal(self.player) == false then
                    if player.data:get_hpRate() < hpRate then
                        hpRate = player.data:get_hpRate()
                        weakFriend = player
                    end
                end
            end
            if weakFriend then
                local cure_value = GlobalTools:Mul(self.hpRecoverRate , GlobalTools:ToFix(num))
                weakFriend:cure("atk", self.player, cure_value, self.skill)
                weakFriend = nil
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M