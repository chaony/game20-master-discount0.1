local G_JinQ_skill2_1_Model = require("Battle.Ply.SkillFeatures.G_JinQ_skill2_1_Model")
---@class G_JinQ_skill2_2_Model : G_JinQ_skill2_1_Model @
---@field super G_JinQ_skill2_1_Model @G_JinQ_skill2_1_Model
local M = class("G_JinQ_skill2_2_Model", G_JinQ_skill2_1_Model)


function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
    self.buf3 = self:getParam(4)
end

function M:changeBuf( )
    self.player.bufMgr:addBufById(self.buf3, self.player)
end

function M:destroy()
    EventDispatcher:unRegisterEvent("add_debuff", {self,self.addBuffHandler})
    M.super.destroy(self)
end
return M