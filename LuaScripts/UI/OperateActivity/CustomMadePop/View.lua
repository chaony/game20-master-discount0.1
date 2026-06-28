local M = class("CustomMadePopView", LikeOO.OOPopBase)

M.m_uiName = "OperateActivity/CustomMadePop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
	self:setTextByLanKey("common_title_text", self.m_model:getTitleName())
	self:setTextByLanKey("kexuan_text", "kexuan_text")
end

function M:refreshUI()
	local select_rewards = self:findGameObject("select_kuang")
	UIUtil.destroyAllChild(select_rewards.transform)
	local slot = self.m_model:getSlot()
	self.slot_items = {}
	for i = 1, #slot do
		local slot_item = self:creatSlotObj(select_rewards)
		self.slot_items[i] = slot_item
		if not IsNull(slot_item) then
			self:updateSlotItem(slot_item, i)
		end
	end
	self:createLoopScroll()
	self:updateBottomDes()
end

function M:updateSelect()
	for i,v in pairs(self.slot_items) do
		self:updateSlotItem(v, i)
	end
	self:createLoopScroll()
	self:updateBottomDes()
end

function M:updateBottomDes()
	local pos = self.m_model:getItemBySolt(self.m_model.m_select_index)
	if pos ~= 0 then
		self:setObjectVisible("select_des", true)
		local reward_data = self.m_model:getCurRewardByIndex(self.m_model.m_select_index,pos)
		local reward_node = RewardUtil:getProcessRewardData(reward_data)
		self:setTextByLanKey("select_des", reward_node.story)
		self:setTextByLanKey("select_tips", reward_node.name)
		self:setObjectVisible("next_btn", true)
		local positions = self.m_model:getSlot()
		if self.m_model:checkFull() == true then
			self:setTextByLanKey("next_btn_text", "new_str_0006")
		else
			self:setTextByLanKey("next_btn_text", "gf_str_0087")
		end
	else
		--
		self:setTextByLanKey("select_tips", "gf_str_0098")
		self:setObjectVisible("next_btn", false)
		self:setObjectVisible("select_des", false)
	end
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:getCurRewardItems()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
			one_line_count = 3, -- 行或列的数量
			ui_name = self.m_uiName,
			update_cell =function(index, cell_obj, cell_data)
                self:update_Gift(index, cell_obj, cell_data)
            end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if UserDataManager:getCurStage() < cell_data[4] then
					local stage = ConfigManager:getCfgByName("stage")
					local name =  stage[cell_data[4]].map_point_name
					GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0059", Language:getTextByKey(name)), delay_close = 2})
				else
					self:updateMsg("select_reward", index)
				end
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data)
    end 
end

function M:update_Gift(index, cell_obj, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        GameUtil:updateItemElement(cell_obj, cell_data, true, false)
		local pos = self.m_model:getItemBySolt(self.m_model.m_select_index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", pos == index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_image", UserDataManager:getCurStage() < cell_data[4])
    end
end

function M:updateSlotItem(obj, index)
	local select_img = UIUtil.findImage(obj.transform, "select_img")
	local select_img2 = UIUtil.findImage(obj.transform, "select_img2")
	select_img.gameObject:SetActive(false)
	select_img2.gameObject:SetActive(false)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local pos = self.m_model:getItemBySolt(index)
	if pos == 0 then
		GameUtil:updateItemElementNoData(obj,true,false, function ()
			self:updateMsg("select", index)
		end)
	else
		local reward_data = self.m_model:getCurRewardByIndex(index,pos)
		GameUtil:updateItemElement(obj,reward_data,true,false, function ()
			self:updateMsg("select", index)
		end)
	end
	if self.m_model.m_select_index == index then
		select_img.gameObject:SetActive(true)
		select_img2.gameObject:SetActive(true)
	end
	if luaBehaviour then
		
	end
end


function M:creatSlotObj(parent)
	local item = ResourceUtil:LoadUIGameObject("OperateActivity/CustomMade_Item", Vector3.zero, nil)
	item.transform:SetParent(parent.transform, false)
	return item
end

return M