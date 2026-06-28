local M = class("HighArenaTeamPopControl",LikeOO.OOControlBase)

function M:onEnter()
   
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then
        self:closeView()
    elseif msg == "order_btn" then -- 调整顺序
        self.m_model.m_edit_status = 2
        self.m_view:refreshUI()
    elseif msg == "ok_btn" then -- 保存
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self:updateMsg("high_arena_exchange_team", {mult_main_teams = self.m_model.m_mult_main_teams,mult_solts = self.m_model.m_mult_solts}, "Formation")
        self.m_view:refreshUI()
    elseif msg == "cancle_btn" then -- 取消
        self.m_model.m_edit_status = 1
        self.m_model.m_select_cell_index = -1
        self.m_model:initData()
        self.m_view:refreshUI()
    elseif msg == "exchange_btn" then
        if self.m_model.m_edit_status == 2 then --选择要调整的队伍
            self.m_model.m_edit_status = 3
            self.m_model.m_select_cell_index = data.index
            self.m_view:refreshUI()
        elseif self.m_model.m_edit_status == 3 then -- 交换
            self.m_model:exchangeTeam(self.m_model.m_select_cell_index, data.index)
            self.m_model.m_edit_status = 2
            self.m_model.m_select_cell_index = -1
            self.m_view:refreshUI()
        end
    elseif msg == "refresh_ui" then
        self.m_model:initData()
        self.m_view:refreshUI()
   end
end


function M:destroy()
    M.super.destroy(self)
end

return M;
