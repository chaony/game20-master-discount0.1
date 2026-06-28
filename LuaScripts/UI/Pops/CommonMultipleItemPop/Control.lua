local M = class("CommonMultipleItemPopControl",LikeOO.OOControlBase)

function M:onEnter()
	audio:SendEvtUI("Play_UI_Notice")
	if SceneManager ~= nil and SceneManager.curScene ~= nil then
		
		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(80)
		end
	end
	self:updateTime()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_is_max then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
			return
		end
		if self.m_model.m_costs then
			local costFlag = true -- 需要的材料是否够
			for i, v in pairs(self.m_model.m_costs) do
				local data = RewardUtil:getProcessRewardData(v)
				if data.user_num < data.data_num then
					costFlag = false
				end
			end
			local data = RewardUtil:getProcessRewardData(self.m_model.m_costs)
			if not costFlag then
				--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
				self:closeView()
				QuickOpenFuncUtil:costsTips(data)
				return
			end
		end
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call({isToday = self.m_view.today_callback,cur_server_ts = self.m_view.cur_server_ts,reward_isOk = true})
		end
	    self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_new_cancel_call then
			self.m_model.m_new_cancel_call()
		else
			if self.m_model.m_on_cancel_call then
				self.m_model.m_on_cancel_call()
			end
		end
	    self:closeView()
	elseif msg == "today_btn" then
		self.m_view:todayIsActive()
	elseif msg == "no_btn" then
		if self.m_model.m_on_no_call then
			self.m_model.m_on_ok_call({reward_isOk = false})
		end
	    self:closeView()

    end
end


function M:destroy()
	M.super.destroy(self)
	if SceneManager ~= nil and SceneManager.curScene ~= nil then
		
		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(120)
		end
	end
end

function M:getMaxViewSortOrder()
	local sort_order = M.super.getMaxViewSortOrder(self)
	if static_ghostChildren then
		for kc,vc in pairs(static_ghostChildren) do
			if vc.m_view then
				sort_order = math.max(sort_order, vc.m_view.m_sortOrder)
			end
		end
	end
	return sort_order
end

--更新时间
function M:updateTime()
	self.m_view:updateTime()
end

return M;
