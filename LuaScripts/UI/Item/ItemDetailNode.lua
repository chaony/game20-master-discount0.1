---@class ItemDetailNode:OOUIbase
local M = class("ItemDetailNode",LikeOO.OOUIbase)

M.m_uiName = "Item/ItemDetailNode"

function M:onEnter()
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self.m_gray_image = self:findImage("gray_image")
	self.m_gain_node = self:findGameObject("gain_node")
	self.m_gain_nodes = self:findGameObject("gain_nodes")
	self.m_icon_node = self:findGameObject("icon_node")
	self:setTextByLanKey("max_btn_text", "new_str_0643")
	self.find_input = self:findInputField("user_input_field")
	UIUtil.addInputFieldListener(self:findGameObject("user_input_field").transform, handler(self,self.inputChanged))
end

function M:onButtonClick(obj, name)
	if name == "minus_ten_btn" then
		self:addUseNum(-10)
		self:updateUseNum()
	elseif name == "minus_one_btn" then
		self:addUseNum(-1)
		self:updateUseNum()
	elseif name == "add_one_btn" then
		self:addUseNum(1)
		self:updateUseNum()
	elseif name == "max_btn" then
		self:addUseNum(self:getMaxNum())
		self:updateUseNum()
	elseif name == "use_btn" then
		self:useItem()
	elseif name == "send_btn" then
		self:sendFetterItem()
	end
	local full_btn_name = self.m_uiName .. "/" .. name
	GameUtil:playBtnSound(full_btn_name)
end

function M:refreshUI()
	if self.m_show_data == nil then
		return
	end
	local item_data = UserDataManager.item_data:getItemDataById(self.m_show_data.data_id)
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg

	self.m_show_data.user_num = item_data and item_data.num or 0
	local use_all = item_cfg.use_all and item_cfg.use_all or 0
	if use_all == 1 then
		self.m_use_num = self:getMaxNum()
	else
		self.m_use_num = math.min(self:getMaxNum(),1)
	end
	self:setTextByLanKey("common_title_text", show_data.name)
	self:setTextByLanKey("item_des_text", show_data.story)
	local text_scroll = self:findImage("item_des_scroll")
	local strCount = string.utf8len(show_data.story)
	text_scroll.raycastTarget = strCount > 300

	self:setTextByLanKey("use_btn_text", item_cfg.sort == 2 and "new_str_0049" or "new_str_0048")
	self:setTextByLanKey("grey_use_btn_text", item_cfg.sort == 2 and "new_str_0049" or "new_str_0048")
	GameUtil:createItemElementByData(show_data, false, false, nil, self.m_icon_node.transform)
	self.m_need_num_slider = self:findSlider("need_num_slider")
	self.m_user_num_slider = self:findSlider("user_num_slider")
	self:updateUseNum()
	self:updateLoopScroll()
end

function M:updateView(data)
	self.m_show_data = data
	self:refreshUI()
end

function M:addUseNum(value)
	local new_count = self.m_use_num + value
	self.m_use_num = math.min(math.max(1,new_count),self:getMaxNum())
end

function M:getMaxNum()
	local max_num = self.m_show_data.user_num
	local item_cfg = self.m_show_data.item_cfg or {}
	if item_cfg.can_use and item_cfg.can_use == 1 and item_cfg.max_limit and item_cfg.max_limit > 0 then
		self.m_use_max = item_cfg.max_limit or 99
	end
	if item_cfg.type == GlobalConfig.ITEM_TYPE.DOUBLE_RECHARGE_VOLUME then --双倍充值券
		local item_id = self.m_show_data.data_id
		local item_data = UserDataManager.item_data:getItemDataById(item_id)
		max_num = math.floor(item_data.value/item_cfg.effect)
	else
		if item_cfg.use_num and item_cfg.use_num > 0 then
			max_num = math.floor(max_num/item_cfg.use_num)
		end
	end
	if self.m_use_max and max_num >=self.m_use_max then
		max_num = self.m_use_max
	end
	return max_num
end

function M:getUseNum()
	return self.m_use_num
end

