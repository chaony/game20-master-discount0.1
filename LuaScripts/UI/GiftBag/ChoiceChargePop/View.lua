local M = class("ChoiceChargePopView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/ChoiceChargePop"
M.m_size_type = 2

function M:onEnter()
	audio:SendEvtUI("UI_Popup_N3")
    self.m_gray_image = self:findImage("gary_img")
    self.reward_grid = self:findGameObject("reward_node")
	self:setTextByLanKey("title_text3", "yinTower_text_0014")
	self:setSpine()
	self:createLoopScroll()
	self:updateTogLight()
	self:refreshUI()
end

function M:updateChargeLvNodeStatus()
	self:setObjectVisible("charge_level_node", self.m_model.m_is_show_charge_lv)
	if self.m_model.m_is_show_charge_lv then
		self:refreshChargeLvNode()
	end
end

function M:refreshChargeLvNode()
	local sub_ids = self.m_model:getChoiceNetData()
	for i = 1, 3 do
		local btn = self:setObjectVisible("charge_btn" .. i , i <= #sub_ids)
		if i <= #sub_ids then
			local price = 999
			if self.m_model.m_gift_cfg.three_charge then
				price = self.m_model:getChoiceCfgData(self.m_model.m_gift_cfg.three_charge, i, "price") or price
			end
			self:setTextByLanKey("charge_text_" .. i, GameUtil:getMoneyTypeNum(price))
			if i == self.m_model.m_charge_index then
				self:setImg("a_hd_jyzt_yq02", "active_ui", "charge_btn" .. i)
				self:setTextColor("charge_text_" .. i, Color( 120/255, 37/255, 36/255))
			else
				self:setImg("a_hd_jyzt_yq01", "active_ui", "charge_btn" .. i)
				self:setTextColor("charge_text_" .. i, Color( 244/255, 222/255, 156/255))
			end
		end
	end
end

--[[
    创建页签列表
]]
function M:createLoopScroll()
    self.m_tag_tab = {}
	local data = self.m_model.m_tag_table
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_tag_tab[index] = {data = cell_data, obj = cell_obj}
                self:update_tag(index, cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                self:updateMsg("change_tag", index)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:update_tag(index, obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text_dark", data.gift_name)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tag_name_text_light", data.gift_name)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_dark", self.m_model.m_select_index ~= index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_light", self.m_model.m_select_index == index)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_select_index == index)
	end
end

function M:updateTogLight()
    -- for k, v in pairs(self.m_tag_tab) do
    --     local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
    --     if luaBehaviour then
    --         LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_dark", self.m_model.m_select_index ~= k)
	-- 		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "tag_name_text_light", self.m_model.m_select_index == k)
	-- 		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_select_index == k)
    --     end
    -- end
end

function M:refreshUI()
	self:setTextByLanKey("common_pop_des", self.m_model.m_gift_cfg.des)
	self:setTextByLanKey("num","gf_str_0033", self.m_model.m_gift_cfg.return_per)
	self:setTextByLanKey("common_pop_des", self.m_model.m_gift_cfg.des)
	local price = self.m_model.m_gift_cfg.price
	if self.m_model.m_gift_cfg.three_charge then
		price = self.m_model:getChoiceCfgData(self.m_model.m_gift_cfg.three_charge, self.m_model.m_charge_index, "price") or price
		
	end
	local text_1 = self.m_model:getChoiceCfgData(self.m_model.m_gift_cfg.three_charge, nil, "pre_name") or ""
	local text_2 = self.m_model:getChoiceCfgData(self.m_model.m_gift_cfg.three_charge, nil, "after_name") or ""
	self:setTextByLanKey("title_text1", text_1)
	self:setTextByLanKey("title_text2", text_2)
	local show_btn = GameUtil:getMoneyTypeNum(price)
	self:setTextByLanKey("get_reward_text", show_btn)
	local num = #self.m_model.m_rewards
	UIUtil.destroyAllChild(self.reward_grid.transform)
	for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
		local item = GameUtil:createItemElement(data, showNum, true)
		item.transform:SetParent(self.reward_grid.transform, false)
	end
	if self.m_model.m_gift_cfg.return_per and  self.m_model.m_gift_cfg.return_per ~= "" then
		local return_per = tonumber(self.m_model.m_gift_cfg.return_per) * 100
		if return_per >= 1000 then
			self:setObjectVisible("num3", false)
			self:setObjectVisible("num4", true)
			local thousand_num = math.floor(return_per/1000)
			local hundred_num = math.floor((return_per - thousand_num*1000)/100)
			self:setImg( "a_xslb_num_"..thousand_num, "active_ui", "fanli_num_4_1")
			self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_4_2")
		else
			self:setObjectVisible("num3", true)
			self:setObjectVisible("num4", false)
			local hundred_num =  math.floor(return_per/100)
			local ten_num = math.floor((return_per - hundred_num*100)/10)
			self:setImg( "a_xslb_num_"..hundred_num, "active_ui", "fanli_num_3_1")
			self:setImg( "a_xslb_num_"..ten_num, "active_ui", "fanli_num_3_2")
		end
	end
	
	self:updateChargeLvNodeStatus()
	self:updateTime()
end

function M:updateTime()
	local end_time = self.m_model:getGiftPushTim()
	if end_time then
		local down_time = end_time - UserDataManager:getServerTime()
		local show_text = GameUtil:formatTimeBySecond(down_time,999)..Language:getTextByKey("gf_str_0104")
		self:setTextByLanKey("bottom_des", show_text)
		if down_time <= 0 then
			self:updateMsg(99999)
		end
	end
end

function M:setSpine()
	local hero_id = self.m_model:getHeroInReward()
	local shin_data_cfg = UserDataManager.hero_data:getHeroCurSkinCfgByData({skin = hero_id})
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_id)
	if shin_data_cfg and next(shin_data_cfg) ~= nil then
		local icon = shin_data_cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	elseif cfg then
		local icon = cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	else
		self.cacheSpineName = "hero_0602_SkeletonData"
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	end
end

--- 关闭ui动画
function M:runCloseAnim( anim_node, callBackFunc)
	local transfer = self.m_model.m_transfer
	if anim_node and transfer then
		self:lockTouch("TAG:runCloseAnim")
		local function endCallFunc()
			self:unlockTouch("TAG:runCloseAnim")
			callBackFunc()
		end
		local transform = anim_node.transform
		if transfer == "scale" then
			local sequence = Tweening.DOTween.Sequence()
			sequence:Append(transform:DOScale(0, 0.2))
			if not IsNull(self.m_model.m_gift_btn) then
				local pos = self.m_model.m_gift_btn.transform.parent:TransformPoint(self.m_model.m_gift_btn.transform.localPosition) --世界坐标
				pos = anim_node.transform.parent:InverseTransformPoint(pos) -- 相对坐标
				sequence:Join(transform:DOLocalMove(pos,0.2))
			end
			sequence:OnComplete(endCallFunc)
			sequence:SetAutoKill(true)
		else
			endCallFunc()
		end
	else
		callBackFunc()
	end
end


return M