---@class MazeStageRelicFormationShowControl:OOControlBase
---@field m_model MazeStageRelicFormationShowModel
local M = class("MazeStageRelicFormationShowControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.MazeStage.MazeStageRelicFormationShow.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
    	self:updateMsg("guide_check", nil, "MazeStage")
        self:closeView()
    elseif msg == "cell_click" then
        if self.m_model.m_open_type == "yin_tower" then
        else
            data.look_mode = 1
            data.assist_heros = self.m_model.m_data.assist_heros
            data.team_key = self.m_model.m_team_key
            self:openView("MazeStage.MazeStageRelicLook", data)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
