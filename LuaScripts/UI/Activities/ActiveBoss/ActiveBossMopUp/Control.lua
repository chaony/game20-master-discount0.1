local M = class("ActiveBossMopUpControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 or msg == "cancle_btn" then
        self:closeView()
    elseif msg == "ok_btn" then
        self:worldBossSweep()
    end
end

-- 扫荡
function M:worldBossSweep()
    local function netCallback(response)
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
        self:updateMsg("update_data", response, "Activities.ActiveBoss")
    end
    local params = {}
    params.open_id = self.m_model.m_open_id
    params.vsn = self.m_model.m_version
    self.m_model:getNetData("common_world_boss_sweep", params, netCallback)
end

return M
