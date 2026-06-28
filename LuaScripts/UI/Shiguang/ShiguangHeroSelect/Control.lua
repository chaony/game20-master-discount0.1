local M = class("ShiguangHeroSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "ok_btn" then
        if self.m_model.m_select_index == nil or self.m_model.m_select_index == -1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
            return
        end
        local data = self.m_model:getShowHeroData()
        local item_data = data[self.m_model.m_select_index]
        self:updateMsg("shiguang_employ", {data = self.m_model.m_cell_data, hero_oid = item_data.hero_id}, "Shiguang")
        self:closeView()
    elseif msg == "look_btn" then
        local cell_data = data.cell_data
        self:openView("HeroInfo", {player_data = {heros = {[cell_data.hero_id] = cell_data.hero_data}}, look_model = 1, oid = cell_data.hero_id})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
