local M = class("ShiguangRelicFormationShowControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cell_click" then
        data.look_mode = 1
        data.assist_heros = self.m_model.m_data.assist_heros
        data.team_key = "rpg_map"
        self:openView("MazeStage.MazeStageRelicLook", data)
    end
end

function M:destroy()
    M.super.destroy(self)
    
end


return M
