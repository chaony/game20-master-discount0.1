---@class PetSkillDetailPopControl: OOControlBase
---@field m_model PetSkillDetailPopModel
---@field m_view PetSkillDetailPopView
local M = class("PetSkillDetailPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "skill_img1" then
        self.m_model:setCurIndex(1)
        self.m_view:refreshUI()
    elseif msg == "skill_img2" then
        self.m_model:setCurIndex(2)
        self.m_view:refreshUI()
    elseif msg == "skill_img3" then
        self.m_model:setCurIndex(3)
        self.m_view:refreshUI()
    elseif msg == "skill_img4" then
        self.m_model:setCurIndex(4)
        self.m_view:refreshUI()
    elseif msg == "skill_img5" then
        self.m_model:setCurIndex(5)
        self.m_view:refreshUI()
    elseif msg == "skill_img6" then
        self.m_model:setCurIndex(6)
        self.m_view:refreshUI()
        
    end
end

return M
