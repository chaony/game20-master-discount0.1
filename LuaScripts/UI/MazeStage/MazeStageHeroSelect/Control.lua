local M = class("MazeStageHeroSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.MazeStage.MazeStageHeroSelect.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:updateMsg("guide_check", nil, "MazeStage")
        self:closeView()
    elseif msg == "ok_btn" then
        --if self.m_model.m_cell_data.status == 0 then
        --    self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "MazeStage")
        --else
        --    if self.m_model.m_select_index == nil or self.m_model.m_select_index == -1 then
        --        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
        --        return
        --    end
        --    local data = self.m_model:getShowHeroData()
        --    local item_data = data[self.m_model.m_select_index]
        --    self:updateMsg("maze_employ", {hero_oid = item_data.hero_id}, "MazeStage")
        --end
        --self:closeView()
        local select_index = self.m_model.m_select_index;
        local data = self.m_model:getShowHeroData()
        local cell_data = self.m_model.m_cell_data;
        local moveFinish = {
            callback = function()
                local item_data = data[select_index]
                if cell_data.status == 0 then
                    static_rootControl:updateMsg("maze_employ", {data = cell_data, param = item_data.hero_id}, "MazeStage")
                    --self:updateMsg("maze_goto", {data = self.m_model.m_cell_data, param = item_data.hero_id}, "MazeStage")
                else
                    static_rootControl:updateMsg("maze_employ", {hero_oid = item_data.hero_id}, "MazeStage")
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
