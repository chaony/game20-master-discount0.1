local M = class("RacconTinShotGiftBagView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconTinShotGiftBag"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "new_str_0732")
	RedPointUtil:saveLocalRedPointFreshTime("voyage_bag_once")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	奖励显示
]]
function M:updateLoopScroll()
	self.m_click_cell_object = nil
	local data = self.m_model:getGiftBagData()
	self:setObjectVisible("CommonTipsNode", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local status = cell_data.status
				if status ~= -1 then
					self:updateMsg(click_name, {index, index, cell_data = cell_data})
					self.m_click_cell_object = cell_object
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end

-- 更新
function M:updateScrollViewCell(index, cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	local cfg = cell_data.cfg
	local status = cell_data.status
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text", cfg.gift_name)
	local time_limit = cfg.time_limit or 0
	local refresh = cfg.refresh or 0 -- 0不限次  1每日刷新 2 每期刷新
	if refresh == 0 then -- 无限制
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"limit_times_text", "new_str_0729")
	else
		if refresh == 1 then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"limit_times_text", "new_str_1025", time_limit - cell_data.buy_times)
		else
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"limit_times_text", "new_str_0796", time_limit - cell_data.buy_times)
		end
	end
	local sort = cfg.sort or 1
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cost_node", sort == 1 and status ~= -1)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn_text", sort == 2 and status ~= -1)
	if sort == 1 then -- 元宝
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"cost_num_text", tostring(cfg.price))
	elseif sort == 2 then -- 充值金额
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"buy_btn_text", GameUtil:getMoneyTypeNum(cfg.price))
	else
		Logger.logError(sort, "ship_gift sort is error ")
	end
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "buy_btn", status ~= -1)
	local drop = cfg.reward or {}
	local reward_node = luaBehaviour:FindRectTransform("reward_node")
	GameUtil:createRewards(reward_node, drop, true, true, nil, 1)
	local task_finish_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"task_finish_text", "new_str_0730")
	task_finish_text.gameObject:SetActive(status == -1)
end

function M:destroy()
	M.super.destroy(self)
end

return M