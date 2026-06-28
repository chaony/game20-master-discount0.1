local M = class("CommonPopControl",LikeOO.OOControlBase)

function M:onEnter()
	audio:SendEvtUI("Play_UI_Notice")
	if SceneManager ~= nil and SceneManager.curScene ~= nil then
		
		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(80)
		end
	end

	self.ok_end_cd = self.m_model.m_params.ok_end_timer

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

		self.ok_end_cd = nil

		if self.m_model.m_is_max then
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("tid#limit_1"), delay_close = 2})
			return
		end
		if self.m_model.m_cost and self.m_model.m_show_cost == nil  then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			if data.user_num < data.data_num then
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
			self.m_model.m_on_no_call({reward_isOk = false})
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

	if self.ok_end_cd then


		self.ok_end_cd = self.ok_end_cd - 1 
		if self.ok_end_cd < 0 then
			self:closeView()
		else
			self.m_view:setTextByLanKey("ok_text", self.m_model.m_ok_text.." ("..self.ok_end_cd+1 ..")") 
		end
	end
end


function M:destroy()
	if self.ok_end_cd ~= nil then
		self.ok_end_cd = nil

		self.m_model.m_on_ok_call()
	end

	
	M.super.destroy(self)
end


return M;
