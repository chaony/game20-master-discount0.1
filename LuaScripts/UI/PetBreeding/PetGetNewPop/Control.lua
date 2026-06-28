---@class PetGetNewPopControl: OOControlBase
---@field m_model PetGetNewPopModel
---@field m_view PetGetNewPopView
local M = class("PetGetNewPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        local callback = self.m_model.m_callback
        self:closeView()
        if type(callback) == "function" then
    		callback()
    	end
    end
end

return M;
