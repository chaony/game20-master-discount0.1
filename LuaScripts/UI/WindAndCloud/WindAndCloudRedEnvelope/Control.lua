---@class WindAndCloudRedEnvelopeControl: OOControlBase
local M = class("WindAndCloudRedEnvelopeControl",LikeOO.OOControlBase)

function M:onEnter()
    local active_data = UserDataManager:getActivesDataByOpenId(407)
    if active_data then
        local common = ConfigManager:getCfgByName("common")
        local timers = common[779] and common[779].value or 5
        timers = timers >=5 and timers or 5
        self.m_timer_id = self:setTimer(5, handler(self, self.updateTime))
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point", nil, "WindAndCloud.WindAndCloudMain")
        self:closeView()
    elseif msg == "reward_preview_btn" then
        local rewards = self.m_model:getGachaShipRewards()
        self:openView("Pops.RewardPreviewPop", {show_rewards = rewards})
    elseif msg == "red_big" then --红包 
        self:openView("WindAndCloud.WindAndCloudRedPacket",{is_main_open = true} )
    elseif msg == "hint_btn" then
        local active = ConfigManager:getCfgByName("active")
        local title = ""
        for k,v in pairs(active) do
            if v.open_id == self.m_model.open_id and v.version ==self.m_model.m_version then
                title = v.name
            end
        end
        self:openView("Pops.CommonHelpPop", { title = title, content = "tid#DiamondEvent_5"})
    elseif msg == "update_red_bag_data" then --需要重新刷新红包数据
        local function netCallback(response)
            if self.m_view then
                self.m_model.m_count = response.count
                self.m_model.m_total_rank_data = {}
                self.m_model:insertRankData(response.ranks,response)
                self.m_view:refreshUI()
            end
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.m_version
        params.start = 1
        params.stop = 10
        self.m_model:getNetData("redbag_send_rank", params, netCallback)
    elseif msg == "peak_game_btn_new" then
        local cfg = ConfigManager:getCfgByName("redbag_draw")
        local cost = cfg and cfg[self.m_model.open_id][self.m_model.m_version].cost
        local limit_num = cfg and cfg[self.m_model.open_id][self.m_model.m_version].open_times or 200
        local price = cost[1][3] or 500
        local params =
        {
            --内容
            msg = Language:getTextByKey("wind_clouds_text_0009"),
            --标题
            title = Language:getTextByKey("wind_clouds_text_0005"),
            --通知的类名
            --className = "QiXi.QiXiShopping",
            --消耗类型
            --cost_data = gift_data.cfg.price_type or 1,
            cost_data = 1,
            --消耗
            --cost = gift_data.cfg.price or 1,
            limit_num = limit_num,
            cost = price,
            --点击购买
            clickBuy = function(num)
                --self:getReward(num)
                if num <=0 then
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wind_clouds_red_packet_text_00015"), delay_close = 2})
                    return
                end
                local function netCallback(response)
                    if self.m_view then
                        if response["end"] then
                            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("wind_clouds_red_packet_text_00013"), delay_close = 2})
                            self:closeView()
                            return
                        end
                        RewardUtil:rewardTipsByData(response.reward) --展示奖励
                        self.m_model:updateTimes(response)
                        self.m_view:refreshUI()
                        local function netCallback_(response_)
                            if self.m_view then
                                local states = response_.status
                                self.m_view:updateActivityTimer(states)
                            end
                        end
                        local params_ = {}
                        params_.open_id = self.m_model.open_id
                        params_.vsn = self.m_model.m_version
                        self.m_model:getNetData("redbag_red_dot", params_, netCallback_)
                    end
                end
                local params = {}
                params.open_id = self.m_model.open_id
                params.vsn = self.m_model.m_version
                params.box_num = num or 0
                self.m_model:getNetData("redbag_receive_draw_gift", params, netCallback)
            end
        }
        self:openView("Pops.CommonTimesPop", params)
    elseif msg == "load_rank" then --刷新到最低
        self:requestLoadRank()
    elseif msg == "refresh_red_point" then
        local function netCallback(response)
            if self.m_view then
                local states = response.status
                self.m_view:updateActivityTimer(states)
            end
        end
        local params = {}
        params.open_id = self.m_model.open_id
        params.vsn = self.m_model.m_version
        self.m_model:getNetData("redbag_red_dot", params, netCallback)
    end
end

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
        params.vsn = self.m_model.m_version
        params.start = start_pos
        params.stop = end_pos
        self.m_model:getNetData("redbag_send_rank", params, netCallback)
    end
end

function M:updateTime()
    local function netCallback(response)
        if self.m_view then
            local states = response.status
            self.m_view:updateActivityTimer(states)
        end
    end
    local params = {}
    params.open_id = self.m_model.open_id
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("redbag_red_dot", params, netCallback)
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

return M

