local M = class("MysticPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "tab_btn" then
        if data ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data)
            self.m_view:AddChildPanel()
        end
    elseif msg == "change_tab" then
        if data.tab_index ~= self.m_model.m_tab_index then
            self.m_model:setTabIndex(data.tab_index)
            if data.evoluation_oid then
                self.m_model:AddMystic(data.evoluation_oid)
            end
            self.m_view:setToggle()
            self.m_view:AddChildPanel()
        end
    elseif msg == "help_btn" then
        local params = {}
        if self.m_model.m_tab_index == 1 then
            params.title = "mystic_str_0003"
            params.content = "tid#mystic_1"
        else
            params.title = "mystic_str_0002"
            params.content = "tid#mystic_2"
        end
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "grid_click" then
        local mystic_data = self.m_model:getUsedMysticDataByIndex(data-1)
        if mystic_data == nil then -- 空的 打开添加
            self:openView("Mystic.MysticSelectPop", {slot_id = data})
        else -- 展示秘籍
            --Logger.log(mystic_data,"mystic_data ====")
            self:openView("Mystic.MysticDetailsPop", {oid = tostring(mystic_data), solt = data, look = 1})
        end
    elseif msg == "put_mystic" then
        self:putMysticRequest(data)
    elseif msg == "remove_solt" then -- 删除已配置的秘籍
        self:removeMysticRequest(data)
    elseif msg == "replace_solt" then -- 替换当前槽位的秘籍
        self:putMysticRequest(data)
    elseif msg == "upgrade_btn" then
        if self.m_model.m_need_count <= 0 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0022"), delay_close = 2})
        elseif self.m_model.m_need_count > #self.m_model.m_select then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("mystic_str_0023"), delay_close = 2})
        else
            --self:openView("Mystic.MysticUpgradePop", self.m_model.m_select)
            local  param = {}
            param[self.m_model.m_select[1]] = {self.m_model.m_select[2], self.m_model.m_select[3]}
            
            local function timeCall()
                self:evolutionMysticRequest(param)
                if self.m_view.m_cur_tab_node then
                    self.m_view.m_cur_tab_node:resetUpgradeAnimation()
                end
                
                self.m_view:unlockTouch()
            end
            self.m_view:lockTouch()
            self:setOnceTimer(2.5,timeCall)
            if self.m_view.m_cur_tab_node then
                self.m_view.m_cur_tab_node:upgradeAnimation()
            end
        end
    elseif msg == "onekey_upgrade_btn" then
        local evolution_type, list = self.m_model:getOneKeyData()
        if evolution_type then
            self:openView("Mystic.MysticSmartPop", {evolution_list = list, evolution_type = evolution_type})
        end
    elseif msg == "select_mystic" then
        local status, slot = self.m_model:AddMystic(data.oid)
        if status == 0 then
            self.m_model.upgrade_anim_slot = slot
            self.m_view:refreshUI()
        elseif status == 1 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0004"), delay_close = 2})
        elseif status == 2 then
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("advanced_str_0007"), delay_close = 2})
        end
    elseif msg == "remove_mystic" then -- 进阶选中删除
        local slot = self.m_model:removeMystic(data.oid)
        self.m_view:refreshUI()
    elseif msg == "evolution" then
        self:evolutionMysticRequest(data.params)
    end
end

function M:removeMysticRequest(data)
    local function putCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
    end
    self.m_model:getNetData("mystic_take_out_mystic", {slot_id = data - 1}, putCallback)
end

function M:putMysticRequest(params)
    if params then
        local function putCallback(response)
            self.m_model.use_anim_slot = params.slot_id + 1
            self.m_model:updateData(response)
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("mystic_put_mystic_in_slot", params, putCallback)
    end
end

function M:evolutionMysticRequest(params)
    -- Logger.log(params,"params ====")
    if params then
        local function evolutionCallback(response)
            if response.reward then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_model:updateData({select_mystic = response.select_mystic, mystic_slots = response.mystic_slots})
            self.m_model:reset()
            self.m_view:refreshUI()
        end
        self.m_model:getNetData("mystic_evolution", {mystic_data = params}, evolutionCallback, false, false, GlobalConfig.POST)
    end
end

return M
