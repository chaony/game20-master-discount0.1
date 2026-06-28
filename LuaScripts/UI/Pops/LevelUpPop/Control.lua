local M = class("LevelUpPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Pops.LevelUpPop.Guide"
    StatisticsUtil:onUserLevelChangeToBi()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("common_refresh",nil,"parent")
        self:closeView()
    end
end

return M;
