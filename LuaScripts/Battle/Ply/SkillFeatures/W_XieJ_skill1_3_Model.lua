-- lv3 我方首个侠客被击败时，邪极还会获得其攻击、防御属性值的15%，一直持续到战斗结束

local W_XieJ_skill1_2_Model = require("Battle.Ply.SkillFeatures.W_XieJ_skill1_2_Model")
---@class W_XieJ_skill1_3_Model : W_XieJ_skill1_2_Model @
---@field super W_XieJ_skill1_2_Model @W_XieJ_skill1_2_Model
local M = class("W_XieJ_skill1_3_Model", W_XieJ_skill1_2_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)

    self.isTriggerFirst = false    -- 是否已经触发过【我方首次阴阵营死亡】
end

---@param player PlayerModel
function M:onPlayerDead(player)
    if not self.isTriggerFirst then
        if player.master == nil and player.camp == self.player.camp then
            self.isTriggerFirst = true
            self:onFirstFriendDead(player)
        end
    end
    M.super.onPlayerDead(self, player)
end

---@param player PlayerModel
function M:onFirstFriendDead(player)
    self.player.bufMgr:addBufById(self.addBuff6, player, self.skill)    -- 获取目标属性，由目标给自己加buff
end

return M