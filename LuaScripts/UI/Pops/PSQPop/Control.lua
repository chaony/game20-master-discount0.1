local M = class("PSQPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "CloseBtn" then    -- 返回
        self:closeView()
    elseif msg == "started_btn" then
        self:qStart()
    elseif msg == "send_btn" then
        self:doQuestion()
    end
end

function M:qStart()
    local function callfunc(data)
        self.m_model:refreshData(data)
        self.m_model.is_open = true
        self.m_view:refreshUI()
	end
    self.m_model:getNetData("question_start", nil, callfunc)
end

function M:doQuestion()
    local function callfunc(data)
        if data.next_qid == 0 then
            UserDataManager.questions = {}
            self:updateMsg("common_refresh", nil, "parent")
            self:updateMsg(99999)
            if next(data.reward) ~= nil then
                RewardUtil:rewardTipsByData(data.reward)
            end  
        else
            self.m_model:refreshNextData(data)
            self.m_view:refreshUI()
        end
    end
    local m_quest =self.m_model:getQuestion()
    local answer = nil
    if m_quest.sort == 1 then
        answer = {self.m_model.m_select_id}
    elseif m_quest.sort == 2 then
        answer = self.m_model.m_select_ids
    elseif m_quest.sort == 3 then 
        if #self.m_view:getInputCount() <= 0 then
            answer = {} 
        else
            answer = {self.m_view:getInputCount()} 
        end
    end   
    local params = {
        version = self.m_model.version,
        qid = self.m_model.m_qid,
        answer = answer
    }
    self.m_model:getNetData("question_do", params, callfunc, false, false, GlobalConfig.POST )
end

return M;
