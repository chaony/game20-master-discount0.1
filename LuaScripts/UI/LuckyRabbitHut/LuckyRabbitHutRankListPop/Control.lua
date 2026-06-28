local M = class("LuckyRabbitHutRankListPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "race" then
		self:switchNode(1)
		self.m_view:refreshUI()
	elseif msg == "type" then
		self:switchNode(2)
		self.m_view:refreshUI()
	elseif msg == "load_rank" then 
		self:requestLoadRank()
	end
end

function M:requestLoadRank()
	local start_pos, end_pos = self.m_model:getLoadIndex()
	if start_pos > 0 then
		local function netCallback(response)
			if self.m_view then
				self.m_mail_load = true
				--self.m_model.type_count[self.m_model.m_race_type][self.m_model.m_type_type] = response.count
				self.m_model:insertRankData(response.ranks)
				self.m_view:refreshUI()
			end
		end
		local params = {}
		params.version = self.m_model.m_version
		params.start = start_pos
		params.stop = end_pos
		local net = "rabbit_rank_info"
		self.m_model:getNetData(net, params, netCallback)
	end
end

function M:destroy()

	M.super.destroy(self)
end


return M