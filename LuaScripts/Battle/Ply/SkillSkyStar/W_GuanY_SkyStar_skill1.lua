--己方侠客每次释放绝技都会提高关羽10%的攻击力，最多叠加5次

---@class W_GuanY_SkyStar_skill1 : SkillSkyStar
---@field super SkillSkyStar
local M = class("W_GuanY_SkyStar_skill1",SkillSkyStar)

function M:init(player, param, level)
    M.super.init(self, player, param, level)
    --加攻击的buff
    self.addAttackBuf = self:getParam(1)
end

function M:gameStart()
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]
    if  config ~= nil and ply.camp  == self.player.camp then
        if config.anim_name == "skill3" then
            self.player.bufMgr:addBufById(self.addAttackBuf, self.player)
        end
    end
end
function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self, self.SkillEnterHandler})
end
return M;