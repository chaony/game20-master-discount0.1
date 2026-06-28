local M = class("FamilyDinnerTaskPopControl",LikeOO.OOControlBase)

function M:onEnter()
    --每隔1秒执行一次
    self:setTimer(1,function()

    end)
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "refreshRedPoint" then    
        self.m_view:refreshUI()
    elseif msg == "hint_btn" then 
        local params = {}
        params.title = "gf_str_0078"
        params.content = Language:getTextByKey("gf_str_0078")
        self:openView("Pops.CommonHelpPop", params) 
    elseif msg == "check_tag" then
        self.m_model:updateData(data, function()
            self:switchTabBtn(data)
        end)
    elseif msg == "get_reward" then    
        self:getReward(data)
    end
end

function M:getReward(data)
    --在线奖励
    local function receivetCallback(response)
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
        -- self.m_model:updateNetData(response)
        table.merge(self.m_model.m_dinner_done, response.dinner_done)
        self:updateMsg("refresh_data", response, "Activities.FamilyDinner.FamilyDinner")
        self.m_view:refreshUI()
    end
    local params = {version = self.m_model.m_version, score_id = data.id}
    self.m_model:getNetData("receive_dinner_score", params, receivetCallback)
end


-- 按钮切换
function M:switchTabBtn(index)
    if self.m_model.m_sel_tab_index ~= index then
        self.m_model.m_sel_tab_index = index
        self.m_view:switchNode(index)
    end
end

return M
