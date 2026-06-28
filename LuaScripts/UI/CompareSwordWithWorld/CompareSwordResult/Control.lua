local M = class("CompareSwordResultControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "btn_history" then
		self:openView("CompareSwordWithWorld.CompareSwordResultHistory",{active = self.m_model.m_all_actives_cfg})
	elseif msg == "btn_rank" then
		self:openView("CompareSwordWithWorld.CompareSwordResultRankList",{raceType = 3}) --self.m_model.m_pharse
	elseif msg == "look_player" then
		local index = tonumber(data[1])
		local top_data = self.m_model:getTopData()
		local select_data = top_data[index]
		if select_data and next(select_data) then
			local uid = select_data.uid
			if select_data.uid then
				self:openView("Pops.PlayerInfo", {uid = uid})
			end
		end
	elseif msg == "refresh_version" then
		if data.version and data.version ~= self.m_model.m_version then
			self.m_model.m_version = data.version
			self.m_model:getDataByVersion(handler(self,self.refreshUI))
		end
	end
end

function M:refreshUI()
	self.m_view:refreshUI()
end

function M:destroy()
	M.super.destroy(self)
end


return M