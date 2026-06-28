---@class TaskMainChapterControl:OOControlBase
local M = class("TaskMainChapterControl",LikeOO.OOControlBase)

function M:onEnter()
    audio:SendEvtUI("UI_Gold_Reward")
    if self.m_model.isle_flag then
        self:updateTime()
        self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
    end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
            self.m_model.m_callback(self.m_model.m_roll_data)
        end
        self:closeView()
    elseif msg == "main_reward" then
        if data.cfg.target_type == 104 then
            self:rollQuestRecvSpecial(data)
        else
            self:questRecvSpecial(data)
        end
    elseif msg == "auto_get_btn" then
        self:autoQuestRecvSpecial(data)
    end
end

function M:updateTime()
    self.m_view:updateTime()
end


--  特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
function M:rollQuestRecvSpecial(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
        end
    end
    local params = { quest_id = data.id }
    self.m_model:getNetData("richman_recv_special", params, netCallback)
end


--  特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
function M:questRecvSpecial(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_dot_update"})
        end
    end
    local params = {quest_id = data.id, quest_type = data.cfg.target_type}
    self.m_model:getNetData("quest_recv_special", params, netCallback)
end

function M:autoQuestRecvSpecial(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:refreshUI(response)

            EventDispatcher:dipatchEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {event = "red_dot_update"})
            if response and response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
        end
    end
    local params = {quest_type = self.m_model.m_quest_type}
    self.m_model:getNetData("quest_auto_recv_special", params, netCallback)
end

function M:destroy()
    if self.m_model.isle_flag then
        self:removeTimer(self.m_timer_id)
    end
    M.super.destroy(self)
end

return M
