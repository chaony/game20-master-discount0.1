---@class DeliciousFeastRankControl: OOControlBase
local M = class("NationalBeautifulHeroesListControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, self.m_model.refresh_main)
        self:closeView()
    elseif msg == "peak_game_btn" then --赠送
        self:favorSend(true) 
    elseif msg == "send_all_gift" then --一键赠送
        self:sendAllGift()
    elseif msg == "send_reward" then --赠送
        self:sendAllGift(1)
    elseif msg == "close_send_gift" then --关闭好感度道具赠送
        self:favorSend(false)
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
    elseif msg == "hero_btn" then --点击貂蝉
        self.m_model.show_dialogue_id = 3
        self.m_view:showDialogue()
    elseif msg == "load_rank" then --刷新到最低
        self:requestLoadRank()
    elseif msg == "refresh_data" or msg == "refreshRedPoint" then --刷新数据
        self:refreshData()
    else
        self:tryOpenItem(msg)
    end
end

--刷新list数据
function M:refreshListData(data_id)
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        self.m_model:netData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("active_diamond_rebate_ranks", {open_id = self.m_model.open_id,version = data_id,start = 1, stop = 10},netCallback)
end

--跳转页签
function M:tryOpenItem(btn_name)
    local item = self.m_model:getItem(btn_name)
    if item then
        local show_active_data = self.m_model:getActiveData(item.open_id) or {}
        local version = self.m_model:getActVsn(item.open_id,item.is_recharge)
        local params = {
            is_token = self.m_model:getTokenFlag(),
            open_id = item.open_id,
            active_data = show_active_data,
            version = version}
        if item.open_id == 411 or item.open_id == 422 then --郿坞试炼
            params.refresh_main = "NationalBeautiful.NationalBeautifulHeroesList"
            params.is_show_break_btn = 1
        end
        if item.jump_id ~= nil then
            local active_data = UserDataManager:getOpenActiveData(item.open_id)
            if active_data == nil then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
                return
            end
            local token = self.m_model:getTokenFlag()
            QuickOpenFuncUtil:openFunc(item.jump_id, { open_id = item.open_id,level_up = 1 ,is_token = token})
        else
            if self.m_model.is_show == 2 then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_xi_050"), delay_close = 2})
                return 
            end
            params.recv = self.m_model.m_data.recv
            self:openView(item.prefab_folder.."."..item.prefab_name, params)
        end
        if item.is_close_view then
            --self:setOnceTimer(0.5,function()
            --    self:closeView()
            --end)
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

--赠送
function M:favorSend(send_show_stuae)
    if send_show_stuae == self.m_model.show_send_gift then
        return
    else
        self.m_model.show_send_gift = send_show_stuae
    end
    self.m_view:updateSendGift(self.m_model.show_send_gift)
end

--一键赠送
function M:sendAllGift(send_num)
    if self.m_model.send_gift_num <= 0 then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
        return
    end
    self.m_model.show_dialogue_id = 2
    self.m_view:showDialogue()
    local function netCallback(response)
        if response["end"] == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:closeView()
            return
        end
        RewardUtil:rewardTipsByData(response.reward) --展示奖励
        self.m_model:netData(response)
        self.m_model:refreshRankData(response)
        self.m_view:refreshUI()
    end
    local num = self.m_model.send_gift_num
    if send_num then
        num = send_num
    end
    local params = {
        open_id = self.m_model.open_id,
        version = self.m_model.version,
        num = num
    }
    self.m_model:getNetData("active_common_favor_send", params,netCallback)
end

--加载排行
function M:requestLoadRank()
    local start_pos, end_pos = self.m_model:getLoadIndex()
    if start_pos > 0 then
        local function netCallback(response)
            if self.m_view then
                self.m_model.m_count = response.count
                self.m_model:insertRankData(response.ranks,response)
                self.m_view:refreshUI(true)
            end
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.version
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("active_common_favor_ranks", params, netCallback)
    end
end

--刷新数据
function M:refreshData()
    local function netCallback(response)
        if self.m_view then
            self.m_view:refreshUI()
        end
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.version = self.m_model.version
    self.m_model:getNetData("active_common_favor_index", params, netCallback)
end

function M:destroy()
    M.super.destroy(self)
end

return M

