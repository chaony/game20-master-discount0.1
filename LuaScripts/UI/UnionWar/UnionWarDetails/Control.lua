local M = class("UnionWarDetailsControl",LikeOO.OOControlBase)


function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
        self:updateMsg("hide_small_tip", nil, "UnionWar.UnionWarSmallTip")
    elseif msg == "recall_btn" then 
        self:requestRecall(data.team_id)
    end
end

function M:requestRecall(teamID)
    local function callback(response)
      self:requestUnionWarDetails()
    end
    self.m_model:getNetData("guild_war_recall", {team_id = tostring(teamID)}, callback)
end

function M:requestUnionWarDetails()
    local function callback(response)
        self.m_model.m_data = response
        self.m_view:refreshUI()
        self:updateMsg("refresh_data", nil, "UnionWar.UnionWarMain")
    end
    self.m_model:getNetData("guild_war_cell_info", {cell_id = self.m_model.m_index}, callback)
end

return M