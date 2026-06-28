--角色的专属装备
--形意
--每次切换拳意的时候，会获得1秒的霸体效果，霸体效果下免疫一切控制效果
---@class W_XingY_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_XingY_Trait0", PlayerTrait)


M.buff = 0
M.herotable = {}
function M:init()
    M.super.init(self)
    self.buff = self:getValue(1)
    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]


    if self.player:equal(ply) and config ~= nil then
      if string.match(config.anim_name, "attack") == nil then
        self.player.bufMgr:addBufById(self.buff,self.player)
        self:rest_func()
      end
        
    end
end

function M:rest_func( ... )
  -- body
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
end
return M