local M = class("GuJianQiTanDrawControl",LikeOO.OOControlBase)


function M:onHandle(msg, data)
    if msg == 99999 then
        self:updateMsg("refresh_red_point_gift", nil, "GuJianQiTan.GuJianQiTanMain")
        self:closeView()
    elseif msg == "help_btn" then --帮助说明
        local params = {}
        params.title = "gu_jian_qi_tan_str_001"
        params.content = "tid#SwordDes3"
        self:openView("Pops.CommonHelpPop", params)
    --活动
    elseif msg == "btn_moon" or msg == "btn_furnace" or msg == "btn_ice" then
        if msg == "btn_ice" then
            audio:SendEvtUI("UI_Icebroken")
            self.m_model:setTouchBtnIndex(1)
        elseif msg == "btn_moon" then
            audio:SendEvtUI("UI_LQYWen")
            self.m_model:setTouchBtnIndex(2)
        elseif msg == "btn_furnace" then
            audio:SendEvtUI("UI_FireFall")
            self.m_model:setTouchBtnIndex(3)
        end
        local touch_id, can_forge_flag = self.m_model:checkSwordForge(msg)
        self.m_view:lockTouch()
        self.m_view:updateTouchGuideEffect()
        if can_forge_flag then
            self.m_view:playTouchAnim(msg, function()
                self:chooseOne(msg, touch_id, can_forge_flag)
            end)
        else
            self:chooseOne(msg, touch_id, can_forge_flag)
        end
    --里程碑
    elseif msg == "box_reward" then --领取
        audio:SendEvtUI("Ui_Reward")
        self:tryToGetReward(data.data)
    elseif msg == "box_click" then --展示
        self:openView("Pops.LookRewardTips", {rewards = {data.data.reward} , click_transform = data.click_transform, show_check_mark = data.data.status == 2})
    end
end

--活动
function M:chooseOne(msg, touch_id, can_forge_flag)
    if can_forge_flag == true then
        local function netCallback(response)
            if response and response.reward and response.interact_result ~= nil then
                local function rewardCallback()
                    self.m_model:updateData(response)
                    self.m_view:updateSwordForgeCount()
                    self.m_view:updateProgressText()
                    self.m_view:updateProgressSlider()
                    self:displayWord(self.m_model:getResultTipWord(msg, response.interact_result), response.interact_result)
                end
                RewardUtil:rewardTipsByData(response.reward, nil, rewardCallback)
            else
                self.m_view:unlockTouch()
            end
        end
        local params = {}
        params.bubble_id = touch_id
        self.m_model:getNetData("ancient_sword_and_wonderland_sword_sign_bubble_interact", params, netCallback, nil, true)
    else
        self:displayWord(self.m_model:getContentWord(), false)
    end
end

function M:displayWord(word, result)
    self.m_view:displayWord(word, result)
    local function netCallback()
        self.m_view:displayWord(self.m_model:getContentWord())
        self.m_view:unlockTouch()
        self.m_view:updateTouchGuideEffect()
    end
    self:setOnceTimer(3.0, netCallback)
end

--里程碑    
function M:tryToGetReward(data)
    if data.status == 1 then--可领取
        local function netCallback(response)
            self.m_model:updateData(response)
            self.m_view:updateProgressSlider()
            RewardUtil:rewardTipsByData(response.reward)
        end
        local params = {}
        params.score = data.score
        self.m_model:getNetData("ancient_sword_and_wonderland_sword_sign_progress_bar", params, netCallback) 
    end
end    

return M;
