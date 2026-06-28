local M = class("UnionWarSmallTipControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:onHandle(msg, data)
    if msg == 99999 or msg == "back_btn" then
        self:updateMsg("refresh_data", nil, "UnionWar.UnionWarMain")
        self:closeView()
    elseif msg == "btn_pull" then --选择帮会战难度
        local difficulty = self.m_model.m_difficulty == 0 and 1 or 0
        self.m_model.m_difficulty = difficulty
        self.m_view:setDifficulty()
    elseif msg == "change_di_1" then --难度1
        self.m_model.m_difficulty_star = 1 
        self.m_view:refreshDifficulty()
    elseif msg == "change_di_2" then --难度2
        self.m_model.m_difficulty_star = 2
        self.m_view:refreshDifficulty()
    elseif msg == "change_di_3" then --难度3
        self.m_model.m_difficulty_star = 3
        self.m_view:refreshDifficulty()
    elseif msg == "battle_btn" then
        if self.m_model:getFormationIndex() then
            self:goBattle()
            self:closeView()
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#Guild_3"), delay_close = 2})
        end
        
    end
end

function M:goBattle()
    local formation_index = self.m_model:getFormationIndex()
    self:openView("Formation", {mode = GlobalConfig.BATTLE_MODE.UNIONWAR, def_data = self.m_model.m_data, gvg_data = self.m_model.m_union_war_data, formation_index = formation_index,GVGstar = self.m_model.m_difficulty_star})
end

return M
