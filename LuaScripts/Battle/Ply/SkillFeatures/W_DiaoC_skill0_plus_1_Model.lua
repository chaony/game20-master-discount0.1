--极·巧连环  场上每有一名侠客阵亡（无论敌我），貂蝉回复100点内力，并获得【连环】效果，每层提高10%攻击力和暴击率。
--其他队友也会获得【连环】效果，在貂蝉死亡后移除该效果。
--貂蝉和己方侠客在每次获得【连环】效果时，恢复30%的最大生命值
--每次获得连环效果时，貂蝉会叠加2层
---@class W_DiaoC_skill0_plus_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_DiaoC_skill0_plus_1_Model", SkillFeatures_Model)

function M:init(ply, skill,className) 
    M.super.init(self, ply, skill,className)
    self.obtainAnger = self:getParam(1)--获得多少内力
    self.atkBuff = self:getParam(2)--连环buff
    self.hpBuff = self:getParam(3)--连环buff
    self.extraTime = self:getParam(4) == 1 --是否貂蝉额外叠加1层

    EventDispatcher:registerEvent("PlayerDead", {self, self.playerDeadHandle})
end
function M:skillStart(data)
    M.super:skillStart(data)
end
---@param eventData Battle_HandleData_PlayerDead
function M:playerDeadHandle(eventName, eventData)
    if (not self.player:equal(eventData.data)) then  -- 非是自己死亡
        self.player.data:addAnger( self.obtainAnger, true )
        self.player.bufMgr:addBufById(self.atkBuff,self.player,self.skill)
        if self.hpBuff > 0 then
            self.player.bufMgr:addBufById(self.hpBuff, self.player,self.skill)
        end
        if self.extraTime then
            self.player.bufMgr:addBufById(self.atkBuff, self.player,self.skill)
            if self.hpBuff > 0 then
                self.player.bufMgr:addBufById(self.hpBuff, self.player,self.skill)
            end
        end
        if self.skill.level > 1 then
            local friends = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friendExceptSelf",
                                                                              ignoreSummon = true,
                                                                              count = "all",
            })
            for i = 1, friends.Count do
                local friend = friends:get(i - 1)
                if friend and friend.bufMgr then
                    friend.bufMgr:addBufById(self.atkBuff, self.player,self.skill)
                    if self.hpBuff > 0 then
                        friend.bufMgr:addBufById(self.hpBuff, self.player,self.skill)
                    end
                end
            end
        end
    else
        local friends = SelectTargetUtil:findPlayerByParam(self.player, { camp = "friendExceptSelf",
                                                                          ignoreSummon = true,
                                                                          count = "all",
        })
        for i = 1, friends.Count do
            local friend = friends:get(i - 1)
            if friend and friend.bufMgr then
                friend.bufMgr:removeBufById(self.atkBuff, true,false)
            end
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent("PlayerDead", {self, self.playerDeadHandle})
    M.super.destroy(self)
end


return M