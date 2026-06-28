--五毒角色的专属装备

--当场上的敌人数量为1/2/3时，大招的伤害会提升12%/6%/3%

--新：必杀技的伤害提升10%
---@class WuDu13_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("WuDu13_Trait0", PlayerTrait)

-- M.dmg1 = nil
-- M.dmg2 = nil
-- M.dmg3 = nil
M.dmg = nil
M.atk_dmg = 0
function M:init()
    M.super.init(self)
    -- self.dmg1 = self:getValue(1) 
    -- self.dmg2 = self:getValue(2) 
    -- self.dmg3 = self:getValue(3) 
    self.dmg = self:getValue(1) 
end

function M:spawn()
    M.super.spawn(self)

    --五毒大招伤害根据表改
--    self.player.skillImprove:addItem(v)

    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    
end

--作为攻击者的属性临时调整
function M:killerDataChangeTemp(victim)
    M.super.killerDataChangeTemp(self,victim)
    self.player.data.atk:addToMulListTemp(self.atk_dmg)
end


function M:SkillEnterHandler(eventName, data)

    local ply = data["player"]
    local config = data["skillConfig"]
    if ply:equal(self.player) and config ~= nil and "skill3" == config.anim_name then
        -- local list = Battle.List.new()
        -- list = SceneManager.curScene.plyMgr:getPlayers(-self.player:get_camp())
        -- if list.Count == 1 then
        --     self.atk_dmg = self.dmg1
        -- elseif list.Count == 2 then
        --     self.atk_dmg = self.dmg2
        -- elseif list.Count == 3 then
        --     self.atk_dmg = self.dmg3
        -- end
        self.atk_dmg = self.dmg
    end
end


function M:destroy()
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    M.super.destroy(self)
end
 

return M