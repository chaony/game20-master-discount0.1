---@class FirstCharge:OOPopBase
---@field m_model FirstChargeModel
local M = class("FirstChargeView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/FirstCharge"
M.m_size_type = 2

function M:onEnter()
    self.m_gray_image = self:findImage("gary_img")
    self.reward_grid = self:findGameObject("reward_node")
	local day_list = self.m_model:getDayList()
	for i = 1,3 do
		self:setTextByLanKey("day_text_"..i, "day_str_"..day_list[i])
	end
	self.privilege_btn = self:findGameObject("quality_btn")
	for i = 1,4 do
		self:setObjectVisible("charge_btn"..i, false)	
	end
	self:setTextByLanKey("go_to_text", "gf_str_0064")
	self:setTextByLanKey("get_btn_text", "new_str_0080")
	self:setTextByLanKey("reward_text", "new_str_0056")
	self:refreshUI()
	local day = GameUtil:dayCompute()
    UserDataManager.local_data:setUserDataByKey("first_charge_day_first_" .. day, 1)
end

function M:updateTagUI()
	for k,v in pairs(self.m_model.m_tag_list) do
		local price = GameUtil:switchMoneyType( v.price)
		local labelTxt = Language:getTextByKey("charge_gift_txt", price)
		local charge_text = self:setTextByLanKey("charge_text_"..k, labelTxt)
		if k == self.m_model.m_select_tag_index then
			self:setImg("a_sc_yeqianxuanzhong", "active_ui","charge_btn"..k)
			charge_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
			self:setObjectVisible("charge_check_"..k, true)
		else
			self:setImg("a_sc_yeqianweixuanzhong", "active_ui","charge_btn"..k)
			charge_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
			self:setObjectVisible("charge_check_"..k, false)
		end
		local tag_red_point = self.m_model:checkRedPointByTag(k)
		self:setObjectVisible("tag_red_point_"..k, tag_red_point == true)
		local pay_num = self.m_model:getPayNum()
		if pay_num >= GameUtil:switchMoneyType(v.sort) then
			self:setObjectVisible("charge_btn"..k, true)
		else
			self:setObjectVisible("charge_btn"..k, false)	
		end
	end
end

function M:refreshUI()
	self:updateTagUI()
	self:updateDayBtns()
	self:updateCurReward()
	self:updateSubPayNum()
	local pay_num = GameUtil:switchMoneyType( self.m_model:getNeedPayNum())
	self:setTextByLanKey("price_num", "gf_str_0029", pay_num)
	local can_get = self.m_model:checkCanGet()
	local get_bl = self.m_model:getPayData()
	self:setObjectVisible("get_reward", can_get == true)
	self:setObjectVisible("get_btn", get_bl == true)
	self:setObjectVisible("get_time_btn", false)
	local charge_cfg = self.m_model:getSecectRechargeCfg()
	if charge_cfg.reward_show then
		self:setSpine(charge_cfg.reward_show[1])
	end
	self:setTextByLanKey("des_text", charge_cfg.name2)
	self:setTextByLanKey("des_hero_text", charge_cfg.name3)
	if can_get == false and get_bl == false then
		local need_num =  GameUtil:switchMoneyType(self.m_model:getNeedPayNum())
		local pay_num = self.m_model:getPayNum()
		if pay_num >= need_num then
			self:setObjectVisible("go_to_btn", false)
			local day = self.m_model:checkGetDay()
			if day == 1 then
				self:setTextByLanKey("get_time_text", "gf_str_0118")
			elseif day == 2 then
				self:setTextByLanKey("get_time_text", "gf_str_0136")	
			else	
				self:setTextByLanKey("get_time_text", "gf_str_0119", Language:getTextByKey("num_str_000"..day) )
			end
			self:setObjectVisible("get_time_btn", true)
		else
			self:setObjectVisible("go_to_btn", true)
		end
	else
		self:setObjectVisible("go_to_btn", false)
	end
end

function M:updateSubPayNum()
	local need_num =  GameUtil:switchMoneyType(self.m_model:getNeedPayNum())
	local pay_num = self.m_model:getPayNum()
	if pay_num >= need_num then
		-- self:setTextByLanKey("sub_pay_num", "已累计充值"..need_num.."/"..need_num.."元")
		self:setTextByLanKey("sub_pay_num", "gf_str_0120",need_num.."/"..need_num)
	else
		self:setTextByLanKey("sub_pay_num", "gf_str_0120",pay_num.."/"..need_num)
	end
end

function M:updateCurReward()
	local c_reward = self.m_model:getSelectReward()
	self.privilege_btn.transform:SetParent(self.content_node.transform, false)
	self.privilege_btn:SetActive(false)
	local items = self:creatRewards(c_reward)
	for k,v in pairs(items) do
		self:updateItem(v)
	end
	if self.m_model.m_select_tag_index == 1 and self.m_model.m_select_day_index == 1 then
		local bl = self.m_model:getPayData()
		self.privilege_btn.transform:SetParent(self.reward_grid.transform, false)
		self.privilege_btn:SetActive(true)
		self:setObjectVisible("privilege_duigou", bl == true)
	end
end

function M:updateDayBtns()
	local day_list = self.m_model:getDayList()
	for i = 1,3 do
		local day_text = self:findText("day_text_"..i)
		self:setTextByLanKey("day_text_"..i, "day_str_"..day_list[i])
		if i == self.m_model.m_select_day_index then
			day_text.color = GlobalConfig.COMMON_COLLOR.COMMON_24
			--day_text.color = GlobalConfig.COMMON_COLLOR.COMMON_14
			self:setObjectVisible("day_img_"..i, true)
		else
			day_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
			--day_text.color = Color( 244/255, 222/255, 156/255)
			self:setObjectVisible("day_img_"..i, false)
		end
		local day_red_point = self.m_model:checkRedPointByDay(i)
		if i == self.m_model.m_select_day_index then
			self:setObjectVisible("day_red_point_"..i, false)
		else
			self:setObjectVisible("day_red_point_"..i, day_red_point == true)			
		end
	
	end
end

function M:creatRewards(rewards)
	if rewards == nil then
		return
	end
	local num = #rewards
	local new_items = {}
	UIUtil.destroyAllChild(self.reward_grid.transform)
	for i = 1, num do
		local data = rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		if not showNum then
			local data = RewardUtil:getProcessRewardData(data)
			GameUtil:creatCommonActiveEffect(item, data.quality, 1)
		end
		item.transform:SetParent(self.reward_grid.transform, false)
		new_items[i] = item
	end
	return new_items
end

function M:updateItem(obj)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local bl = self.m_model:getPayData()
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", bl == true)
	end
end

function M:setSpine(hero_reward)
	if hero_reward then
		local reward_data = RewardUtil:getProcessRewardData(hero_reward)
		if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
			if cfg then
				local icon = cfg.hero_spine
				if self.cacheSpineName == icon then
					return
				else
					self.cacheSpineName = icon
				end
				local play_img = self:findGameObject("hero_sk")
				GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
			end
		end
	else	
		local hero_sk = self:findGameObject("hero_sk")
		GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/hero_0105_SkeletonData", "idle", 0, true)
	end
end


return M