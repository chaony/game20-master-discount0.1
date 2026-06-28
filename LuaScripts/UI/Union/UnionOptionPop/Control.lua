local M = class("UnionOptionControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
	elseif msg == "icon_btn" then
		self:openView("Union.UnionEmblemPop", {parent = "Union.UnionOptionPop", guild = self.m_model.m_data})
	elseif msg == "emblem_select" then
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
		if self.m_view:getNameText() == self.m_model.m_data.name then
			self:requestSetting()
		else
			local cost = ConfigManager:getCfgByName("system_cost")[7].cost[1]
	    	local params =
	        {
	            on_ok_call = function(msg)
	                self:requestSetting()
	            end,
	            no_close_btn = false,
	            cost = cost,
	            text = string.format(Language:getTextByKey("union_str_1042"), cost[3])
	        }
	        static_rootControl:openView("Pops.CommonPop", params)
	    end
    end
end

function M:requestSetting()
	local function setCallback(response)
		self:updateMsg("update_data", response, "Union.UnionMain")
		self:updateMsg("update_data", response, "Union.UnionHall")
        self:closeView()
    end
    local params = {}
	if self.m_model.m_data.name ~= self.m_view:getNameText() then
		params.name = self.m_view:getNameText()
	end
    params.flag = self.m_model.m_data.flag
    params.apply_desc = self.m_view:getDesText()
    params.apply = self.m_model.m_data.apply
    params.apply_lv = self.m_model.m_data.apply_lv
    self.m_model:getNetData("guild_edit_guild", params, setCallback, nil, nil, GlobalConfig.POST)
end

return M;
