local M = class("MaterialAcquisitionControl", LikeOO.OOControlBase)

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
    elseif msg == "buy" then -- 购买
        self:buyQuest()
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
        if self.m_view then
            RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
            self.m_model:updateServerData(response)
            self.m_view:refreshUI() --刷新列表
            self:updateMsg("material_quest", response, "Summer.SummerMain")
            self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
        end
    end
    local params = {quest_id = data.quest_id, version = self.m_model.m_quest_vsn}
    self.m_model:getNetData("hero_chest_receive_quest", params, netCallback)
end

--领取购买奖励
function M:buyQuest()
    local function netCallback(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        self.m_model:updateBuyServerData(response)
        self.m_view:refreshUI() --刷新列表
        RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        self:updateMsg("refreshUI_Material", response, "Summer.SummerMain")
        self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
    end

    self.m_model:getNetData("hero_chest_buy_shop_goods", {version = self.m_model.m_quest_vsn}, netCallback)
end

return M
