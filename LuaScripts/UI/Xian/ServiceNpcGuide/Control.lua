local M = class("ServiceNpcGuideControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:updateMsg("updateUI", nil, "Xian")
		self:closeView()
	elseif msg == "get_reward" then
		self:getRewards(data)
	elseif msg == "open_mask" then
		self.m_view:openCheckDes(false)	
	elseif msg == "go_to" then
		local func_id = data[1]
        if func_id then
            local jump = ConfigManager:getCfgByName("jump")
            local jump_item = jump[func_id]
            if jump_item then
                local open_condition_id = jump_item.open_condition_id or 0
                local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
                if open_flag == true then
                    self:updateMsg("common_refresh", nil, "parent") 
                    static_rootControl:closeAllViewPop()
                    local go_type = data or {}
                    QuickOpenFuncUtil:openFunc(go_type)
                else
                    GameUtil:lookInfoTips(self, {msg = tips_str, delay_close = 2}) 
                end
            end
        end
	end
end

function M:getRewards(data)
    local function readCallback(response)
		if response then
			local bl, cfg = self.m_model:getNpcGuideData(response.guide_id)
			if bl == false then
				table.insert(UserDataManager.welfare_npc_guide, response.guide_id)	
			end
            self:updateMsg("updateData", response, "Xian")
            if next(response.reward) then
                RewardUtil:rewardTipsByData(response.reward)
            end
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("receive_guide_reward", {guide_id = data}, readCallback)
end

return M