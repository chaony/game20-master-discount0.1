local M = class("GuJianQiTanMazeBlessControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 or msg == "star_close_btn" then
        --self:closeView()
        --祝福使者
    elseif msg == "sure_btn" then
        local params = {}
        params.cell_id = self.m_model.m_cur_cell_id
        params.buff_index = self.m_model.m_cur_index - 1
        self:updateMsg("maze_bless",params, "GuJianQiTan.GuJianQiTanMaze")
        self:closeView()
    elseif msg == "select_buff" then
        if data and data ~= self.m_model.m_cur_index then
            self.m_model.m_cur_index = data
            self.m_view:refreshUI()
        end
    end
end

return M
