local M = class("MillionairePopView",LikeOO.OOPopBase)

M.m_uiName = "Millionaire/MillionairePop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_material = self:findText("material_node").material
	self.items = self.m_model:getAllItem()
	self:refreshUI()
	self:retreshScroll()
end

function M:refreshUI(keep_offset)
	self:refreshRedPoint()
	for k, v in pairs(self.items) do
		self:setTextByLanKey(v.title_name, v.title_text)
		self:setObjectVisible("tab_up_"..k,k == self.m_model.show_id)
	end
	if keep_offset == nil then
		keep_offset = false
	end
	self:createLoopScroll(keep_offset)
end

function M:refreshRedPoint()
	local items = self.m_model:getAllItem()
	for k, v in pairs(items) do
		self:setObjectVisible(v.red_name, false)
	end
end

--列表信息
function M:createLoopScroll(keep_offset)
	local data = self.m_model:getGiftData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_obj, cell_data)
				self:updateItem(cell_obj, index, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "recall_btn" then
					self:updateMsg("buy", {index = index, cell_data = cell_data})
				end
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data,keep_offset)
	end
end

function M:updateItem(obj, index, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local lock_time = GameUtil:numberToChineseString(index) -- 数字转大写
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_rename_btn_text", Language:getTextByKey("millionaire_text_010",lock_time))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"recall_btn_text", GameUtil:getMoneyTypeNum(data.price))
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"invest_btn_text", "millionaire_text_009")
	local reward_node = luaBehaviour:FindGameObject("reward_node")
	GameUtil:createRewards(reward_node.transform, data.reward, true, true)
	local  recall_btn = luaBehaviour:FindImage("recall_btn")
	if self.m_model.current_time < index then
		recall_btn.material = self.m_gray_material
	else
		recall_btn.material = nil
	end
	local is_buy = self.m_model:isBuy(index,self.m_model.show_id)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour,"recall_btn",is_buy ~= 1)
end

--刷新滑动条位置
function M:retreshScroll()
	self.current_complet = self.m_model:isBuyMinId(self.m_model.show_id) --当前可挑战
	if self.current_complet == 0 then
		self.current_complet = self.m_model.current_time
	end
	if self.m_scroll_view ~= nil then
		self.m_scroll_view:moveToCellIndex(self.current_complet)
	end
end

--刷新活动时间
function M:updateActivityTimer()
	local surplus_time = 0
	local endTimer = self.m_model.m_data.actives[1].end_ts
	local cur_tim = UserDataManager:getServerTime() --服务器时间
	if endTimer ~= nil then
		surplus_time = endTimer - cur_tim
	end
	if surplus_time < 0 or self.m_model.m_data.actives[1].show_start_ts < self.m_model.m_data.actives[1].end_ts then
		if self.m_model.is_show_time == nil then
			self.m_model.is_show_time = true
		end
	else
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
		if self.m_model.day == nil or  remain_day ~= self.m_model.day then
			self.m_model.day = remain_day
			self.m_model.current_time = self.m_model:setCurrentDay()
		end
	end
end

return M