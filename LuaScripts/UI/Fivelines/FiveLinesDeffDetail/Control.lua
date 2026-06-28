local M = class("FiveLinesDeffDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Fivelines.FiveLinesDeffDetail.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        self:updateMsg("battle_start", { data = self.m_model.m_cell_data, index = self.m_model.m_index }, "Fivelines")
        self:closeView()
    elseif msg == "cell_btn" then
        --local cell_data = data.cell_data
        --self:openView("HeroInfo", {player_data = {heros = {[cell_data.card_id] = cell_data.hero_data}}, look_model = 1, oid = cell_data.card_id})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
