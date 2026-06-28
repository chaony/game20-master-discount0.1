--密宗    金轮返生
-- 开场时给己方阴系侠客增加密宗自身的20%内伤减免,涅槃后追加30%(不给自己加效果）

local W_MiZ_skill1_1_Model = require("Battle.Ply.SkillFeatures.W_MiZ_skill1_1_Model")

---@class W_MiZ_skill1_2_Model : W_MiZ_skill1_1_Model @
---@field super W_MiZ_skill1_1_Model @W_MiZ_skill1_1_Model
local M = class("W_MiZ_skill1_2_Model", W_MiZ_skill1_1_Model)

function M:init(ply, skill, className)
    M.super.init(self, ply, skill, className)

    self.addBuff3 = self:getParam(3)  -- Buff[] 免伤buff
    self.addBuff4 = self:getParam(4)  -- Buff 涅槃免伤buff              
    self.addBuff5 = self:getParam(5)  -- Buff[] 首次死亡前给队友加buff
    self.addBuff6 = self:getParam(6)  -- Buff[] 密宗涅槃后回战场后免伤buff
end

function M:spawnFinish()
    M.super.spawnFinish(self)
    self:addRace6FriendBuff(self.addBuff3)
end

function M:onRelive()
    M.super.onRelive(self)
    self:addRace6FriendBuff(self.addBuff4, self.addBuff3)
    
    self.player.bufMgr:addBufById(self.addBuff6, self.player, self.skill)   --密宗涅槃后回战场后免伤buff
end

function M:addRace6FriendBuff(buffId, remove)
    ---- 总是给队友加buff，再给自己加buff
    --if remove then
    --    self.player.bufMgr:removeBufById(remove, true)
    --end

    if buffId == 0 then -- 没有配置
        return
    end
    
    ---@type Battle_List
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    if friends.Count > 0 then
        for i = 0, friends.Count-1 do
            ---@type PlayerModel
            local player = friends:get(i)
            if not self.player:equal(player) then   -- 不给自己加
                if player:isLive() and player.plyData.race == Battle.EnumData.BATTLE_RACE.Huo then
                    if remove then
                        player.bufMgr:removeBufById(remove, true)
                    end
                    player.bufMgr:addBufById(buffId, self.player, self.skill)
                end
            end 
        end
    end

    --if self.player:isLive() and self.player.plyData.race == 6 then
    --    self.player.bufMgr:addBufById(buffId, self.player, self.skill)
    --end
end

--密宗离开战场时,会清除全体友方侠客的控制效果并免疫3秒
function M:willNirvana(data)
    M.super.willNirvana(self, data)

    if self.addBuff5 == 0 then
        return
    end
    
    ---@type Battle_List
    local friends = self.player.plyMgr:getPlayers(self.player:get_camp())
    if friends.Count > 0 then
        for i = 0, friends.Count-1 do
            ---@type PlayerModel
            local player = friends:get(i)
            if not self.player:equal(player) then
                if player:isLive() then
                    player.bufMgr:addBufById(self.addBuff5, self.player, self.skill)
                end
            end
        end
    end
end

return M