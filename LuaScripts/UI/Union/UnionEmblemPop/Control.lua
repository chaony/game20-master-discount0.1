local M = class("UnionEmblemControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
	    self:closeView()
    elseif msg == "ok_btn" then
    	self:updateMsg("emblem_select", self.m_model.m_select, self.m_model.m_parent)
		self:closeView()
	elseif msg == "cell_btn" then
		local cfg_data = self.m_model.m_list_data[data]
		if self.m_model.m_lv >= cfg_data.unlock_level then
			if data%8 ~= 0  then
				data = data - math.floor(data/8)
			end
			self.m_model:setSelect(data)
			self.m_view:refreshUI()
		else
			local text = string.format(Language:getTextByKey("union_str_1026"), cfg_data.unlock_level)
			GameUtil:lookInfoTips(self, {msg = text, delay_close = 2})
		end
    end
end

return M;
