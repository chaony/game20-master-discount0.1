--战斗开始时，随机连接自己与一名女性友军，合欢的属性会提升该友军攻击、
--防御、血量属性的30%，该效果会一直持续到战斗结束
---@class W_HeH_skill2_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_HeH_skill2_1_Model", SkillFeatures_Model)
M.lineData = require("Battle.Ply.SkillFeaturesData.W_HeH_skill2_1_Data")

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    --自身提升比例, 友军的属性添加到自己身上
    self.rate = self:getParam(1)
    --队友提升比例， 自己的属性添加到友军身上
    self.friendRate = self:getParam(2)
end

function M:spawn()
    M.super.spawn(self)
    self:createLine()
    if self.friend ~= nil then
        self:addData(self.player, self.rate, self.friend)
        self:addData(self.friend, self.friendRate, self.player)
    end
end

function M:addData(player, rate, targetPlayer)
    if rate > 0 then
        local targetInitAtk = targetPlayer.data.atk:getInitialValue()
        local targetInitHp = targetPlayer.data.hp:getInitialValue()
        local hpRate = player.data:get_hpRate()
        player.data.atk:addToAddList(GlobalTools:Mul(rate, targetInitAtk))
        player.data.hp:addToAddList(GlobalTools:Mul(rate, targetInitHp))
        local hp_value = GlobalTools:Mul(player.data:get_hp(), hpRate)
        player.data:set_curHp( hp_value )
    end
end

--连线
function M:createLine()
    --加载预制
    self.line = require("Battle.Line.Line_Model").new()
    self.line:init(self.lineData, self.player, self.player)
    --将连线加入到管理器
    self.player.lineMgr:addLine(self.line)
    self.friend = self.line.target
end

function M:destroy()
    M.super.destroy(self)
end

return M