function M:updateUseNum()
	self:setObjectVisible("use_red_point_img", false)
	self:setObjectVisible("user_num_slider", false)
	
	local use_max = self:getMaxNum()
	local use_num = self:getUseNum()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local cfg_use_num = item_cfg.use_num
	self:setTextByLanKey("own_num_text", "new_str_0430", tostring(show_data.user_num))
	self:setSearchText(use_num)
	--local use_num_text = self:setTextByLanKey("use_num_text", "new_str_0050", use_num, use_max)
	
	self:setObjectVisible("use_node", item_cfg.can_use == 1)
	if item_cfg.can_use == 1 then
		self:setObjectVisible("use_node", item_cfg.use_multi == 0)
	end
	self:setObjectVisible("use_btn", item_cfg.can_use == 1)
	--self:setObjectVisible("need_num_node", item_cfg.can_use == 1 and cfg_use_num > 1)
	--if cfg_use_num > 0 then
	--	self:setTextByLanKey("need_num_text", "new_str_0053", show_data.user_num, cfg_use_num)
	--	self.m_need_num_slider.value = show_data.user_num/cfg_use_num
	--end
	if item_cfg.sort == 2 then --碎片
		self:setObjectVisible("use_red_point_img", show_data.user_num >= cfg_use_num)
		self:setTextColor("use_num_text",use_num > 0 and GlobalConfig.COMMON_COLLOR.COMMON_14 or GlobalConfig.COMMON_COLLOR.COMMON_11)
	end
	if item_cfg.type == 12 then --双倍充值券
		self:setObjectVisible("user_num_slider", true)
		local item_data = UserDataManager.item_data:getItemDataById(show_data.data_id)
		self:setTextByLanKey("user_num_text", "new_str_0053", item_data.value, item_cfg.effect)
		self.m_user_num_slider.value = item_data.value/item_cfg.effect
	end
	local item_type = item_cfg.type
	UIUtil.destroyAllChild(self.m_gain_nodes.transform)
	if item_type == 4 or item_type == 5 or item_type == 6 or item_type == 7 then
		local reward = GameUtil:getHangUpReward(item_cfg, use_num)
		if #reward > 0 then
			--self.m_gain_nodes:SetActive(true)
			--for i,v in ipairs(reward) do
			--	local obj = GameUtil:instanceObject(self.m_gain_node, self.m_gain_nodes.transform)
			--	obj:SetActive(true)
			--	local data = RewardUtil:getProcessRewardData(v)
			--	local text,unit  = GameUtil:formatValueToString(data.data_num)
			--	local gain_num_text = UIUtil.setTextByLanKey(obj.transform, "gain_num_text", text)
			--	UIUtil.setImg(obj.transform, data.icon_name, "item_icon" ,"gain_img") --装备Icon
			--end
		--else
		--	self.m_gain_nodes:SetActive(false)
		end
	--else
	--	self.m_gain_nodes:SetActive(false)
	end
	local level = UserDataManager.user_data:getUserStatusDataByKey("level") or 1
	local player_lv = item_cfg.player_lv or 1
	local use_btn_img = self:findImage("use_btn")
	local use_btn = self:findButton("use_btn")
	if level < player_lv then -- 未解锁
		self:setTextByLanKey("unlock_text", "new_str_0350", player_lv)
		use_btn_img.material = self.m_gray_image.material
		use_btn.enabled = false
		self:setObjectVisible("grey_use_btn_text", true)
		self:setObjectVisible("use_btn_text", false)
	else
		use_btn_img.material = nil
		use_btn.enabled = true
		self:setObjectVisible("grey_use_btn_text", false)
		self:setObjectVisible("use_btn_text", true)
	end
	self:setObjectVisible("unlock_text", level < player_lv)
	if item_cfg.sort == 5 then --英雄友情道具
		self:updateFetterUI()
		self:setObjectVisible("fetter_item", true)
	else
		self:setObjectVisible("fetter_item", false)	
	end
end

function M:updateFetterUI()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local sub_type_name = Language:getTextByKey('tid#haoganleixingname_'..item_cfg.sub_type)
	local str = Language:getTextByKey("hero_ui_str_0038", sub_type_name)
	local min_num, change_lv = self:getMinLv(item_cfg)
	str = str.."\n"..Language:getTextByKey("hero_ui_str_0039", min_num)
	self:setTextByLanKey("fetter_item_des_text", str)
	self:setTextByLanKey("fetter_hero_tips", "hero_ui_str_0040")
	self:updateHeroLoopScroll()
end

function M:getMinLv(item_cfg)
	local tab = {}
	for k,v in pairs(item_cfg.effect) do
		table.insert(tab, {lv = v[1], num =v[2]})
	end
	local init_num = tab[1].num or 0
	table.sort(tab, function(data1, data2)
		return data1.lv < data2.lv
	end)
	for i = 1, #tab do
		if tab[i].num < init_num then
			return init_num, i
		end
	end
	return init_num, 0
