local M = class("ServiceWorldProgressControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("updateUI", nil, "Xian")
		self:closeView()
	elseif msg == "mask_Img" then
		self:getServerLevel(data)
	elseif msg == "refresh" then --刷新
		self.m_model.m_data.server_level_rcvd = data.server_level_rcvd
		self.m_view:refreshUI();
	end
end

--获取江湖排名信息
function M:getServerLevel(data)
	local function netCallback(response)
		local data = {
			id = data.id,
			current_data = data.cell_data,
			tip_word = data.tip_word,
			server_level = response,
			server_level_rcvd = self.m_model.m_data.server_level_rcvd
		}
		self:openView("Xian.ServiceJiangHuPop", data)
	end
	local params = {
		stage_id = data.cell_data.stage_id
	}
	self.m_model:getNetData("stage_server_level_rank", params,netCallback)
end


return M