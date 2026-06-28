local M = class("TalisManmentCompareView",LikeOO.OOPopBase)

M.m_uiName = "HeroBag/HeroTalisMan/TalisManmentCompare"
M.m_size_type = 2


function M:onEnter()
	self.m_select_cell_index = 1
	EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	self:initText()
	self:refreshUI()
end

function M:initText()
	--self:setTextByLanKey("common_title_text", "talisman_text_001")
	self:setTextByLanKey("shiyong_txt", "talisman_text_0013")
	self:setTextByLanKey("keep_txt", "talisman_text_0014")
	self:setTextByLanKey("left_old_title_txt", "talisman_text_0017")
	self:setTextByLanKey("left_old_power_txt", "talisman_text_0015")
	self:setTextByLanKey("left_property_title_txt", "talisman_text_006")
	self:setTextByLanKey("left_effect_title_txt", "talisman_text_0018")
	self:setTextByLanKey("right_old_title_txt", "talisman_text_0016")
	self:setTextByLanKey("right_old_power_txt", "talisman_text_0015")
	self:setTextByLanKey("right_property_title_txt", "talisman_text_006")
	self:setTextByLanKey("right_effect_title_txt", "talisman_text_0018")
	self:setTextByLanKey("keep_shuxing_txt", "talisman_text_0021")
	self:setTextByLanKey("left_old_power_txt", "talisman_text_0035")
	self:setTextByLanKey("right_new_power_txt", "talisman_text_0035")
end

function M:dataUpdateEvent()
	self:updateLeftInfo()
end

function M:refreshUI()
	self:updateLeftInfo()
	self:updateRightInfo()
