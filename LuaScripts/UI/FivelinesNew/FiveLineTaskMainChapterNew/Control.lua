local M = class("FiveLineTaskMainChapterNewControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "main_reward" then
        self:questRecvSpecial(data)
    end
end



--  特殊任务领奖  quest_type: 任务类型  quest_id: 任务id
function M:questRecvSpecial(data)
    local function netCallback(response)
        if self.m_view then
            self.m_model:initData(response)
            self.m_view:runAnim(response)
            self:updateMsg("battle_end_refresh_ui", nil, "FivelinesNew")
        end
    end
    local params = {quest_id = data.id, vsn = self.m_model.svn}
    self.m_model:getNetData("four_tower_receive_ques", params, netCallback)
end

return M