end

function M:getFetterHeros()
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local new_hero_tab = {}
	local se_id = UserDataManager:getCurSeason()
	for k,v in pairs(hero_detail) do
		if k < 1000 then --四位数的事特殊的、不是英雄id
			if se_id >= v.season and v.favorite_gift then
				for kk,vv in pairs(v.favorite_gift) do
					if vv == item_cfg.sub_type then
						table.insert(new_hero_tab, k)
					end
				end
			end
		end
	end
	return new_hero_tab
end

function M:getFetterHerosForSeason(hero_data)
	local new_hero_tab = {}
	local cur_season = UserDataManager:getCurSeason()
	local cur_season_day = UserDataManager:getCurSeasonDay()
	local cfg_season
	local cfg_season_day
	local hero_item
	for k, v in pairs(hero_data) do
		hero_item = RewardUtil:getProcessRewardData(v)
		cfg_season = hero_item.item_cfg.season
		cfg_season_day = hero_item.item_cfg.season_day or 0
		if (cfg_season < cur_season) or (cfg_season == cur_season and ((cfg_season_day == 0) or (cfg_season_day ~= 0 and cfg_season_day <= cur_season_day))) then
			table.insert(new_hero_tab, v)
		end
	end
	return new_hero_tab
end

--前往赠送好感道具
function M:sendFetterItem()
	local data = self:getFetterHeros()
	local open_fetter = {}
	local hers_tab = UserDataManager.hero_data:getHerosData()
	local fetter_lock_queate = ConfigManager:getCommonValueById(465,3)
	local new_sort_tab = {} --计算品阶
	local new_sort_tab2 = {} --不计算品阶
	for i,v in pairs(hers_tab) do
		if v.evo >= fetter_lock_queate then
			if self:checkInTab(v.id, data) == true then
				table.insert(new_sort_tab, v.oid)
			end
		else
			if self:checkInTab(v.id, data) == true then
				table.insert(new_sort_tab2, v.oid)
			end
		end
	end
	self:heroIdsSort(new_sort_tab)
	if next(new_sort_tab) ~= nil then
		self:openView("HeroBag", {mode = 1, select_oid = new_sort_tab[1]})
		self:updateMsg(99999)
		return
	end
	if next(new_sort_tab2) ~= nil then
		local farm_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[fetter_lock_queate]
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_8",Language:getTextByKey(farm_data.name) ), delay_close = 2})
	else
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("tid#haogandutips_7"), delay_close = 2})
	end
end

function M:heroIdsSort(ids)
	-- t0 1级以上
	-- t1 好感未衰减
	-- t2 好感等级从高到低
    local function sortFunc(id_one, id_two)
		local data1, cfg1 = UserDataManager.hero_data:getHeroDataById(id_one)
		local data2, cfg2 = UserDataManager.hero_data:getHeroDataById(id_two)
		local friend_data_1 = UserDataManager.m_friendliness[tostring(cfg1.id)] or {point=0,lv=0} 
		local friend_data_2 = UserDataManager.m_friendliness[tostring(cfg2.id)] or {point=0,lv=0} 
		local hero_lv_1 = data1.clv > 0 and data1.clv or data1.lv
		local hero_lv_2 = data2.clv > 0 and data2.clv or data2.lv
		local friend_lv_1 = hero_lv_1 > 1 and 1 or 0
		local friend_lv_2 = hero_lv_2 > 1 and 1 or 0
		local dam_1 = self:checkDamping(friend_data_1.lv)
		local dam_2 = self:checkDamping(friend_data_2.lv)
		if friend_lv_1 == friend_lv_2 then 
			if dam_1 == dam_2 then 
				if data1.evo == data2.evo then 
					return friend_data_1.lv > friend_data_2.lv
				else
					return data1.evo > data2.evo
				end
			else
				return dam_1 > dam_2
			end
		else
			return friend_lv_1 > friend_lv_2
		end
    end
    table.sort(ids, sortFunc)
end

--检测是否衰减
function M:checkDamping(c_lv)
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local tab = {}
	local cur_num = 0
	for k,v in pairs(item_cfg.effect) do
		table.insert(tab, {lv = v[1], num =v[2]})
	end
	local init_num = tab[1].num or 0
	table.sort(tab, function(data1, data2)
		return data1.lv < data2.lv
	end)
	for i = 1, #tab do
		if tab[i].lv == c_lv then
			cur_num = tab[i].num
			break
		end
	end
	if init_num > cur_num then
		return 0
	else
		return 1	
	end
