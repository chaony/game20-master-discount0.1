local M = class("ReportBtnPopView", LikeOO.OOPopBase)

M.m_uiName = "Pops/ReportBtnPop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("report_btn_text", "report_str_0006")

    if self.m_model.m_obj then
        local pos = self.m_model.m_obj.transform.position
        local node = self:findGameObject("node")
        local rectTrans = self.m_model.m_obj:GetComponent("RectTransform")
        local rect = rectTrans.rect
        node.transform.position = pos
        local localPos = node.transform.localPosition 
        localPos.x = localPos.x + (0.5 - rectTrans.pivot.x)*rect.width
        localPos.y = localPos.y + (0.5 - rectTrans.pivot.y)*rect.height
        localPos.y = localPos.y + rect.height*0.5 + 18
        node.transform.localPosition = localPos
    end
end

return M
