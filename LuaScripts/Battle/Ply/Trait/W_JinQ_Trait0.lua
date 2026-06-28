--金钱帮角色的专属装备

--使用技能回旋战斧时接住飞斧的几率提升至75%，此外，每当接住飞斧后便会立即再使用一次回旋斧，并使下一次接住飞斧的几率下降25%，直至没接住为止

--新：战斗中金钱会获得305的攻速加成
---@class W_JinQ_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_JinQ_Trait0", PlayerTrait)

M.atk_speed = nil

function M:init()
    M.super.init(self)
   -- self.rate = self:getValue(1)
    self.buff = self:getValue(1)
end

function M:spawn()
     M.super.spawn(self)
    self.player.bufMgr:addBufById(self.buff, self.player)

    -- self.skill2 = self.player.plySkill:getSkillByName("skill2")
    -- if self.skill2 ~= nil then
    --     self.skill2.cur_skill_config.feature.rate = self.rate
    -- end
    
    --EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end


-- function M:SkillEndHandler(eventName, data)

--     local ply = data["player"]

--     if ply:equal(self.player) and self.skill2 ~= nil and self.skill2.cur_skill_config.feature.succeed then
        
--         self.player:set_curSkillConfig(self.skill2.cur_skill_config)
--         self.player.curSkillConfig.extra_anim_name = "skill2"
--         self.skill2.cur_skill_config.feature.rate = self.skill2.cur_skill_config.feature.rate - 25
--     end
-- end


-- function M:update(dt)
--     M.super.update(self,dt)
    
-- end

function M:destroy()
    M.super.destroy(self)
    --EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end

return M