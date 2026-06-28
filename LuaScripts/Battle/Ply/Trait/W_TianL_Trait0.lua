--角色的专属装备
--天龙
--大招持续期间，天龙会获得25%的吸血效果

---@class W_TianL_Trait0 : PlayerTrait @
---@field super PlayerTrait @PlayerTrait
local M = class("W_TianL_Trait0", PlayerTrait)

M.buffId = nil

function M:init()
    M.super.init(self)
    
    self.buffId = self:getValue(1)

    EventDispatcher:registerEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:registerEvent("SkillEnd", {self,self.SkillEndHandler})
end

--技能结束
function M:SkillEndHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]


    if self.player:equal(ply) and config ~= nil then
      if config.anim_name == "skill3" then
         self.player.bufMgr:removeBufById(self.buffId)
      end
        
    end
end

--技能释放
function M:SkillEnterHandler( eventName, data )
    local ply = data["player"]
    local config = data["skillConfig"]


    if self.player:equal(ply) and config ~= nil then
      if config.anim_name == "skill3" then
         self.player.bufMgr:addBufById(self.buffId, self.player)
      end
        
    end
end


function M:destroy()
    M.super.destroy(self)
    EventDispatcher:unRegisterEvent("SkillEnter", {self,self.SkillEnterHandler})
    EventDispatcher:unRegisterEvent("SkillEnd", {self,self.SkillEndHandler})
end


return M