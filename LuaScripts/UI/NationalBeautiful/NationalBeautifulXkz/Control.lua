local M = class("NationalBeautifulXkzControl",LikeOO.OOControlBase)

function M:onEnter()
    self:updateTime()
    RedPointUtil:saveLocalRedPointFreshTime("raccon_xkz_daily_once")
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("refresh_red_point", nil, self.m_model.refresh_main)
        self:closeView()
    elseif msg == "refreshRedPoint" then
        self.m_view:refreshRedPoint() 
    elseif msg == "hero_btn1" then
        self:openXkzDetail(1)
    elseif msg == "hero_btn2" then
        self:openXkzDetail(2)
    elseif msg == "hero_btn3" then
        self:openXkzDetail(3)
    elseif msg == "help_btn" then
        local params = {}
        local open_condition = ConfigManager:getCfgByName("open_condition")
        local o_item = open_condition[341] or {}
        params.title = o_item.name or "raccon_text_0003"
        params.content = "tid#XiaoHuanXiongDes_3"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "box_click" then
        audio:SendEvtUI("UI_Pay")
        local rewards = data.data.rewards or {}
        self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = data.status == -1})
    elseif msg == "box_reward" then
        audio:SendEvtUI("UI_Pay")
        local box_id = data.data.box_id or 0
        self:getBoxReward(box_id)
    elseif msg == "refreh_index" then
        self:refreshIndex()
    elseif msg == "change_index" then
        if data and self.m_model.m_cur_index ~= data then
            self.m_model.m_cur_index = data
            self.m_view:refreshUI()
        end
    elseif msg == "update_data" then
        if data then
            self.m_model:updateData(data)
            self.m_view:refreshUI()
        end
    end
end

function M:openXkzDetail(hero_index)
    local hero = self.m_model:getCfgValueByKey("hero") or {}
    hero_index = hero[hero_index]
    local is_lock,lock_des = self.m_model:isChapterUnlock(hero_index)
    if is_lock then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey(lock_des), delay_close = 2})
    else
        local active = self.m_model:getActiveData(self.m_model.open_id)
        self:openView("NationalBeautiful.NationalBeautifulXkzDetail", {hero_index = hero_index,
                                                 cur_index = self.m_model.m_cur_index,
                                                 net_data = self.m_model.m_data,
                                                 open_id = self.m_model.open_id,
                                                 version = self.m_model.version,
                                                 active = active})
    end
end

--计时器
function M:updateTime()
    self.m_view:updateActivityTimer()
end

function M:getBoxReward(box_id)
    local function netCallback(response)
        if response.update then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response["end"] then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
            self:closeView()
            return
        end
        if response and response.reward then
            RewardUtil:rewardTipsByData(response.reward)
        end
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("raccon_common_chapter_recv", {open_id=self.m_model.open_id,vsn = self.m_model.version,score_id = box_id, chapter_id = self.m_model.m_cur_index}, netCallback)
end


function M:destroy()
    self:removeTimer(self.m_timer_id)
    M.super.destroy(self)
end

function M:refreshIndex()
    local function receivetCallback(response)
        self.m_model:updateData(response)
        self:updateMsg("update_data", response, "NationalBeautiful.NationalBeautifulXkzDetail")
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("raccon_common_index", {open_id = self.m_model.open_id,vsn = self.m_model.version}, receivetCallback)
end


return M;
