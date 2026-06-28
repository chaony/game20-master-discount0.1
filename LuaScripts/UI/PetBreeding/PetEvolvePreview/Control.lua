---@class PetEvolvePreviewControl: OOControlBase
---@field m_model PetEvolvePreviewModel
---@field m_view PetEvolvePreviewView
local M = class("PetEvolvePreviewControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:updateMsg("refresh_lock_skill", self.m_model.m_lock_skill, "PetBreeding.PetEvolvePop")
        self:closeView()
    elseif msg == "add_lock" then
        if self.m_model:checkLockFull() == true and self.m_model:checkIsLick(data) == false then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("锁定已满 --- "), delay_close = 2})
            return
        end
        if self.m_model:checkIsLick(data) then
            self.m_model:removeLockSkill(data)
        else
            self.m_model:addLockSkill(data)
        end
        self.m_view:refreshUI()
    elseif msg == "remove" then
        self.m_view:refreshUI() 
    end
end

return M;
