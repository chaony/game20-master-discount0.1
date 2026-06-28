local M = class("MonthChargePopView",LikeOO.OOPopBase)

M.m_uiName = "GiftBag/MonthChargePop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_hero_obj = self:findGameObject("hero_spine")
	self.m_hero_skin_cfg = ConfigManager:getCfgByName("hero_skin")
	self:setTextByLanKey("close_title_text", "month_charge_text_0001")
	self:updateCommonAttrNodes()
	self:updateHeroSpine()
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

-- 滑动列表
function M:updateLoopScroll()
	local data = self.m_model:getGiftBagData()
	if self.m_loop_scroll_view == nil then
		local loopScroll = self:findGameObject("loop_scroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopScroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if cell_data.status ~= -1 then
					self:updateMsg(click_name, {index, index, cell_data = cell_data})	
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

-- 礼包单元
function M:updateCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local id = cell_data.id
	local cfg = cell_data.cfg
	local status = cell_data.status  -- status：-1已购买，0未达成，1可购买
	local buy_count = status == -1 and 1 or 0
	local price_str = GameUtil:getMoneyTypeNum(cfg.price)
	
	-- 按钮状态
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "price_text", status == 1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "not_yet_text", status == 0)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bought_text", status == -1)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"price_text", price_str)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"limit_text", buy_count .. "/1")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"title_text", "month_charge_text_0003", id)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"bought_text", "month_charge_text_0004")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"not_yet_text", "month_charge_text_0005")
	
	-- 礼包内容
	local rewards = cfg.reward or {}
	local reward_node = luaBehaviour:FindRectTransform("item_parent")
	local items = GameUtil:createRewards(reward_node, rewards, true, true)
	for _, v in pairs(items) do
		local visible = status == -1
		local item_luaBehaviour = UIUtil.findLuaBehaviour(v)
		LuaBehaviourUtil.setObjectVisible(item_luaBehaviour, "duigoudi_img", visible)
	end
end

-- 公共资源
function M:updateCommonAttrNodes()
	local attr_mode = self.m_model:isToken() and 20 or 1
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
end

-- 英雄 Spine
function M:updateHeroSpine()
	local skin_id = self.m_model:getHeroSkinID()
	local hero_cfg = self.m_hero_skin_cfg[skin_id]
	local spine_name = "RoleSpine/" .. hero_cfg.hero_spine
	GameUtil:updateSpineLoadSet(self.m_hero_obj, spine_name, "idle", 0, true)
end

-- 活动剩余时间
function M:updateActivityTimer(left_ts)
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(left_ts)
	local time_str
	if remain_day >= 1 then
		time_str = string.format("%d天", remain_day)
	elseif remain_hour >= 1 then
		time_str = string.format("%d小时", remain_hour)
	elseif remain_min >= 1 then
		time_str = string.format("%d分钟", remain_min)
	else
		time_str = string.format("%d秒", remain_sec)
	end
	local format_time_str = Language:getTextByKey("month_charge_text_0002", time_str)
	self:setText("time_text", format_time_str)
end

function M:destroy()
	if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
	M.super.destroy(self)
end

return M