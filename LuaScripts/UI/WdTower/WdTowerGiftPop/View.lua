local M = class("WdTowerGiftPopView",LikeOO.OOPopBase)
--成长礼包
M.m_uiName = "WdTower/WdTowerGiftPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
	self.m_gray_img = self:findImage("gray_img")
	local title_id = self.m_model:getDesByKey("reward_title") or "tid#TowerActiveDes_03"
	self:setTextByLanKey("close_title_text", title_id)
	local gift_bg = self.m_model:getDesByKey("gift_bg") or "a_jyzt_bg"
	if gift_bg then
		local gift_bg_img = self:findImage("gift_bg_img")
		GameUtil:updateResourcesImg( gift_bg_img, "Texture/yintower/" .. gift_bg)
	end
	local gift_arts_name = self.m_model:getDesByKey("gift_arts_name") or "a_jyzt_biaoti"
	if gift_arts_name then
		local gift_des_img = self:findImage("gift_des_img")
		GameUtil:updateResourcesImg( gift_des_img, "Texture/zh_cn/" .. gift_arts_name)
		gift_des_img:SetNativeSize()
	end
	self:setSpine()
	self.m_end_ts = 0
	self.m_content_panel = self:findGameObject("parent_obj")
	self.gray_img = self:findImage("gray_img")
	self:setTextByLanKey("title_text1", "budoServer_text_0013")
	self:setTextByLanKey("title_text2", "budoServer_text_0014")
	self:setTextByLanKey("gift_btn_text", "gf_str_0025")
	self:refreshUI()
end

function M:refreshRedPoint()
	local is_red2 = RedPointUtil:hasRedPointById(24402)
	self:setObjectVisible("gift_red_point", is_red2)
end

--刷新时间
function M:updateTime()
	local remain_tim = self.m_model:getEndTs() --剩余时间
	if self.m_model:getActStatus() == 1 then
		local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
		if remain_day > 0  then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0002",remain_day)) --重置剩余天
		elseif remain_day <= 0 and remain_hour > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0003",remain_hour)) --重置剩余小时
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0004",remain_min)) --重置剩余分钟
		elseif remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 and remain_sec > 0 then
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
		else
			self:setTextByLanKey("reset_time_text", Language:getTextByKey("yinTower_text_0005",remain_sec)) --重置剩余秒
			self:updateMsg("battle_end_refresh_ui") --重置数据
		end
		if self.remain_day == nil or self.remain_day > remain_day then
			self.remain_day = remain_day
		end
	elseif self.m_model:getActStatus() == 2 and remain_tim <= 0 then
		GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("gf_str_0085"), delay_close = 2})
		self:updateMsg(99999)
		self:updateMsg(99999,nil, "YinTower")
	else
		self:setTextByLanKey("reset_time_text", "yinTower_text_0013") --重置剩余秒
	end
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

function M:refreshUI()
	self:updateBoxStatus()
	local gift_list = self.m_model:getGiftsData()
	self:createLoopScroll(gift_list)
	self:refreshRedPoint()
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
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lock_star_text","huashan_sword_text0016", numStr, tostring(cell_data.num))
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

function M:setSpine()
	local c_id = self.m_model:getDesByKey("hero_id") or "501"
	local hk_obj = self:findGameObject("hero_sk")
	local hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(tonumber(c_id))
	local spine_name = hero_cfg.hero_spine or "hero_0001_SkeletonData"
	GameUtil:updateSpineLoadSet(hk_obj, "RoleSpine/" .. spine_name, "idle", 0, true)
end

function M:destroy()
	M.super.destroy(self)
end


return M
