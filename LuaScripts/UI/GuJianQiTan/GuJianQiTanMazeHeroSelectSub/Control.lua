local M = class("GuJianQiTanMazeHeroSelectSubControl",LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:updateMsg("guide_check", nil, "GuJianQiTan.GuJianQiTanMaze")
        self:closeView()
    elseif msg == "ok_btn" then
        local select_index = self.m_model.m_select_index;
        local heroData = self.m_model:getShowHeroData()
        local cell_data = self.m_model.m_cell_data;
        local m_engageHeroId = self.m_model.m_engageHeroId
        local moveFinish = {
            callback = function()
                local item_data = heroData[select_index]
                local engageHeroId = m_engageHeroId
                if cell_data.status == 0 then
                    static_rootControl:updateMsg("maze_employ", {data = cell_data, param = engageHeroId, replace_hero_oid = item_data.hero_id}, "GuJianQiTan.GuJianQiTanMaze")
                else
                    static_rootControl:updateMsg("maze_employ", {hero_oid = engageHeroId, replace_hero_oid = item_data.hero_id}, "GuJianQiTan.GuJianQiTanMaze")
                end
            end,
            select_index = select_index
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        self:closeView()
    elseif msg == "look_btn" then
        local cell_data = data.cell_data
        self:openView("HeroBag", {player_data = {heros = {[cell_data.hero_id] = cell_data.hero_data}}, mode = 3, oid = cell_data.hero_id})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
