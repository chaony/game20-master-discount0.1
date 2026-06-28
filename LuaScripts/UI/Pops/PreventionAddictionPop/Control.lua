local M = class("PreventionAddictionPopControl",LikeOO.OOControlBase)

function M:onEnter()
	if SceneManager ~= nil and SceneManager.curScene ~= nil then
		
		if SceneManager.curScene.showMove ~= nil then
			SceneManager.curScene.showMove:SetDepth(80)
		end
	end
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
		end
        self:closeView()
    elseif msg == "ok_btn" then
		if self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			if data.user_num < data.data_num then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
				self:closeView()
				return
			end
		end
		if self.m_model.m_on_ok_call then
			self.m_model.m_on_ok_call()
		end
	    self:closeView()
	elseif msg == "cancle_btn" then
		if self.m_model.m_on_cancel_call then
			self.m_model.m_on_cancel_call()
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

return M;
