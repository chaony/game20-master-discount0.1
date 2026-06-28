--肥啾在场上时，每15秒给我方随机1名侠客给予【翎佑】印记，印记最多可叠加1层，效果为：免疫下一次控制效果（包含）。免疫控制后，印记爆炸并对小范围的敌方侠客造成2%侠客最大生命值的伤害。
--击败敌方宠物后，效果加强为：免疫控制后，印记爆炸造成的伤害提升至5%。

---@class P_Niao_xiezhanskill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("P_Niao_xiezhanskill1_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.killFlag = false -- 是否击杀敌方宠物
    EventDispatcher:registerEvent("PlayerDead", {self,self.PlayerDeadHandler})
end

function M:skillStart(data)
    M.super.skillStart(self, data)
    if self.killFlag then
        self.skill.extra_anim_name = "xiezhanskill1_2"
    else
        self.skill.extra_anim_name = "xiezhanskill1"
    end
end

function M:findPlayer(data)
    if self.skill == self.player.curSkillConfig then
        local maxCnt = data.Count
        local friends = SelectTargetUtil:findXieKeFriends(self.player)
        friends = BattleTool:findNoBuffPlayers(friends, "P_Niao_xiezhanskill1", true)
        local newList = Battle.List.new()
        ---@type PlayerModel
        local friend = nil
        for i = 1, maxCnt do
            local randomIndex = WRandom:randomNum(1, friends.Count, true)
            friend = friends:get(randomIndex-1)
            if friend and friend:isLive() then
                newList:add(friend)
            end
        end
        return newList
    end
    return data
end

---@param eventData Battle_HandleData_PlayerDead
function M:PlayerDeadHandler(eventName, eventData)
    if eventData.data.playerType == "pet" and BattleTool:killerIsMe(self.player, eventData.data) then
        self.killFlag = true
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self,self.PlayerDeadHandler})
    M.super.destroy(self)
end

return M