end
function M:updateLeftInfo()
	local data = self.m_model.left_data
	local lock_num = 0
	if data then
		self:setObjectVisible("ItemNode_left",true)
		self:setObjectVisible("left_effect_bg",true)
		--刷新物品
		local item = self:findGameObject("ItemNode_left")
		local itemData = self.m_model:getTalisDataById(data.id)
		GameUtil:updateItemElement(item, itemData.reward or {170,data.id,1}, false, false)
		--刷新战力
		--local combat = self.m_model:getTalisComatByArr(data.attrs)
		local combat = self.m_model:getCurrentIntegral(self.m_model.pos,data.attrs)
		combat = math.floor(combat * 10 + 0.5)/10
		self.m_model.left_value = combat
		self:setTextByLanKey("left_old_power_num_txt",GameUtil:formatValueToString(combat))

		local cfgData = self.m_model:getTalisSuitConfigByCid(data.id or 1)
		for i =1,3 do
			local attr_data = data.attrs[tostring(i)] 
			if attr_data then
				self:setObjectVisible("left_property_not_empty_"..i,true)
				self:setObjectVisible("left_property_empty_"..i,false)
				--设置锁
				local lockImage = attr_data.locked ==1 and "a_zbxl_jinsuo" or "a_zbxl_suo_open"
				local path = attr_data.locked ==1 and "mystic_ui" or "active_ui"
				self:setImg(lockImage, path, "left_property_lock_"..i)

				--优化 把没有锁的隐藏
				if attr_data.locked ==0 then
					self:setObjectVisible("left_property_lock_"..i,false)
				end
				--设置属性
				local showArr = self.m_model:getCurrentAttrs({attr_data.value})
				local at_name = GameUtil:getAttrsName(showArr[1]).."："
				--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", at_name)
				-- 四舍五入保留小数点后一位
				local attr_value = showArr[2].cur_num or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				if GameUtil:newattrTransition2(showArr[1]) == true then
					self:setTextByLanKey("left_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value).."%")
				else
					self:setTextByLanKey("left_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value))
				end
				self:setTextColor("left_property_text_"..i,self.m_model:getCurrentPropertyTextColor(attr_data.value[2],self.m_model.pos,attr_data.value[1]))

				local reward_bar = self:findSlider("left_property_slider_"..i)
				local cur_value,max_value = self.m_model:getCurrentLimitbyId(cfgData.quality,self.m_model.pos,attr_data.team_id,attr_data.value[2])
				reward_bar.value = cur_value/max_value
				--设置上锁数量
				lock_num = attr_data.locked ==1 and lock_num +1 or lock_num
			else
				self:setObjectVisible("left_property_not_empty_"..i,false)
				self:setObjectVisible("left_property_empty_"..i,true)
			end
		end
		--特殊处理红色
		if cfgData.quality <14 then
			self:setObjectVisible("left_property_not_empty_"..3,false)
			self:setObjectVisible("left_property_empty_"..3,false)
		end
		--刷新效果
		self:setTextByLanKey("left_effect_text_1",cfgData.name or "")
		self:setTextByLanKey("left_effect_text_title_2","talisman_text_007")
		self:setTextByLanKey("left_effect_text_2",cfgData.addition2.tips or "")
		self:setTextByLanKey("left_effect_text_title_3","talisman_text_008")
		self:setTextByLanKey("left_effect_text_3",cfgData.addition4.tips)
		--self:setImg(cfgData.icon, "maze_stage_ui", "fuzhuan_bg_1")
	else
		for i = 1,3 do
			self:setObjectVisible("left_property_not_empty_"..i,false)
			self:setObjectVisible("left_property_empty_"..i,true)
		end
		self:setObjectVisible("ItemNode_left",false)
		self:setObjectVisible("left_effect_bg",false)
	end
	--刷新元宝数量
	local diamond_num = UserDataManager.user_data:getUserStatusDataByKey("diamond") or 0
	local use_num = 0
	local commonData = ConfigManager:getCfgByName("common")
	local commonDataIndex = commonData[771]
	if commonDataIndex and lock_num>0 then
		use_num =  commonDataIndex.value and commonDataIndex.value[lock_num][2] or 0
	end
	self:setTextByLanKey("yuangbao_txt",GameUtil:formatValueToString(use_num).."/"..GameUtil:formatValueToString(diamond_num))
	--刷新使用次数
	local current_num = self.m_model:getTalisDataById(self.m_model.m_talins_id).number and self.m_model:getTalisDataById(self.m_model.m_talins_id).number or 0
	self:setTextByLanKey("fuzhuan_txt","talisman_text_0027",1,current_num)
	if current_num <=0 then 
		self:setTextColor("fuzhuan_txt",GlobalConfig.FUZHUAN_GRADE_COLOR[10]) --红色
	end
end

function M:updateRightInfo()
	local data = self.m_model.right_data
	if data then
		self:setObjectVisible("ItemNode_right",true)
		self:setObjectVisible("right_effect_bg",true)
		--刷新物品
		local item = self:findGameObject("ItemNode_right")
		local itemData = self.m_model:getTalisDataById(data.id)
		GameUtil:updateItemElement(item, itemData.reward or {170,data.id,1}, false, false)
		--刷新战力
		--local combat = self.m_model:getTalisComatByArr(data.attrs)
		local combat = self.m_model:getCurrentIntegral(self.m_model.pos,data.attrs)
		combat = math.floor(combat * 10 + 0.5)/10
		self.m_model.right_value = combat
		self:setTextByLanKey("right_new_power_num_txt", GameUtil:formatValueToString(combat))
		local cfgData = self.m_model:getTalisSuitConfigByCid(data.id or 1)
		--刷新属性
		for i =1,3 do
			local attr_data = data.attrs[tostring(i)]
			if attr_data then
				self:setObjectVisible("right_property_not_empty_"..i,true)
				self:setObjectVisible("right_property_empty_"..i,false)
				--设置锁
				local lockImage = attr_data.locked ==1 and "a_zbxl_jinsuo" or "a_zbxl_suo_open"
				local path = attr_data.locked ==1 and "mystic_ui" or "active_ui"
				self:setImg(lockImage, path, "right_property_lock_"..i)
				
				--优化 把没有锁的隐藏
				if attr_data.locked ==0 then 
					self:setObjectVisible("right_property_lock_"..i,false)
				end
				--设置属性
				local showArr = self.m_model:getCurrentAttrs({attr_data.value})
				local at_name = GameUtil:getAttrsName(showArr[1]).."："
				--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "attr_name_text", at_name)
				-- 四舍五入保留小数点后一位
				local attr_value = showArr[2].cur_num or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				if GameUtil:newattrTransition2(showArr[1]) == true then
					self:setTextByLanKey("right_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value).."%")
				else
					self:setTextByLanKey("right_property_text_"..i, at_name..GameUtil:formatValueToString(attr_value))
				end
				self:setTextColor("right_property_text_"..i,self.m_model:getCurrentPropertyTextColor(attr_data.value[2],self.m_model.pos,attr_data.value[1]))

				local reward_bar = self:findSlider("right_property_slider_"..i)
				local cur_value,max_value = self.m_model:getCurrentLimitbyId(cfgData.quality,self.m_model.pos,attr_data.team_id,attr_data.value[2])
				reward_bar.value = cur_value/max_value
				
				--设置刷新特效
				if  attr_data.locked == 0 then
					local back_effect = self:findGameObject("right_property_not_empty_back_"..i)
					UIUtil.destroyAllChild(back_effect.transform)
					local eqp_effect2 = ResourceUtil:GetUIEffectItem("ItemNode/UI_ItemNode_Talins_001", self:findGameObject("right_property_not_empty_"..i))
					eqp_effect2.transform:SetParent(back_effect.transform, false)
					eqp_effect2.transform.localPosition = Vector3(0,0,0)
				end
			else
				self:setObjectVisible("right_property_not_empty_"..i,false)
				self:setObjectVisible("right_property_empty_"..i,true)
			end
		end
		--特殊处理红色
		if cfgData.quality <14 then
			self:setObjectVisible("right_property_not_empty_"..3,false)
			self:setObjectVisible("right_property_empty_"..3,false)
		end

		--刷新效果
		self:setTextByLanKey("right_effect_text_1",cfgData.name or "")
		self:setTextByLanKey("right_effect_text_title_2","talisman_text_007")
		self:setTextByLanKey("right_effect_text_2",cfgData.addition2.tips or "")
		self:setTextByLanKey("right_effect_text_title_3","talisman_text_008")
		self:setTextByLanKey("right_effect_text_3",cfgData.addition4.tips)
		self:setImg(cfgData.icon, "maze_stage_ui", "fuzhuan_bg_1")
	else
		for i = 1,3 do
			self:setObjectVisible("right_property_not_empty_"..i,false)
			self:setObjectVisible("right_property_empty_"..i,true)
		end
		self:setObjectVisible("ItemNode_right",false)
		self:setObjectVisible("right_effect_bg",false)
	end
end


function M:destroy()
	EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.NET_DATA_UPDATE_EVENT, {self, self.dataUpdateEvent})
	M.super.destroy(self)
end

return M