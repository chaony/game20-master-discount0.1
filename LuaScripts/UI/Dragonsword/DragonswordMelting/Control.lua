local M = class("DragonswordMeltingControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "one_melting_btn" then  --熔炼一次
        self:doMelting(1)
    elseif msg == "ten_melting_btn" then  --熔炼十次
        self:doMelting(10)
    elseif msg == "receive_btn_1" then  --里程奖励1
        self:receiveScoreReward(1)
    elseif msg == "receive_btn_2" then  --里程奖励2
        self:receiveScoreReward(2)
    elseif msg == "receive_btn_3" then  --里程奖励3
        self:receiveScoreReward(3)
    elseif msg == "receive_btn_4" then  --里程奖励4
        self:receiveScoreReward(4)
    elseif msg == "receive_btn_5" then  --里程奖励5
        self:receiveScoreReward(5)
    elseif msg == "spar_btn" then  --获取晶石
        if self.m_model:IsOpenQuest() then
            self:openView("Dragonsword.DragonswordQuest",
                    {version = self.m_model.m_version,
                     quests = self.m_model.m_quests,
                     start_time = self.m_model:stringTimeByNumberTime(self.m_model.m_active_data.start_time),
                     current_day = self.m_model.current_open_day})
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
        end
    elseif msg == "refreshQuest" then -- 更新任务数据
        self.m_model:updateQuests(data)
        self.m_view:refreshUI()
    elseif msg == "name_img_btn" then --装备提示展示
        local params = {}
        params.title = "tid#EquipName70001"
        params.content = "tid#EquipDes70001"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "help_btn" then  --帮助
        local params = {}
        params.title = "tid#OpenConditionName_252"
        params.content = "tid#DragonDes_1"
        self:openView("Pops.CommonHelpPop", params)
    end
end

--进行熔炼
function M:doMelting(melting_num)
    if self.m_model:IsOpenQuest() then
        local function netCallback(response)
            RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
            self:updateMsg("refresh_data", nil, "Dragonsword")
            self.m_model:updateServer(response)
            self.m_view:refreshUI()
        end
        local param = {
            vsn = self.m_model.m_version,
            times = melting_num
        }
        self.m_model:getNetData("active_dragonsword_doing_melting",param,netCallback)
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
    end
end

--领取里程奖励
function M:receiveScoreReward(score_id)
    local score_num = self.m_model:getScoreNum(score_id)
    if self.m_model.m_score < score_num then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("dragonsword_text_0012"), delay_close = 2})
    else
        local function netCallback(response)
            RewardUtil:rewardTipsByData(response.reward) --展示已领取奖励
            self:updateMsg("refresh_data", nil, "Dragonsword")
            self.m_model:updateServer(response)
            self.m_view:refreshUI()
        end
        local param = {
            vsn = self.m_model.m_version,
            score_id = score_id
        }
        self.m_model:getNetData("active_dragonsword_recv_score_reward",param,netCallback)
    end
end

return M;
