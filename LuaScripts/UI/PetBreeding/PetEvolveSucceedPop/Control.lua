---@class PetEvolveSucceedControl: OOControlBase
---@field m_model PetEvolveSucceedModel
---@field m_view PetEvolveSucceedView
local M = class("PetEvolveSucceedPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        if self.m_model.m_callback then
            self.m_model.m_callback()
        end
        self:closeView()
    end
end

return M;