end

function M:checkInTab(id, tab)
	for i,v in pairs(tab) do
		if v == id then
			return true
		end
	end
	return false
end


function M:dataUpdateEvent(event, data)
	local curEvent = data.event
	if curEvent == "items_update" then
		self:refreshUI()
	end
end

--[[
    item_id: 道具id item_num: 道具数量
]]
function M:useItem()
	local item_num = self:getUseNum()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg
	local item_id = self.m_show_data.data_id
	if item_num > self.m_show_data.user_num then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1054"), delay_close = 2})
		return
	end
	if item_num < 1 then
		if item_cfg.type == GlobalConfig.ITEM_TYPE.DOUBLE_RECHARGE_VOLUME then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_0442"), delay_close = 2})
		else
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey(item_cfg.sort == 2 and "new_str_0051" or "new_str_0052"), delay_close = 2})
		end
		return
	else
		if item_cfg.type == GlobalConfig.ITEM_TYPE.RACE_HERO then -- 4选1紫色卡
			self.m_control:openView("Pub.MartialGachaPop", {item_id = item_id})
			return
		elseif	item_cfg.type == GlobalConfig.ITEM_TYPE.ONE_BOX or item_cfg.type == GlobalConfig.ITEM_TYPE.MUL_BOX then 
			--self.m_control:openView("Item.ItemBox", {show_data = show_data, use_num = item_num})
			if self:isHeroReward(item_cfg) == true then
				self:openView("Item.HeroBox", {show_data = show_data, use_num = item_num})
			else
				self:openView("Item.ItemBox", {show_data = show_data, use_num = item_num})
			end
			return
		elseif item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_CHANGE_HERO then
			self:openView("Pub.SeasonChangeHeroPop", {show_data = show_data, use_num = item_num})
			return
		elseif item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
			if self:isHeroReward(item_cfg, true, show_data.item_effect) == true then
				self:openView("Item.HeroBox", {show_data = show_data, use_num = item_num})
			else
				self:openView("Item.ItemBox", {show_data = show_data, use_num = item_num})
			end
			return
		end
	end

	local function netCallback(response)
		if response.reward and response.reward.emoji and table.nums(response.reward.emoji) > 0 then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("new_str_1042"), delay_close = 2})
		else
			RewardUtil:rewardTipsByData(response.reward)
		end
	end
	local params = {item_id = item_id, item_num = item_num or 1}
	self.m_model:getNetData("item_use_item", params, netCallback)
end

