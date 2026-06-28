---@class FukubukurokuShareControl: OOControlBase
local M = class("FukubukurokuMainControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "close_btn_main" then
        self:updateMsg("refresh_red_point", nil, "NationalBeautiful.NationalBeautifulMain")
        self:closeView()
    elseif msg == "share_btn" then
        self.m_view:ShareShow(false)
        local show_call = function()
            self.m_view:ShareShow(true)
        end
        local close_call = function()
            if self.m_model.can_share > 0 then 
                self.m_model:getNetData("fukubukuro_luckbag_share",{open_id = self.m_model.open_id,vsn = self.m_model.version,quest_id = self.m_model.can_share})
                self:updateMsg("update_can_share", nil, "Fukubukuroku.FukubukurokuMain")
                self:closeView()
            end
        end
        --local close_call = function()
        --    local callback = function(response)
        --        self:closeView()
        --        self:updateMsg("change_double_time",response , "Activities.ZhangMenSimulator") --开启双倍收益
        --    end
        --    self.m_model:getNetData("simulator_double_time",nil,callback)
        --end
        self:openView("SharePicture", {picture_callback = show_call,picture_closeback = close_call})  -- 分享图片
    elseif msg == "hint_btn" then --帮助
        local params = {}
        params.title = self.m_view.avtive_data.name
        params.content = "tid#BeautyEvent_favor"
        self:openView("Pops.CommonHelpPop", params)
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
        if item.open_id == 411 then --郿坞试炼
            params.refresh_main = "NationalBeautiful.NationalBeautifulMain"
            params.is_show_break_btn = 1
        end
        if item.jump_id ~= nil then
            QuickOpenFuncUtil:openFunc(item.jump_id, { open_id = item.open_id,level_up = 1 })
        else
            params.recv = self.m_model.m_data.recv
            self:openView(item.prefab_folder.."."..item.prefab_name, params)
        end
        if item.is_close_view then
            self:setOnceTimer(0.5,function()
                self:closeView()
            end)
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
                self.m_view:refreshUI()
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

function M:destroy()
    M.super.destroy(self)
end

return M

