---
--- 御龙诀持续时间增加3秒，当任一敌方侠客被击败，天龙恢复自身15%最大生命值，御龙诀持续期间，天龙额外提升25%的暴击效果
---
local M = class("W_TianL_SkyStar_skill1",SkillSkyStar)


function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --提升25%的暴击效果
    self.addCtrlBuf = self:getParam(1)
    --恢复比例
    self.restoreRate = self:getParam(2)
end

function M:gameStart()
    EventDispatcher:registerEvent("PlayerDead",{self,self.deadHandler} )
    EventDispatcher:registerEvent("remove_W_TianL_skill3", {self, self.removeBuffHandler})
end

--有人死亡时
function M:deadHandler( eventName, data )
    local target = data["data"]
    if target.camp == -1 then
        --增加血量
        self.player:cure("hp", self.player, self.restoreRate)
    end
end


--触发开始
function M:skillStart( ply, skill )
    if skill.anim_name == "skill3" then
        self.player.bufMgr:addBufById(self.addCtrlBuf, self.player)
    end
end

--移除buf的时候再移除暴击buf
function M:removeBuffHandler( eventName, data )
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        self.player.bufMgr:removeBufById(self.addCtrlBuf, true)
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_TianL_skill3", {self, self.removeBuffHandler})
    EventDispatcher:unRegisterEvent("PlayerDead",{self,self.deadHandler} )
end


return M;