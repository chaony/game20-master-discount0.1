local M = class("GuJianQiTanMazeHeroSelectControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.GuJianQiTan.GuJianQiTanMazeHeroSelect.Guide"
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
        if table.nums(self.m_model.m_assist_heros) >= 5 then
            if select_index == -1 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0357"), delay_close = 2})
                return
            end
            local item_data = heroData[select_index]
            self:openView("GuJianQiTan.GuJianQiTanMazeHeroSelectSub", {m_assist_heros = self.m_model.m_assist_heros,data = cell_data, engageHeroId = item_data.hero_id, callBack = self.m_model.m_callBack})
        else                                 
            local moveFinish = {
                callback = function()
                    local item_data = heroData[select_index]
                    if cell_data.status == 0 then
                        static_rootControl:updateMsg("maze_employ", {data = cell_data, param = item_data.hero_id}, "GuJianQiTan.GuJianQiTanMaze")
                        --self:updateMsg("maze_goto", {data = self.m_model.m_cell_data, param = item_data.hero_id}, "MazeStage")
                    else
                        static_rootControl:updateMsg("maze_employ", {hero_oid = item_data.hero_id}, "GuJianQiTan.GuJianQiTanMaze")
                    end
                end,
                select_index = select_index
            }
            if self.m_model.m_callBack ~= nil then
                self.m_model.m_callBack( moveFinish )
            end
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
