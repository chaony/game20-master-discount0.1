local M = class("FriendApplayPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/FriendApplyPop"
M.m_size_type = 2

local __TAB_BTN_NODE = { "apply_toggle","add_toggle","black_toggle", }
local __TAB_BTN_TEXT = { "apply_toggle_text","add_toggle_text","black_toggle_text", }
function M:onEnter()
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data)
				self:setTextColor(__TAB_BTN_TEXT[data], GlobalConfig.COMMON_COLLOR.COMMON_25)
			else
				self:setTextColor(__TAB_BTN_TEXT[data], GlobalConfig.COMMON_COLLOR.COMMON_24)
			end 
		end, i, self.m_uiName)
	end
	self.find_input = self:findInputField("find_input")
	UIUtil.addInputFieldListener(self:findGameObject("find_input").transform, handler(self,self.inputChanged))
	self.find_btn = self:findButton("find_btn")
	self.find_panel = self:findGameObject("find_panel")
	self.apply_btn_panel = self:findGameObject("apply_btn_panel")
	self.have_panel = self:findGameObject("have_panel")
	self.list_scroll = self:findGameObject("list_scroll")

	UIUtil.setTextByLanKey(self:findGameObject("apply_toggle").transform, "Label", "friend_str_0016")
	UIUtil.setTextByLanKey(self:findGameObject("add_toggle").transform, "Label", "friend_str_0017")
	UIUtil.setTextByLanKey(self:findGameObject("black_toggle").transform, "Label", "friend_str_0018")
	self:refreshUI()
end

function M:refreshUI()
	self.find_panel:SetActive(self.m_model.m_tab_index == 2)
	self.apply_btn_panel:SetActive(self.m_model.m_tab_index == 1)
	self:setObjectVisible("apply_text", self.m_model.m_tab_index == 1)
	self:setObjectVisible("apply_num_text", self.m_model.m_tab_index == 1)
	local content_rect = self.have_panel.transform.parent.rect
	local scroll_rect = self.list_scroll:GetComponent("RectTransform")
	if self.m_model.m_tab_index == 2 then
		scroll_rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("top"), 164,355)
		self:setText("have_text", Language:getTextByKey("friend_str_0003") .. self.m_model.m_friend_num .. "/" .. ConfigManager:getCommonValueById(39))
		self:setText("common_title_text", Language:getTextByKey("friend_str_0017"))
	else
		if self.m_model.m_tab_index == 3 then
			self:setText("have_text", Language:getTextByKey("friend_str_0009") .. self.m_model:getListNum())
			self:setText("common_title_text", Language:getTextByKey("friend_str_0018"))
			scroll_rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("top"), 94,415)
		else
			self:setText("have_text", Language:getTextByKey("friend_str_0003") .. self.m_model.m_friend_num .. "/" .. ConfigManager:getCommonValueById(39))
			self:setText("apply_num_text", tostring(self.m_model.m_apply_msg_num) .. "/" ..  ConfigManager:getCommonValueById(41))
			self:setText("apply_text", Language:getTextByKey("friend_str_0011"))
			self:setText("common_title_text", Language:getTextByKey("friend_str_0016"))
			scroll_rect:SetInsetAndSizeFromParentEdge(U3DUtil:RectTransform_Edge("top"), 94,362)
		end
	end

	self:updateListScroll()
end

function M:updateListScroll()
    local num,data = self.m_model:getListNum()
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:cellBtnHandle(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:setCellHander(obj, id)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = self.m_model:getDataByIndex(id)
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 1})
    UIUtil.setObjectVisible(obj.transform, self.m_model.m_tab_index ~= 1, "remove_black_btn")
    UIUtil.setObjectVisible(obj.transform, self.m_model.m_tab_index == 1, "add_btn")
    UIUtil.setObjectVisible(obj.transform, self.m_model.m_tab_index == 1, "remove_btn")
    UIUtil.setText(obj.transform, data.full_combat, "power_text")
    UIUtil.setText(obj.transform, Language:getTextByKey(data.name), "name_text")
    -- UIUtil.setText(obj.transform, data.level, "playerNode/lv_text")
    if self.m_model.m_tab_index == 1 then 

	elseif self.m_model.m_tab_index == 2 then 
		if data.is_applied == 0 then
			UIUtil.setTextByLanKey(obj.transform, "remove_black_btn/remove_black_btn_text", "friend_str_0012")
			UIUtil.findButton(obj.transform,"remove_black_btn").interactable = true
		else
			UIUtil.setTextByLanKey(obj.transform, "remove_black_btn/remove_black_btn_text", "friend_str_0013")
			UIUtil.findButton(obj.transform,"remove_black_btn").interactable = false
		end
	elseif self.m_model.m_tab_index == 3 then 
		UIUtil.setTextByLanKey(obj.transform, "remove_black_btn/remove_black_btn_text", "friend_str_0014")
		UIUtil.findButton(obj.transform,"remove_black_btn").interactable = true
	end
end

function M:cellBtnHandle(name, itag)
    if name == "remove_black_btn" then
    	if self.m_model.m_tab_index == 2 then
    		self:updateMsg("send_apply_friend", itag)
		elseif self.m_model.m_tab_index == 3 then
			self:updateMsg("remove_black", itag)
		end
	elseif name == "add_btn" then
		self:updateMsg("add_btn", itag)
	elseif name == "remove_btn" then
		self:updateMsg("remove_btn", itag)
    end
end

function M:getSearchText()
	return self.find_input.text
end

function M:setSearchText(text)
	self.find_input.text = tostring(text)
end

function M:inputChanged()
	local name = self:getSearchText()
	if name and name ~= "" then
		self.find_btn.interactable = true
	else
		self.find_btn.interactable = false
	end
end

return M