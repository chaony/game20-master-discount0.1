local M = class("WorldBossMopUpControl",LikeOO.OOControlBase)

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
        --self:openView("Settlement.WorldBossMopUpSettlement", {data = response, boss_id = self.m_model.m_boss_id})
        self:updateMsg("update_data", response, "Activities.WorldBoss")
        self:updateMsg("update_boss_data", response , "Activities.WorldBoss.WorldBossSelectMain")
        --self:updateMsg(99999)
    end
    local params = {}
    self.m_model:getNetData("world_boss_sweep", params, netCallback)
end

return M