function M:isHeroReward(item_cfg, isHeroSextCount, item_effect)
	local effect = item_cfg.effect or {}
	if item_cfg.type == 20 then
		effect = item_effect or {}
	end
	local flag = true
	for k,v in pairs(effect) do
		if v[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS and v[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			if isHeroSextCount and v[1] == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
				goto continue
			end
			flag = false
			break
			::continue::
		end
	end
	return flag
end

function M:getShowRewardData()
	local item_cfg = self.m_show_data.item_cfg
	local id = self.m_show_data.data_id
	local data = nil
	if item_cfg.type == GlobalConfig.ITEM_TYPE.ONE_BOX or item_cfg.type == GlobalConfig.ITEM_TYPE.MUL_BOX then
		data = item_cfg.effect
	elseif item_cfg.type == GlobalConfig.ITEM_TYPE.CHEST then
		data = {}
		local force_show_item_list = ConfigManager:getCommonValueById(785)
		if force_show_item_list and type(force_show_item_list) == "table" and next(force_show_item_list) then
			for k,v in ipairs(force_show_item_list) do
				if tostring(v) == id then
					data = item_cfg.effect
					return data or {}
				end
			end
		end
		local random_chest = ConfigManager:getCfgByName("random_chest") or {}
		local effect = item_cfg.effect or {}
		local cur_stage = UserDataManager:getCurStage()
		for i, v in ipairs(effect) do
			if v[1] == 201 then
				local random_chest_item = random_chest[v[2]]
				if random_chest_item then
					local sort = random_chest_item.sort
					local configs = random_chest_item.configs or {}
					if sort == 0 then -- 所有的随机
						for idx, item in ipairs(configs) do
							local rewards = item.rewards or {}
							table.insertto(data, rewards)
						end
					elseif sort == 1 then -- 关卡限制
						for idx, item in ipairs(configs) do
							local param = item.params or 0
							if cur_stage >= param then
								local rewards = item.rewards or {}
								table.insertto(data, rewards)
							end
						end
					elseif sort == 2 then -- 赛季展示
						local index, season = self:getCurSeasonRewardIndex(configs)
						if configs[index] and configs[index].rewards then
							table.insertto(data, configs[index].rewards)
						end
					end
				end
			end
		end
	elseif item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		return self:getFetterHerosForSeason(self.m_show_data.item_effect or {})
	end
	return data or {}
end
-- 获取当前赛季的Index,和赛季
function M:getCurSeasonRewardIndex(configs)
	local cur_season = UserDataManager:getCurSeason() -- 获取赛季
	local season = 0
	local index = 1
	for idx, item in ipairs(configs) do
		if item.param <= cur_season and item.param >= season then
			season = item.param
			index = idx
		end
	end
	return index, season
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self:getShowRewardData()
	local loopscroll = self:findGameObject("loopscroll")
	loopscroll:SetActive(#data > 0)
	--local text_scroll_rect = self:findRectTransform("item_des_scroll")
	--if text_scroll_rect ~= nil then
	--	text_scroll_rect.offsetMin= Vector2(text_scroll_rect.offsetMin.x, #data > 0  and 265 or 153)
	--end

	if #data > 0 then
		if self.m_loop_scroll_view == nil then
			local params = {
				show_data = data,
				one_line_count = 3,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					local data = RewardUtil:getProcessRewardData(cell_data)
					GameUtil:updateItemElementByData(cell_object, data, data.data_num > 1, true)
				end,
				ui_name = self.m_uiName
			}
			self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_loop_scroll_view:reloadData(data)
		end
	end
end


function M:updateHeroLoopScroll()
	local hers_tab = UserDataManager.hero_data:getHerosData()
	local data = self:getFetterHeros()
	self.hero_oids = {} --
	for i,v in pairs(hers_tab) do
		if self:checkInTab(v.id, data) == true then
			if self.hero_oids[v.id] == nil then
				self.hero_oids[v.id] = v
			else
				if self.hero_oids[v.id].evo < v.evo then
					self.hero_oids[v.id] = v
				end
			end
		end
	end
	local loopscroll = self:findGameObject("hero_loopscroll")
	loopscroll:SetActive(#data > 0)
	local function sortFunc(id_one, id_two)
		local evo_1 = 1
		local evo_2 = 1
		if self.hero_oids[id_one] then
			evo_1 = self.hero_oids[id_one].evo
		end
		if self.hero_oids[id_two] then
			evo_2 = self.hero_oids[id_two].evo
		end
		if evo_1 == evo_2 then 
			return id_one > id_two
		else
			return evo_1 > evo_2
		end
    end
    table.sort(data, sortFunc)
	if #data > 0 then
		if self.m_hero_loop_scroll_view == nil then
			local params = {
				show_data = data,
				loop_scroll_object = loopscroll,
				update_cell = function(index, cell_object, cell_data)
					local oid = nil
					if self.hero_oids[cell_data] then
						oid = self.hero_oids[cell_data].oid
					end
					CommonUIUtil:updateHeroElement(cell_object, {101, cell_data, 1, oid})
					local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
					if luaBehaviour then
						local item_img = luaBehaviour:FindImage("item_img")
						local camp_img = luaBehaviour:FindImage("camp_img")
						if oid == nil then
							if item_img then
								item_img.material = self.m_gray_image.material
							end
							if camp_img then
								camp_img.material = self.m_gray_image.material
							end
						else
							if item_img then
								item_img.material = nil
							end
							if camp_img then
								camp_img.material = nil
							end
						end
						LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lv_text", false)
					end
				end,
				ui_name = self.m_uiName
			}
			self.m_hero_loop_scroll_view = LoopScrollViewUtil.new(params)
		else
			self.m_hero_loop_scroll_view:reloadData(data)
		end
	end
end

function M:getSearchText()
	return self.find_input.text
end

function M:setSearchText(num)
	self.find_input.text = num
end

function M:inputChanged()
	local num = self:getSearchText()
	if self.m_use_max and tonumber(num) >= self.m_use_max then
		num = self.m_use_max
		self.find_input.text =  self.m_use_max
	end
	self.m_use_num = tonumber(num)
end

function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M