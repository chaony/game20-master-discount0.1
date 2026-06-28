local M = class("WorldMapRegionalTaskRewardControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "box_reward_btn" then
        local status = data.cell_data.data.status or 0 -- 0：未完成，1：可领取，2：已领取
        if status == 1 then
            self:bigMapReceiceSceneCpd(data.cell_data)
        elseif status == 0 then
            local rewards = data.cell_data.cfg.item_reward or {}
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = status == 2})
        end
    end
end

-- 领取场景完成度奖励  area_id: 1    # 区域id   scene_id: 1   # 场景id
function M:bigMapReceiceSceneCpd(data)
    local function netCallback(response)
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {area_id = self.m_model.m_map_id, scene_id = data.id}
    self.m_model:getNetData("big_map_receice_scene_cpd", params, netCallback)
end

return M;
