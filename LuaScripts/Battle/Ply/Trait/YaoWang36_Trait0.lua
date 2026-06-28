--药王角色的专属装备

--普通攻击时会治疗最虚弱的友军，使其恢复自己攻击力60%的生命值

--新：药王造成和受到的所有治疗效果提升10%
---@class YaoWang36_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("YaoWang36_Trait0", PlayerTrait)

--生命回复效果
M.hpRecover = nil
M.cureRate = nil --治疗效果

function M:init()
    M.super.init(self)
    --self.hpRecover = self:getValue(1) 
    --self.cureRate = self:getValue(2) 
    self.buff = self:getValue(1)
end
function M:spawn()
    M.super.spawn(self)
    self.player.bufMgr:addBufById(self.buff, self.player)

end

-- function M:spawn()
--     M.super.spawn(self)
--     self.data =
--     {
--         ["count"] = "one",
--         ["camp"] = "friend",
--         ["campRace"] = "not",
--         ["pos"] = "bloodLeast",
--         ["profession"] = "all",
--         ["area"] = "all",
--         ["areaWidth"] = "",
--         ["areaHeight"] = "",
--         ["areaAngle"] = "",
--         ["areaRadius"] = "",
--         ["forceSelect"] = false,
--         ["selectLast"] = false
--     }
--     EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    
-- end


-- function M:SkillEnterHandler(eventName, data)

--     local ply = data["player"]
--     local config = data["skillConfig"]
--     if ply:equal(self.player) and config ~= nil and "attack1" == config.anim_name then

--         local enemys = SelectTargetTool:findPlayerByType(self.data,self.player)

--         self.player:cure("fix", enemys:get(0), self.player.data.atk:getValue() * self.hp)
--     end
-- end


function M:destroy()
    --EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end
 

return M