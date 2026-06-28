local M = class("NineActiveMainView",LikeOO.OOPopBase)

M.m_uiName = "Activities/NineActiveMain/NineActiveMain"
M.m_size_type = 2

function M:onEnter()
	--local nine_active_parent = UserDataManager.local_data:getLocalDataByKey("nine_active_parent", 0)
	--if nine_active_parent == 0 then
		local nine_active = self:findGameObject("nine_active")
		SDKUtil:SetGameGoParent(nine_active)
		--SDKUtil:SetGameGoParent("nine_active")
		--UserDataManager.local_data:setLocalDataByKey("nine_active_parent", 1)
	--end
	if self.m_model.nine_active_data ~= nil and self.m_model.nine_active_data.activityUrl ~= nil and self.m_model.nine_active_data.inGameId ~= nil then
		SDKUtil:openPage(function(params)
			if params ~= nil and params.data ~= nil then
				UserDataManager.local_data:setLocalDataByKey("windowId",params.data)
			end
		end, self.m_model.nine_active_data.activityUrl,self.m_model.nine_active_data.inGameId)
	end
end



function M:destroy()
	M.super.destroy(self)
end

return M