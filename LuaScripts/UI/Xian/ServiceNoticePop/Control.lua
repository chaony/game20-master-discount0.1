local M = class("ServiceNoticePopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
	if msg == 99999 or msg == "CloseBtn" then    -- 返回
		self:updateMsg("updateUI", nil, "Xian")
		self:closeView()
	elseif msg == "red_notice" then
		self:readNotice(data)	
	elseif msg == "Sliding_right" then
		self.m_model:changeNum(self.m_model.m_notice_index-1)
		self.m_view:refreshUI()
	elseif msg == "Sliding_left" then
		self.m_model:changeNum(self.m_model.m_notice_index+1)
		self.m_view:refreshUI()
	end
end

function M:readNotice(data)
	local function callback(response)
		self:updateMsg("updateOneNotice", data, "Xian")
    end
    local params = {}
    params.notice_id = data
    self.m_model:getNetData("read_notice", params, callback, nil, true)
end


return M