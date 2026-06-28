local M = class("LiteratureGroupSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "join_btn" then
        self:requestJoin()
    end
end

function M:requestJoin()
    local function joinCallback(response)
        local function rewardCallback()
            self:updateMsg("update_data", {msg_source = "literature_group_select"}, "Activities.EnjoySpring")
            self:updateMsg(99999, nil, "Activities.EnjoySpring.LiteratureRank")
            self:updateMsg(99999)
        end
        RewardUtil:rewardTipsByData(response.reward, nil, rewardCallback)
    end
    local params = {}
    params.force_id = self.m_model.m_index
    self.m_model:getNetData("enjoy_spring_add_wenqu", params, joinCallback)
end

return M;
