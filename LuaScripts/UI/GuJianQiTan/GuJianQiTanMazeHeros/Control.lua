local M = class("GuJianQiTanMazeHerosControl",LikeOO.OOControlBase)

function M:onEnter()
    
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if SceneManager.curScene.resetClickRoom ~= nil then
            SceneManager.curScene:resetClickRoom();
        end
        self:closeView()
    elseif msg == "use_btn" then
        local cost = ConfigManager:getCommonValueById(47)
        if _G.next(cost) then
            local flag = QuickOpenFuncUtil:hasCostsTips(cost)
            if flag then
                return;
            end
            local cost_data = RewardUtil:getProcessRewardData(cost[1])
            local params = {
                on_ok_call = function(msg)
                    self:updateMsg("maze_revive_all", nil, "MazeStage")
                end,
                on_cancel_call = function(msg)
    
                end,
                no_close_btn = false,
                tow_close_btn = true,
                cost = {cost[1][1], cost[1][2], cost_data.data_num},
                text =  Language:getTextByKey("new_str_0179",cost_data.data_num, cost_data.name),
                title = Language:getTextByKey(cost_data.name)
            }
            self:openView("Pops.CommonPop", params, nil, true)
        end
    elseif msg == "refresh_ui" then
        self.m_maze_data = data.data
        self.m_view:runAnim()
    end
end

function M:destroy()
    M.super.destroy(self)
    
end

return M
