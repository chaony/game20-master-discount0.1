--战斗开始6秒内，周瑜免受一切控制，要是小乔在队伍中，效果结束后，周瑜还会获得6秒的60坚韧加成

---@class W_ZhouY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_ZhouY_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --免受控制 tag  W_ZhouY_SkyStar_Skill1
    self.buffId = self:getParam(1)
    --坚韧
    self.extraBuffId = self:getParam(2)
    self.hasXiaoQ = false
    EventDispatcher:registerEvent("remove_W_ZhouY_SkyStar_Skill1", {self,self.removeBuffHandler})
end

function M:gameStart()
    M.super:gameStart()
    self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    friends:safeWalkInverted(function(ply)
        if ply ~= nil and ply:isLive() and ply.playerId == Battle.EnumData.BATTLE_SPECIAL_HERO_ID.XiaoQ then
            self.hasXiaoQ = true
        end
    end)
end

function M:removeBuffHandler(eventName, data)
    local buff = data["buff"]
    if self.hasXiaoQ and buff ~= nil and self.player:equal(buff.source) then
        local player = buff.player
        if player and player.bufMgr then
            player.bufMgr:addBufById(self.extraBuffId, self.player, self.skill)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_ZhouY_SkyStar_Skill1", {self,self.removeBuffHandler})
    M.super.destroy(self)
end
return M;