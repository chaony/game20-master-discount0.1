--白玉堂 每次造成伤害都会提高10点暴击效果，最多叠加5次，该效果在退出迷踪状态后重置

---@class W_BaiYT_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_BaiYT_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    
    --暴击buff，策划说在buff里面控制buff最大上的次数
    self.addCtrlBuf = self:getParam(1)
end
function M:gameStart()
    EventDispatcher:registerEvent("remove_W_BaiYT_skill2", {self, self.removeBuffHandler})
end
function M:attackOver(ply, killer, wantdata)
    if wantdata.damage > 0 then
        --在大招期间的总伤害
        self.player.bufMgr:addBufById(self.addCtrlBuf, self.player)
    end
end

function M:removeBuffHandler( eventName, data )
    local buff = data["buff"]
    if buff ~= nil and self.player:equal(buff.source) then
        self.player.bufMgr:removeBufById(self.addCtrlBuf, true)
    end
end
function M:destroy()
    EventDispatcher:unRegisterEvent("remove_W_BaiYT_skill2", {self, self.removeBuffHandler})
end
return M;