---@class RankListControl
local M = class("RankListControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("common_refresh", nil, "parent") 
        self:updateMsg("refresh_red_point", {red_point = self.m_model.m_red_point, id = self.m_model.m_id}, "Rank.RankMain") 
        self:closeView()
    elseif msg == "item_click" then
    	local item_data = self.m_model:getRankDataByIndex(data.id)
    	self:openView("Pops.PlayerInfo", {uid = item_data.user.uid})
    elseif msg == "score_look" then
        GameUtil:lookInfoTips(self, data)
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#ranking1", content = "tid#ranking2" })
    elseif msg == "check_tag" then
        self:switchTabBtn(data)
    elseif msg == "look_player" then
        local cell_data = self.m_model:getQuestsDataByIndex(data.index)
        self:openView("Pops.PlayerInfo", {uid = cell_data.data.user.uid})
    elseif msg == "click_self_info" then
        self.m_model.m_click_self = not(self.m_model.m_click_self)
        self.m_view:refreshUI()
        self.m_view:refreshOwnPrebPosition()
    end
end

-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
