local M = class("HuntTreasuresBigMapPop",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.HuntTreasures.HuntTreasuresBigMapPop.Guide"
    self:updateTime()
    self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

--[[
function M:startGuide()
    local have_guide = UserDataManager.guide_data:setAnyTeamGuide(57, 1)
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
end
]]--

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "explain_btn" then
        local params = {}
        params.title = "tid#mining_dec_04"
        params.content = "tid#mining_dec_05"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "box_reward" then
        if data and data.data then
            local function callfunc(response)
                RewardUtil:rewardTipsByData(response.reward or {})
                self.m_model:initData(response)
                self.m_view:refreshUI()
            end
            self.m_model:getNetData("mining_receive_scale", { scale = data.data }, callfunc)
        end
    elseif msg == "box_click" then
        if data and data.data then
            local itemData = {data.data}
            self:openView("Pops.LookRewardTips",{rewards = itemData, click_transform = data.click_transform, show_check_mark = false})
        end
    elseif msg == "map_btn_1" then
        self:requestLocationIndex(1)
    elseif msg == "map_btn_2" then
        self:requestLocationIndex(2)
    elseif msg == "map_btn_3" then
        self:requestLocationIndex(3)
    elseif msg == "map_btn_4" then
        self:requestLocationIndex(4)
    elseif msg == "refresh_index" then
        if self.m_timer_id then
            self:removeTimer(self.m_timer_id)
        end
        local function callfunc(response)
            self.m_model:initData(response)
            self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("mining_map_index",nil, callfunc)
    elseif msg == "arena_btn" then
        self:requestLocationIndex(1)
    end
end

function M:requestLocationIndex(map_id)
    local region_id, location_id = map_id, 1
    local open_flag, tips_str = BtnOpenUtil:isBtnOpen(self.m_model.open_id[map_id])
    if open_flag then
        self:openView("HuntTreasures.HuntTreasuresAreaPop",  { region_id = region_id })
        --self:updateMsg("refresh_cur_page", { region_id = region_id, location_id = location_id },"HuntTreasures")
        self:updateMsg(99999)
    else    
        GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2})
    end
end

function M:updateTime()
    self.m_view:updateTime()
end

function M:destroy()
    if self.m_timer_id then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M;
