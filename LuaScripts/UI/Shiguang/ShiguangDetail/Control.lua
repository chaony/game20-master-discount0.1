local M = class("ShiguangDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_cell_data.status == 0 then
            self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "Shiguang")
        else
            self:updateMsg("goto_battle", {data = self.m_model.m_cell_data}, "Shiguang")
        end
        self:closeView()
    elseif msg == "cell_btn" then
        -- local cell_data = data.cell_data
        -- self:openView("HeroInfo", {player_data = {heros = {[cell_data.card_id] = cell_data.hero_data}}, look_model = 1, oid = cell_data.card_id})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
