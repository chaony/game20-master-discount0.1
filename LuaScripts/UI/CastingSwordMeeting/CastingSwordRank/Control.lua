---@class CastingSwordRankControl: OOControlBase
local M = class("CastingSwordRankControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "reward_btn" then --奖励
        self:refreshShowMode(2)
    elseif msg == "rank_btn" then --排行
        self:refreshShowMode(1)
    elseif msg == "hint_btn" then --帮助
        local show_data = self.m_model:getShowDate()
        local params = {}
        params.title = self.m_view.avtive_data.name
        params.content = show_data.favor_des or ""
        self:openView("Pops.CommonHelpPop", params)
    else
        self:tryOpenItem(msg)
    end
end

--跳转页签
function M:tryOpenItem(btn_name)
    local item = self.m_model:getItem(btn_name)
    if item then
        if item.open_id == 259 then
            self:openView("TopUpGiftBag", {actives = UserDataManager.m_actives, open_id = self.m_is_token, active_id = item.active_id})
            return
        elseif item.open_id == 251 then
            self:openView("GiftBag", {mode = 1, actives = UserDataManager.m_actives, open_id = self.m_is_token, active_id = item.active_id})
        end
    end
end

--切换显示模式
function M:refreshShowMode(mode_id)
    if self.m_model.current_show_tab_num ~= mode_id then
        self.m_model:setSelectIndex(mode_id)
        self.m_view:refreshUI()
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M