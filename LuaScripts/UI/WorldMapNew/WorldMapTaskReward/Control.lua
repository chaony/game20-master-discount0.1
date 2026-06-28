local M = class("WorldMapTaskRewardControl", LikeOO.OOControlBase)

function M:onEnter()
    self.m_view:switchTabNode(self.m_model.m_open_tab_index)
end

function M:onHandle(msg, data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "check_tag" then
        if self.m_model.m_sel_tab_index then
            if self.m_model.m_sel_tab_index ~= data then
                self.m_model.m_sel_tab_index = data
                self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
                self.m_view:switchTabNode(data)
            end
        else
            self.m_model.m_sel_tab_index = data
            self.m_model.m_open_tab_index = self.m_model.m_sel_tab_index
            self.m_view:switchTabNode(data)
        end
    elseif msg == "box_btn" then
        local cpd, status = self.m_model:getMapCpd()
        local rewards = self.m_model:getSenceReward()
        local box_obj = data
        local mark = nil
        if status == 1 then
            -- 领取场景完成度奖励
            local function netCallback(response)
                self.m_view:refreshUI()
                RewardUtil:rewardTipsByData(response.reward)
                if response.update_attrs ~= nil and _G.next(response.update_attrs) then
                    local tips = UserDataManager:checkWorldMemoryAttrUpdate(response.update_attrs)
                    TimeTools:delayTimeUnity(1,
                            function()
                                GameUtil:lookInfoTips(static_rootControl, {msg = tips, delay_close = 2})
                            end)
                end
            end
            local params = {area_id = self.m_model.m_area_id, scene_id = self.m_model.m_scene_id}
            self.m_model:getNetData("new_big_map_receice_scene_cpd", params, netCallback)
        elseif status == 2 then
            mark = 1
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = box_obj.transform, show_check_mark = mark})
        elseif status == 0 then
            self:openView("Pops.LookRewardTips",{rewards = rewards, click_transform = box_obj.transform, show_check_mark = mark})
        end
    elseif msg == "click_btn" then
        local area_id = UserDataManager.local_data:getUserDataByKey("world_memory_area_id",101)
        if self.m_model.m_area_id ~= area_id then
            self:closeView()
            local mapId = self.m_model.m_scene_id
            self:updateMsg("change_scene", {area_id = self.m_model.m_area_id, map_id = mapId}, "WorldMapNew.WorldMemoryMain")
        else
            self:closeView()
        end
    elseif msg == "map_btn" then
        local map_id = data.map_id
        if map_id then
            if LikeOO.NewMap2DControl.curMap2D ~= nil and map_id == LikeOO.NewMap2DControl.curMap2D.map_id then
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("worldMap_str_010"), delay_close = 2})
                return
            end
            self:closeView()
            LikeOO.NewMap2DControl:openMap2D(map_id)
        end
    end
end

return M
