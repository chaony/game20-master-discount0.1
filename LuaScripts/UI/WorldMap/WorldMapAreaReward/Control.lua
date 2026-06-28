local M = class("WorldMapAreaRewardControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "cell_btn" then
        self:openView("WorldMap.WorldMapRegionalTaskReward", {map_id = data.cell_data.id})
    elseif msg == "box_reward_btn" then
        local status = data.cell_data.data.status or 0 -- 0：未完成，1：可领取，2：已领取
        if status == 1 then
            self:bigMapReceiceAreaCpd(data.cell_data)
        elseif status == 0 then
            local rewards = data.cell_data.cfg.item_reward or {}
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = data.click_transform, show_check_mark = status == 2})
        end
    end
end

-- 领取区域完成度奖励  area_id: 1    # 区域id
function M:bigMapReceiceAreaCpd(data)
    local function netCallback(response)
        self.m_view:refreshUI()
        RewardUtil:rewardTipsByData(response.reward)
    end
    local params = {area_id = data.id}
    self.m_model:getNetData("big_map_receice_area_cpd", params, netCallback)
end

return M;
