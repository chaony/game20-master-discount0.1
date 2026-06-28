local M = class("DragonswordQuestControl", LikeOO.OOControlBase)

function M:onEnter()
end

function M:jumpIsOpen(data, ext)
    data = data or {}
    if type(data) == "number" then
        data = {data}
    end
    local func_id = data[1]
    if func_id then
        local jump = ConfigManager:getCfgByName("jump")
        local jump_item = jump[func_id]
        if jump_item then
            local open_condition_id = jump_item.open_condition_id or 0
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
            if ext then
                ext.open_id = open_condition_id
            else
                ext = {open_id = open_condition_id}
            end
            if open_condition_id > 0 and not open_flag then
                GameUtil:lookInfoTips(static_rootControl, {msg = tips_str, delay_close = 2})
                return false
            end
        end
    end
    return true
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:closeView()
    elseif msg == "close_btn" then
        self:closeView()
    elseif msg == "reward" then --领取奖励
        self:questRecvSpecial(date)
    elseif msg == "goto_btn" then --前往
        local go_type = date.cfg.go_type or {}
        if self:jumpIsOpen(go_type) then
            static_rootControl:closeAllViewPop()
            QuickOpenFuncUtil:openFunc(go_type)
        end
    end
end

--  任务领奖  quest_id: 任务id
function M:questRecvSpecial(data)
    local function netCallback(response)
        RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        self.m_model:updateServerData(response)
        self.m_view:refreshUI() --刷新列表
        self:updateMsg("refresh_data", nil, "Dragonsword")
        self:updateMsg("refreshQuest", response, "Dragonsword.DragonswordMelting")
    end
    local params = {quest_id = data.id, vsn = self.m_model.m_version}
    self.m_model:getNetData("active_dragonsword_recv_quest_reward", params, netCallback)
end


return M
