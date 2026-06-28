local M = class("UnionLogView",LikeOO.OOPopBase)

M.m_uiName = "Union/UnionLogPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("common_title_text", "union_str_1049")
	local list_scroll = self:findGameObject("list_scroll")
	self.scroll_rect = list_scroll:GetComponent("LoopListView2")
	self.canvas_group = list_scroll:GetComponent("CanvasGroup")
	self:refreshUI()
	self:initList()
end

function M:refreshUI()

end

function M:initList()
	self.scroll_rect:InitListView(#self.m_model.m_list_data,function(list, index)
		if index < 0 or self.m_model == nil or index>#self.m_model.m_list_data then
			return nil
		end
		local data = self.m_model.m_list_data[index+1]
		local cell
		if data.cell_type == 1 then
			cell = list:NewListViewItem("date_panel")
			local luaBehaviour = cell:GetComponent("LuaBehaviour")
			LuaBehaviourUtil.setText(luaBehaviour, "date_text", data.data)
			LuaBehaviourUtil.setText(luaBehaviour, "time_text", data.time)
		else
			cell = list:NewListViewItem('text_panel')
			local luaBehaviour = cell:GetComponent("LuaBehaviour")
			local guild_log = ConfigManager:getCfgByName("guild_log")
			local log_cfg = guild_log[data.data.id]
			if log_cfg then
				local text = GameUtil:formatTextString(Language:getTextByKey(log_cfg.content), data.data.param, "%H:%M")
				LuaBehaviourUtil.setText(luaBehaviour, "msg_text", text)
			else
				LuaBehaviourUtil.setText(luaBehaviour, "msg_text", "")
			end
			local msg_text = luaBehaviour:FindGameObject("msg_text")
			msg_text.transform:GetComponent('ContentSizeFitter'):SetLayoutVertical();
			--msg_text.transform.parent:GetComponent('ContentSizeFitter'):SetLayoutVertical();

			local y = msg_text:GetComponent('RectTransform').sizeDelta.y
			local other_rt = cell:GetComponent('RectTransform')
			other_rt:SetSizeWithCurrentAnchors(U3DUtil:RectTransform_Axis("ver"), y)
		end
		return cell
	end)
	-- self.scroll_rect:MovePanelToItemIndex(0, 0)
	self:lockTouch()
	self.m_control:setOnceTimer(0.1, function()
		self:unlockTouch()
		self.scroll_rect:RefreshAllShownItem()
		self.canvas_group.alpha = 1
	end)
end

return M