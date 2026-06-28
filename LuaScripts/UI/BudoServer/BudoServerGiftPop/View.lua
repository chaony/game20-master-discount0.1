local M = class("BudoServerGiftPopView",LikeOO.OOPopBase)
--成长礼包
M.m_uiName = "BudoServer/BudoServerGiftPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_img = self:findImage("gray_img")
	self:setTextByLanKey("close_title_text", "budoServer_text_0009")
	self.m_end_ts = 0
	self.m_content_panel = self:findGameObject("parent_obj")
	self.gray_img = self:findImage("gray_img")
	self:setTextByLanKey("title_text1", "budoServer_text_0013")
	self:setTextByLanKey("title_text2", "budoServer_text_0014")
	self:setTextByLanKey("gift_btn_text", "budoServer_text_0021")
	self:refreshUI()
end

function M:refreshRedPoint()
	local is_red2 = RedPointUtil:hasRedPointById(24502)
	self:setObjectVisible("gift_red_point", is_red2)
end

function M:refreshUI()
	local gift_list = self.m_model:getGiftsData()
	self:createLoopScroll(gift_list)
	self:updateBoxStatus()
	self:refreshRedPoint()
	--if self.m_scroll_view then
	--	if self.is_update and self.is_update == true then
	--		local pos = self.m_scroll_view:getContentOffset()
	--		if pos then
	--			self.m_scroll_view:setContentOffset(pos)
	--		end
	--	else
	--		for i, v in pairs(gift_list) do
	--			local state, day = self.m_model:getCanGetRewardDay(v)
	--			if state == 1 then
	--				self.m_scroll_view:moveToCellIndex(day)
	--				break
	--			end
	--		end
	--		
	--	end
	--end
end

function M:updateBoxStatus()
	local have_effect = self.m_model:getGiftStatus()
	local gift_btn = self:findGameObject("gift_btn")
	local box_trans = gift_btn.transform
	local box_effect = UIUtil.findRectTransform(gift_btn.transform, "UI_Task_BaoXiang_001")

	if have_effect then
		self:setImg("a_gj_guajijiangli_2", "main_ui2", "gift_btn")
	else
		self:setImg("a_gj_guajijiangli_1", "main_ui2", "gift_btn")
	end
	box_effect.gameObject:SetActive(have_effect)
end


--[[
    创建礼包列表
]]
function M:createLoopScroll(gift_list)
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params ={
			show_data = gift_list,
			loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self:update_Gift(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "free_btn" then
					self:updateMsg("get_free_gift", {id = cell_data.id })
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(gift_list, true)
	end
end

function M:update_Gift(index, cell_obj, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
	if luaBehaviour then
		local free_node = luaBehaviour:FindGameObject("free_items")
		UIUtil.destroyAllChild(free_node.transform)
		GameUtil:createRewards(free_node.transform, cell_data.reward_free, true, true)
		local numStr = GameUtil:numberToChineseString(cell_data.day) -- 数字转大写
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text","budoServer_text_0015", numStr, tostring(cell_data.floor))
		local img_name = "a_yxczlb_btn_bukedianj"
		local clickFlag = false
		local text_name = "new_str_0278"
		local material = nil
		if cell_data.free_received == 2 then -- 0 可领取 1 不可领取 2 已领取
			img_name = "a_ui_currency_btn_small_2"
			clickFlag = false
			text_name = "budoServer_text_0020"
			material = nil
			material = self.m_gray_img.material
		elseif cell_data.free_received == 1 then
			img_name = "a_ui_currency_btn_small_2"
			clickFlag = false
			text_name = "new_str_0057"
			material = self.m_gray_img.material
		elseif cell_data.free_received == 0 then
			img_name = "a_ui_currency_btn_small_2"
			clickFlag = true
			text_name = "new_str_0056"
			material = nil
		end
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "free_btn_text_light", text_name)
		local free_img = LuaBehaviourUtil.setImg(luaBehaviour, "free_btn", img_name, "common_ui")
		if free_img then
			local free_btn = UIUtil.findButton(free_img.transform)
			free_btn.interactable = clickFlag
			free_img.material = material
		end
	end
end

function M:destroy()
	M.super.destroy(self)
end


return M
