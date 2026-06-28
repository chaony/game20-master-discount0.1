--- 
local M = class("ItemMulBoxNode",LikeOO.OOUIbase)

M.m_uiName = "Item/ItemMulBoxNode"

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self:setTextByLanKey("box_title_text", "new_str_0497")
	self.m_icon_node = self:findGameObject("icon_node")
end

function M:onButtonClick(obj, name)
	if name == "use_btn" then
		self:useItem()
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	local item_data = UserDataManager.item_data:getItemDataById(self.m_show_data.data_id)
	self.m_show_data.user_num = item_data and item_data.num or 0
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("item_des_text", "new_str_0496")
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self:updateBoxLoopScroll(item_cfg.effect)
end

function M:updateView(data)
	self.m_show_data = data
	self:refreshUI()
end

function M:itemCanAdd()
	local total_num = self:getSelectTotalNum()
	return total_num < self.m_show_data.user_num
end

function M:getSelectTotalNum()
	local total_num = 0
	for _,v in pairs(self.m_item_select_num) do
		total_num = total_num + v
	end
	return total_num
end

--[[
	创建列表
]]
function M:updateBoxLoopScroll(show_data)
	self.m_item_select_num = {}
	self:setTextByLanKey("own_num_text", "0/" .. tostring(self.m_show_data.user_num))
	local data = show_data or {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("box_loopscroll")
		local params = {
			show_data = data,
			one_line_count = 2,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if self.m_item_select_num[index] == nil then
					self.m_item_select_num[index] = 0
				end
				if click_name == "minus_one_btn" then
					self.m_item_select_num[index] = math.max(0, self.m_item_select_num[index] - 1)
				elseif click_name == "add_one_btn" then
					if self:itemCanAdd() then
						self.m_item_select_num[index] = self.m_item_select_num[index] + 1
					end
				end
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "use_num_text", tostring(self.m_item_select_num[index]))
				local select_total_num = self:getSelectTotalNum()
				self:setTextByLanKey("own_num_text", tostring(select_total_num) .. "/" .. tostring(self.m_show_data.user_num))
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local transform = cell_object.transform
	local data = cell_data
	local item_node = UIUtil.findRectTransform(transform,"item_node")
	UIUtil.destroyAllChild(item_node)
	local item = GameUtil:createItemElement(data, true, true)
	item.transform:SetParent(item_node.transform, false)
	local select_num = self.m_item_select_num[index] or 0
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "use_num_text", tostring(select_num))
end

function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "items_update" then
		self:refreshUI()
	end
end

--[[
    
]]
function M:useItem()
	--TODO: 后端还未添加接口
	GameUtil:lookInfoTips(self.m_comtrol, {msg = Language:getTextByKey("NO URL"), delay_close = 2})
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M