local M = class("QiMenDunJiaMapView",LikeOO.OOPopBase)

M.m_uiName = "QiMenDunJia/QiMenDunJiaMap"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self.m_content_node = self:findGameObject("content_node")


    self.new_stage = ResourceUtil:GetUIItem("QiMenDunJia/QiMenDunJiaMapCell", self.m_content_node, "ui_prefabs")
    UIUtil.setLocalPosition(self.new_stage.transform, 10, 10, 0)
    
end

function M:refreshUI()
 
end


return M