local M = class("TreasureBoxControl", LikeOO.OOControlBase)

function M:onEnter()
    -- self:updateTime()
    -- self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg, date)
    if msg == 99999 then
        self:closeView()
    elseif msg == "close_btn" then
        self:closeView()
    elseif msg == "btn_exchange" then --抽奖
        local svTime = UserDataManager:getServerTime()
        if svTime >= self.m_model.m_params.active_time.end_ts then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        else
            local prop_cfg = self.m_view.itemData
            if prop_cfg.user_num >= prop_cfg.data_num then
                self:getGift()
            else
                local params = {
                    text = Language:getTextByKey("new_str_0700"),
                    tow_close_btn = true,
                    on_ok_call = function()
                        self:updateMsg("getPop")
                    end
                }
                self:openView("Pops.CommonPop", params)
            end
        end
    elseif msg == "btn_openBox_one" then  --立即开启
        self:receiveBox(0)
    elseif msg == "box_click" then
        audio:SendEvtUI("UI_Click_N1")
        self:checkBox(1)
    elseif msg == "btn_openBox" then --开启箱子
        self:receiveBox(date)
    elseif msg == "getPop" then --道具不足，获取道具
        self:closeView()
        self:updateMsg("btn_MaterialAcquisition", nil, "Summer.SummerMain")
        self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
    elseif msg == "btn_desc" then
        local btn = self.m_view:findGameObject("btn_desc")
        local chestCfg = ConfigManager:getCfgByName("chest")

        local posObj = self.m_view:findGameObject("pos_desc")
        self:openView(
            "Pops.MeridianSkillPop",
            {
                click_transform = posObj.transform,
                desc = Language:getTextByKey(chestCfg[1].des)
            }
        )
    --
    elseif msg == "to_active_obj" then --侠客试炼
        self:closeView("Activities.WorldBoss.HeroBossTrainPop")
        self:closeView("Summer.SummerMain")
        QuickOpenFuncUtil:openFunc(78)   
        self:setOnceTimer(0.1, function ()
            self:updateMsg(99999)
        end)
    end
end

--获取一个奖励(抽奖)
function M:getGift()
    local function netCallback(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        self.m_model:updateServerData(response)
        self.m_view:refreshUI()
        self:updateMsg("draw", response, "Summer.SummerMain")
        self:updateMsg("redPoint_update", nil, "Summer.SummerMain")

        -- self.m_view:reSelectedFirstBox()
    end
    self.m_model:getNetData("hero_chest_random_draw", {version = self.m_model.m_draw_vsn}, netCallback)
end

--设置当前选中的箱子
-- function M:checkBox(data)
--     local current_box_index = self.m_view.m_current_check_box
--     self.m_view.m_current_check_box = 0
--     self.m_view.m_current_check_data = { }
--     if data.cur_box then
--         if data.index ~= current_box_index then
--             self.m_view.m_current_check_box = data.index
--             self.m_view.m_current_check_data = data.cell_data
--         end
--     end
--     self.m_view:refreshUI()
-- end

--一键领取奖励
function M:receiveBoxOne()
    local function netCallback(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        self.m_model:updateServerData(response)
        self.m_view.m_current_check_box = 0
    end
end

--领奖
function M:receiveBox(is_one_receive)
    local lastCheckBox = self.m_view.m_current_check_box or 0
    local function netCallback(response)
        if response["end"] == 1 then --活动结束提示
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
            self:updateMsg(99999)
        end
        RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
        self.m_model:updateServerData(response)
        self.m_view.m_current_check_box = 0

        for i = 1, lastCheckBox do
        local data = self.m_model.m_draw_box[i]--:getDrawListData()
        if data and data.gift then
                self.m_view.m_current_check_box = i
            end
        end

        self.m_view.m_openBoxTime = 2

        -- self.m_view.m_current_check_data = { }
        self.m_view:refreshUI()
        self:updateMsg("draw", response, "Summer.SummerMain")
        self:updateMsg("redPoint_update", nil, "Summer.SummerMain")
    end
    local cost = 0
    if is_one_receive == 0 then
        lastCheckBox = is_one_receive
        cost = is_one_receive
    else
        local curBox = self.m_view:getSelectBox()
        if curBox.ts - UserDataManager:getServerTime() > 0 then
            cost = 1
        end
    end
    local params = {
        version = self.m_model.m_draw_vsn,
        position = lastCheckBox,
        cost = cost
    }
    self.m_model:getNetData("hero_chest_receive_draw_gift", params, netCallback)
end

--更新时间
-- function M:updateTime()
--     self.m_view:updateTime()
-- end

return M
