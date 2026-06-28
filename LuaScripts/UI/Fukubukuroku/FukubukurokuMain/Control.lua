---@class FukubukurokuMainControl: OOControlBase
local M = class("FukubukurokuMainControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "NationalBeautiful.NationalBeautifulMain")
        self:updateMsg("update_red", nil, "OperateActivity")
        self:closeView()
    elseif msg == "share_btn" then
        self:openView("Fukubukuroku.FukubukurokuShare",{open_id = self.m_model.open_id,vsn = self.m_model.version,can_share = self.m_model.can_share})  -- 分享图片
    elseif msg == "hint_btn" then --帮助
        local active_tab = ConfigManager:getCfgByName("active")
        local title = Language:getTextByKey("fukubukuroku_text_0007")
        for k,v in pairs(active_tab) do
            if v.open_id == self.m_model.open_id and v.version ==self.m_model.version then
                title = v.name
            end
        end
        local params = {}
        params.title = title
        params.content = "tid#LuckybagEvent"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "reward_preview_btn" then
        local rewards = self.m_model:getGachaShipRewards()
        self:openView("Pops.RewardPreviewPop", {show_rewards = rewards})
    elseif msg == "update_can_share" then
        local Callback = function(response)
            self.m_model.can_share = response.can_share or 0
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("fukubukuro_luckbag_index",{open_id = self.m_model.open_id,vsn = self.m_model.version},Callback)
    elseif msg == "Image_fudai_btn" then
        self:openView("Pops.LookRewardTips",{rewards = self.m_model.every_data.reward, click_transform = self.m_view:findGameObject("Image_fudai_btn").transform, show_check_mark = false})
    elseif msg == "peak_game_btn" then
        if self.m_model.daily == 1 then return end
        local function Callback(response)
            self.m_model.daily = response.daily or 0
            RewardUtil:rewardTipsByData(response.reward) --展示奖励
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("fukubukuro_luckbag_receive_daily",{open_id = self.m_model.open_id,vsn = self.m_model.version,quest_id =self.m_model.every_data.id},Callback)
    elseif msg == "click_btn" then
        if data.cell_data.status == 1 then --奖励可领取
            local function Callback(response)
                self.m_model.can_share = response.can_share or 0
                local call_back = function()
                    if  self.m_model.can_share > 0 and self.m_model.is_First_share == false then
                        self.m_model.is_First_share =true
                        self:openView("Fukubukuroku.FukubukurokuShare",{open_id = self.m_model.open_id,vsn = self.m_model.version,can_share = self.m_model.can_share})  -- 分享图片
                    end
                end
                RewardUtil:rewardTipsByData(response.reward,nil,call_back) --展示奖励
                self.m_model:InitRewardData(response)
                self.m_view:refreshUI(true)
            end
            local params = {open_id = self.m_model.open_id,vsn = self.m_model.version,quest_id = data.cell_data.id}
            self.m_model.is_First_share = false
            self.m_model:getNetData("fukubukuro_luckbag_login_stage",params,Callback)
        else
            --self:openView("Pops.LookRewardTips",{rewards = data.cell_data.reward, click_transform = data.cell_object.transform, show_check_mark = data.cell_data.status == -1})
        end
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

