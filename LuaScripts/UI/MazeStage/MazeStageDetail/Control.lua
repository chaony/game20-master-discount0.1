local M = class("MazeStageDetailControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.MazeStage.MazeStageDetail.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:updateMsg("guide_check", nil, "MazeStage")
        self:closeView()
    elseif msg == "ok_btn" then
        local cell_data = self.m_model.m_cell_data;
        local moveFinish = {
            callback = function()
                if cell_data.status == 0 then
                    -- self:updateMsg("maze_goto", {data = self.m_model.m_cell_data}, "MazeStage")
                    static_rootControl:updateMsg("goto_battle", {data = cell_data}, "MazeStage")
                else
                    static_rootControl:updateMsg("goto_battle", {data = cell_data}, "MazeStage")
                end
            end
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        self:closeView()
    elseif msg == "speed_btttle" then
        local cell_data = self.m_model
        local moveFinish = {
            callback = function()
                static_rootControl:updateMsg("speed_btttle",cell_data,"MazeStage");
            end
        }
        if self.m_model.m_callBack ~= nil then
            self.m_model.m_callBack( moveFinish )
        end
        self:closeView()
        --self:updateMsg("speed_btttle",self.m_model,"MazeStage");
        --self:closeView();
    elseif msg == "cell_btn" then
        --local cell_data = data.cell_data
        --self:openView("HeroInfo", {player_data = {heros = {[cell_data.card_id] = cell_data.hero_data}}, look_model = 1, oid = cell_data.card_id})
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
