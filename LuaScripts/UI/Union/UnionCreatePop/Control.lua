local M = class("UnionCreateControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
	    self:closeView()
    elseif msg == "ok_btn" then
		local name_raw = self.m_view:getNameText()
		local name, flag = string.filterInvalidChars(name_raw)
		if string.utf8len(self.m_view:getNameText()) > 7 then
			self.m_view:resetNameText()
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0006"), delay_close = 2})
			return
		elseif #self.m_view:getNameText() == 0 then
			self.m_view:resetNameText()
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0007"), delay_close = 2})
			return
		elseif flag == false then
			self.m_view:resetNameText()
			GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("union_str_0064"), delay_close = 2})
			return
		end
		
		if not self.m_model.m_is_free and self.m_model.m_cost then
			local data = RewardUtil:getProcessRewardData(self.m_model.m_cost)
			if data.user_num < data.data_num then
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0098", data.name), delay_close = 2})
				self:closeView()
				return
			end
		end
		if self.m_model.m_on_ok_call then
			local params = {}
			params.name = self.m_view:getNameText()
			params.flag = self.m_model.m_emblem
			params.apply_desc = self.m_view:getDesText()
			params.apply = self.m_model.m_apply
			params.apply_lv = self.m_model.m_apply_lv
			self.m_model.m_on_ok_call(params)
		end

		self:closeView()
	elseif msg == "icon_btn" then
		self:openView("Union.UnionEmblemPop", {parent = "Union.UnionCreatePop"})
	elseif msg == "emblem_select" then
		Logger.log(data,"-------- emblem_select")
		self.m_model:setEmblem(data)
		self.m_view:refreshUI()
	elseif msg == "type_left_btn" then
		self.m_model:changeTypeValue(-1)
		self.m_view:refreshUI()
	elseif msg == "type_right_btn" then
		self.m_model:changeTypeValue(1)
		self.m_view:refreshUI()
	elseif msg == "lv_left_btn" then
		self.m_model:changeLevelValue(-5)
		self.m_view:refreshUI()
	elseif msg == "lv_right_btn" then
		self.m_model:changeLevelValue(5)
		self.m_view:refreshUI()
    end
end

return M;
