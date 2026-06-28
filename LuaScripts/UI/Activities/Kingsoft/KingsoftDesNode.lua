local M = class("KingsoftDesNode",LikeOO.OOUIbase)

M.m_uiName = "Activities/Kingsoft/KingsoftDesNode"

function M:onEnter()
    self:refreshUi()
end

function M:refreshUi()
   self:setObjectVisible("about_node", self.m_model.m_cur_index == 8)
   self:setObjectVisible("text_scroll_node", self.m_model.m_cur_index == 7)
    if self.m_model.m_cur_index == 7 then
        self:setTextByLanKey("des_text", "tid#KingsoftDes_01")
    else
        for i = 1, 4 do
            self:setTextByLanKey("des_text" .. i, "tid#KingsoftDes_0" .. (i + 1))
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M