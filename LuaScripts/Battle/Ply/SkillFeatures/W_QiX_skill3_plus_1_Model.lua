--等级1：花间派鼓舞所有己方侠客，使全队伤害提升35%，受到伤害降低35%，内力恢复速度提高35%，持续8秒
--等级2:与花间同一阵营的侠客，会额外获得25%的效果提升
--等级3:与花间费同一阵营的侠客，也将获得额外获得15%的效果提升
--等级4:花间如果阵亡，全队将立即获得该效果直到战斗结束
---@class W_QiX_skill3_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_QiX_skill3_plus_1_Model", SkillFeatures_Model)



function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.campbuffId = self:getParam(1)
    self.uncampbuffId = self:getParam(2)


    EventDispatcher:registerEvent("add_W_QiX_Skill3_Plus", {self,self.addBuffHandler})
    if self.skill.level >= 4  then
        EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
    end
end

---@param data Battle_HandleData_AddBuff
function M:addBufHandler(eventName, data)
    if data.buff and data.buff.player and data.buff.player.camp == self.player.camp and data.buff.player:isLive() then
        if data.buff.player.plyData.race == self.player.plyData.race then
            data.buff.player.bufMgr:addBufById(self.campbuffId,self.player,self.skill)
        else
            data.buff.player.bufMgr:addBufById(self.uncampbuffId,self.player,self.skill)
        end
    end
end

--死亡回调
function M:PlayerDeadHandler( eventName, data )
    local player = data["data"]
    if player ~= nil and player:equal(self.player)  then
        local friends = SceneManager.curScene.plyMgr:getPlayers(self.player:get_camp())
        if friends.Count > 0 then
            for i = 0, friends.Count-1 do
                ---@type PlayerModel
                local player = friends:get(i)
                if not self.player:equal(player) then
                    if player:isLive() then
                        if player.plyData.race == self.player.plyData.race then
                            player.bufMgr:addBufById(self.campbuffId,self.player,self.skill)
                        else
                            player.bufMgr:addBufById(self.uncampbuffId,self.player,self.skill)
                        end
                    end
                end
            end
        end
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("add_W_QiX_Skill3_Plus", {self, self.addBuffHandler})
    if self.skill.level >= 4  then
        EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    end
end

return M