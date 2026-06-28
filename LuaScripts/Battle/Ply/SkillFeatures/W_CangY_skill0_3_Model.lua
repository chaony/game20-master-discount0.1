--自己身边的友军会获得该技能30%的效果
local W_CangY_skill0_1_Model = require("Battle.Ply.SkillFeatures.W_CangY_skill0_1_Model")

---@class W_CangY_skill0_3_Model : W_CangY_skill0_1_Model @
---@field super W_CangY_skill0_1_Model @W_CangY_skill0_1_Model
local M = class("W_CangY_skill0_3_Model", W_CangY_skill0_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)
    self.friendRadius = self:getParam(5)
    self.friendRate = self:getParam(6)
    self.friendList = {}
end

function M:checkArea()
    M.super.checkArea(self)

    local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
    for i = 1, friends.Count do
        local friend = friends:get(i - 1)
        if friend:equal(self.player) == false and GlobalTools:Distance(friend.position, self.player.position) <= GlobalTools:ToFix2(self.friendRadius) then
            local count_def = GlobalTools:Mul( GlobalTools:ToFix(self.curCount),self.def);
            local def = GlobalTools:Mul( count_def, self.friendRate )
            if self.friendList[friend.playerInstanceId] == nil then
                friend.data.def:addToMulList(def)
                friend.bufMgr:addBufById(self.effectBuff, self.player)
            else
                if self.friendList[friend.playerInstanceId] ~= def then
                    friend.data.def:removeFromMulList(self.friendList[friend.playerInstanceId])
                    friend.data.def:addToMulList(def)
                end
            end
            self.friendList[friend.playerInstanceId] = def
        else
            if self.friendList[friend.playerInstanceId] ~= nil then
                friend.data.def:removeFromMulList(self.friendList[friend.playerInstanceId])
                self.friendList[friend.playerInstanceId] = nil
                friend.bufMgr:removeBufById(self.effectBuff)
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M