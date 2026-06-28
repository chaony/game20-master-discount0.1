local M = class("LingCloudView", LikeOO.OOPopBase)
--凌云阁
M.m_uiName = "LingCloud/LingCloud"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:refreshUI()
    self:setTextByLanKey("close_title_text", "ling_cloud_str_0001")
    self:setTextByLanKey("left_cell_title_1", "new_str_1058")
    self:setTextByLanKey("left_cell_title_2", "new_str_1103")
    self:setTextByLanKey("left_cell_title_3", "new_str_1104")
    self:setTextByLanKey("right_cell_title_1", "new_str_1058")
    self:setTextByLanKey("right_cell_title_2", "new_str_1103")
    self:setTextByLanKey("right_cell_title_3", "new_str_1104")
end

function M:refreshUI()
    self:setTextByLanKey("left_cell_num_2", self.m_model:getHightArenaRankName())
    self:setTextByLanKey("left_cell_num_3", self.m_model:getHightArenaRank())
    self:setTextByLanKey("right_cell_num_3", self.m_model:getTopArenaRank())
    if self.m_model.m_top_arena == nil or self.m_model.m_top_arena.last_time == -1 then
        self:setTextByLanKey("right_cell_num_3", "gf_str_0068")
    elseif self.m_model:checkCanClick() == false then
        self:setTextByLanKey("right_cell_num_3", "ling_cloud_str_0002")
    end

    --快速导航
    self:setObjectVisible("guide_btn", true)
end

function M:refreshTimeUI()
    self:setTextByLanKey("left_cell_num_1", self.m_model:getHighArenaEndTime())
    if self.m_model.m_top_arena == nil or self.m_model.m_top_arena.last_time == -1 then
        self:setTextByLanKey("right_cell_num_1", "ling_cloud_str_0003")
    else
        self:setTextByLanKey("right_cell_num_1", self.m_model:getTopArenaEndTime())
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
