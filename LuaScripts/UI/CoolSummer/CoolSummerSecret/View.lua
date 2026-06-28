local M = class("CoolSummerSecretView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversarySecret"
M.m_size_type = 2
M.m_iphoneXAdapter = true
M.QUALITY_ITEM = {
    { frame_name = "a_xlqp_hui"  }, --1 灰色
    {frame_name = "a_xlqp_lv"   }, --2 绿色
    {frame_name = "a_xlqp_lan"   }, --3 蓝色
    {frame_name = "a_xlqp_lan"    }, --4 蓝+ 有外框
    {frame_name = "a_xlqp_zi"      }, --5 紫色
    {frame_name = "a_xlqp_jin"     }, --6 金
    {frame_name = "a_xlqp_hong"   }, --7 红
    {frame_name = "a_xlqp_bai" }, --8 白
	{frame_name = "a_xlqp_bai" }, --9 白
	{frame_name = "a_xlqp_bai" }, --10 白
	{frame_name = "a_xlqp_bai" }, --11 白
	{frame_name = "a_xlqp_cai" } --12 彩
}

local Time_1 = 0.5
local Time_2 = 1.7

M.NONE_POS = {1, 3, 6, 13, 17, 24, 25, 27, 31, 33, 36} --空节点
M.BIG_POS = {4,7,8,11,12,15,16,20,22,26,29,32,35} --大节点

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 36})
	self:updateCommonAttrNodes()
	self.avtive_data = self.m_model:getActiveData()
	if self.avtive_data then
		self:setTextByLanKey("close_title_text", self.avtive_data.name )
	end
	self.scroll_parent = self:findGameObject("scroll_list")
	self.GridLayoutGroup = self.scroll_parent:GetComponent("GridLayoutGroup")
	self:updateShuaXinEffect(false)
	self:refreshUI()
	self:setTextByLanKey("jiangli_text", "gf_scroll_str_0001")
	local active_cfg = self.m_model:getActiveCfg()
	if active_cfg and active_cfg.hero_id and active_cfg.hero_id > 0 then
		self:setObjectVisible("to_active_obj", true)
	else
		self:setObjectVisible("to_active_obj", false)	
	end
	self:setTextByLanKey("active_btn_text", "gf_str_0078")
	self:setObjectVisible("change_btn", false)
	self:setSpine()
end

--夏日夺宝切换为spine
function M:setSpine()
	local img_go = self:findGameObject("hero_img")
	local spine_go = self:findGameObject("hero_spine")
	img_go:SetActive(false)
	spine_go:SetActive(true)
	local scroll_cfg = self.m_model:getScrollCfg()
	local spine_name = scroll_cfg.photo or "hero_0001_SkeletonData"
	GameUtil:updateSpineLoadSet(spine_go, "RoleSpine/" .. spine_name, "", 0, true)
end

function M:refreshUI()
	self:updateBigReward()
	self:updateCostUI()
	self:updateScrollItems()
	self:setTextByLanKey("stage_num", self.m_model:getLayerNum()) --设置层数
	--self:setObjectVisible("get_red_point", self.m_model:checkTaskRedPoint() == true)
	self:setObjectVisible("spine_xinshou", self.m_model:checkIsNewLayer() == true)
	self:showTheAward()
end

-- 公共资源
function M:updateCommonAttrNodes()
	local attr_mode = self.m_model:isToken() and 42 or 36
	self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = attr_mode})
end


--展示本期大奖
function M:showTheAward()
	local vip_lv = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
	self:setObjectVisible("FinshGift", vip_lv >= 8)
	local big_reward = self.m_model:getTheAwardData()
	if vip_lv >= 8 and big_reward then
		local TheAwardItem = self:findGameObject("TheAwardItem")
		if TheAwardItem then
			GameUtil:updateItemElement(TheAwardItem, big_reward,true,true)
		end
		local show_str = self.m_model:showTehAwardNum()
		self:setTextByLanKey("process_txt", "gf_str_0094", show_str)
		local luaBehaviour = UIUtil.findLuaBehaviour(TheAwardItem)
		if luaBehaviour then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isGetBig() == true)
		end
	else
		self:setObjectVisible("FinshGift", false)	
	end
end

function M:pieceEnterAnim()
	self:lockTouch()
	self.m_control:setOnceTimer(1.8,function ()
		self:unlockTouch()
	end)
	for k,v in pairs(self.reward_items) do
		--if self:checkNone(k) == false then
			local itemNode = UIUtil.setObjectVisible(v.transform, false, "itemNode")
			local delayTime = math.random(1,8) * 0.1;
			self.m_control:setOnceTimer(delayTime, function ()
				self:showEnterEffect(itemNode)
			end)
		--end
	end
end

function M:showEnterEffect(obj)
	obj.gameObject:SetActive(true)
	UIUtil.setObjectVisible(obj.transform, true, "enterEffect")
	self.m_control:setOnceTimer(1, function ()
		UIUtil.setObjectVisible(obj.transform, false, "enterEffect")
	end)
end

function M:updateScrollItems()
	local get_num = 0
	local data = {}
	self.reward_items = {}
	UIUtil.destroyAllChild(self.scroll_parent.transform)
	self.GridLayoutGroup.enabled = true
	for i = 1, 16 do
		local rcvd_gift = self.m_model:getScrollRcvdGift(i)
		if rcvd_gift and next(rcvd_gift) ~= nil then
            get_num = get_num + 1
        end
        data[i] = rcvd_gift or {}
        local cell_obj = self:creatItemObj()
		self.reward_items[i] = cell_obj
        self:updateItemNode(i, cell_obj, data[i])
	end
	local last = self.m_model:checkLastFloor()
	if last == true and get_num == 16 then
        self:setObjectVisible("kong_panel",true)
		for k,v in pairs(self.reward_items) do
			v:SetActive(false)
		end
    end
end

function M:updateItemNode(index, obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		--if self:checkNone(index) == true then
		--	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "itemNode", false)
		--	return
		--end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_back", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_front", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_zhadan", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "play_big_reward_ef", false)
		--local is_big = self:checkBig(index)
		local item_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "itemNode", true)
		local is_big_reward = data.is_big and data.is_big == 1
		if next(data) == nil then -- 未打开
			--LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", not is_big)
			
			--if self.m_model:checkWhitePos(index) == true then
			--	LuaBehaviourUtil.setImg(luaBehaviour, "piece_icon", "a_xlqp_big_bai", "active_ui")
			--else
			--	LuaBehaviourUtil.setImg(luaBehaviour, "piece_icon", "a_xlqb_daheiqi", "active_ui")	
			--end
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "piece_icon", true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_bg", false)
		elseif data.is_bomb then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bomb_img", true)
			local bomb_img = luaBehaviour:FindGameObject("bomb_img")
			--if is_big == true then
			--	UIUtil.setScale(bomb_img.transform, 0.78)
			--else
			--	UIUtil.setScale(bomb_img.transform, 0.66)	
			--end
		else	
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "piece_icon", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "little_bg", false)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_bg", true)
			local item_data = RewardUtil:getProcessRewardData(data.gift[1])
			--local que_data = self.QUALITY_ITEM[item_data.quality]
			--local reward_bg = LuaBehaviourUtil.setImg(luaBehaviour, "reward_bg", que_data.frame_name, "active_ui")
			--LuaBehaviourUtil.setImg(luaBehaviour, "reward_icon", item_data.icon_name, item_data.atlas_name)
			local ItemNode = luaBehaviour:FindGameObject("ItemNode")
			GameUtil:updateItemElementByData(ItemNode, item_data, true)
			if item_data.data_num >= 1 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", false)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_num", item_data.data_num)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", false)	
			end
			if is_big_reward == true and self.m_model:checkLastFloor() == false then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "next_img", true)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "num_bg", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_bg", false)
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "next_img", false)
			end
			--if is_big == true then
			--	UIUtil.setScale(reward_bg.transform, 0.78)
			--else
			--	UIUtil.setScale(reward_bg.transform, 0.66)	
			--end
		end
		local function clickCallback()
			if is_big_reward == true and self.m_model:checkLastFloor() == false then
				self:setBigEffect(function ()
					self:updateMsg("next_layer")
				end)
				return
			end
			if next(data) == nil then
				self:updateMsg("open_scroll", {position = index, vsn = self.m_model.m_data.version})	
			elseif data.is_bomb then

			else
				local item_data = RewardUtil:getProcessRewardData(data.gift[1])
				if item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.EQUIPS then
					static_rootControl:openView("HeroInfo.EquipmentPop", {equip_cfg_id = item_data.data_id, race = item_data.race, look_model = 3})
				elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.ITEM then
					static_rootControl:openView("Item.ItemDetail", {show_data = item_data, display = true}, nil, true)
				elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT or item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS_EXT then
					static_rootControl:openView("Pops.HeroLookInfo", {hero_id = item_data.data_id, is_new = false})
				elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HERO_SKIN then
					local hero_id = item_data.item_cfg.hero
					static_rootControl:openView("Pops.HeroLookInfo", {hero_id = hero_id, is_new = false, skin_id = item_data.data_id})
				elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.MYSTIC then
					static_rootControl:openView("SutraDepository.DepositoryPop", {oid = item_data.data_id, mode = 2, star = item_data.star})
				elseif item_data.data_type == RewardUtil.REWARD_TYPE_KEYS.TITLE then
					static_rootControl:openView("Title.TitleDetail", {show_data = item_data, display = true})
				else
					static_rootControl:openView("Pops.CommonItemTipsPop", {data = item_data, target_obj = item_node.gameObject})
				end
			end
		end
		UIUtil.setButtonClick(obj, clickCallback)
	end
end

function M:updateOneRewardItem(index)
	local rcvd_gift = self.m_model:getScrollRcvdGift(index)
	if self.reward_items[index] and rcvd_gift then
		self:updateItemNode(index, self.reward_items[index], rcvd_gift)
	end
	self:setObjectVisible("spine_xinshou", self.m_model:checkIsNewLayer() == true)
	--最后一层
	if self.m_model.m_data.layer >= 20 then
		local get_num = 0
		local data = {}
		for i = 1, 36 do
			local rcvd_gift = self.m_model:getScrollRcvdGift(i)
			if rcvd_gift and next(rcvd_gift) ~= nil then
				get_num = get_num + 1
			end
		end
		if get_num >= 25 then
			self:setObjectVisible("kong_panel",true)
			for k,v in pairs(self.reward_items) do
				v:SetActive(false)
			end
		end
    end
end



function M:setBigEffect(callback)
	local big_index = 0
	self.GridLayoutGroup.enabled = false
	for k,v in pairs(self.reward_items) do
		local rcvd_gift = self.m_model:getScrollRcvdGift(k)
		if next(rcvd_gift) ~= nil then
			local is_big_reward = rcvd_gift.is_big and rcvd_gift.is_big == 1
			local luaBehaviour = UIUtil.findLuaBehaviour(v)
			if luaBehaviour then
				if is_big_reward == true then
					audio:SendEvtUI("UI_XLQB_fx_2")
					big_index = k
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_back", true)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_front", true)
				end
			end
		end
	end
	if big_index == 0 then
		return
	end
	self:lockTouch()
	self.m_control:setOnceTimer(1.8, function ()
		self:unlockTouch()
		if callback then
			callback()
		end
	end)
	for k,v in pairs(self.reward_items) do
		if k ~= big_index then
			self:moveTo(v, self.reward_items[big_index])
		end
	end
end

--点到大奖的特效
function M:playGetBigEffext(pos, callback)
	local big_obj = self.reward_items[pos]
	if big_obj then
		audio:SendEvtUI("UI_SLQB_fx_3")
		local luaBehaviour = UIUtil.findLuaBehaviour(big_obj)
		if luaBehaviour then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "play_big_reward_ef", true)
		end
		self:lockTouch()
		self.m_control:setOnceTimer(1.25, function ()
			self:unlockTouch()
			if luaBehaviour then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "play_big_reward_ef", false)
			end
			callback()
		end)
	else
		callback()
	end
end

function M:moveTo(obj_1, obj_2)
	local group = obj_1:GetComponent("CanvasGroup")
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(obj_1.transform:DOLocalMove(obj_2.transform.localPosition, Time_2):SetEase(Tweening.Ease.OutSine))
	sequence:Join(obj_1.transform:DOScale(0.3, Time_1):SetEase(Tweening.Ease.OutSine))
	sequence:Join(DOTweenModuleUI.DOFade(group,0.3,Time_1):SetEase(CS.DG.Tweening.Ease.OutQuad))
	sequence:OnComplete(function ()
		obj_1:SetActive(false)
	end)
	sequence:SetAutoKill(true)
end

function M:setBoomEffect(bombData, callback)
	for k,v in pairs(bombData) do
		local bomb_obj = self.reward_items[v.pos]
		local rcvd_gift = self.m_model:getScrollRcvdGift(v.pos)
		if bomb_obj and rcvd_gift.is_bomb and rcvd_gift.is_bomb == 1 then
			local luaBehaviour = UIUtil.findLuaBehaviour(bomb_obj)
			if luaBehaviour then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "effect_zhadan", true)
			end
		end
	end
	if callback then
		self:lockTouch()
		self.m_control:setOnceTimer(1.2, function ()
			self:unlockTouch()
			callback()
		end)
	end
end

--设置大奖
function M:updateBigReward()
	local big_reward_cfg = self.m_model:checkBigRcvd()
	local rewardTable = big_reward_cfg.reward[1] or nil
	if rewardTable then
		self:setObjectVisible("big_reward_node", true)
		local data = RewardUtil:getProcessRewardData(rewardTable)
		local quality_data = self.QUALITY_ITEM[data.quality]
		self:setImg(quality_data.frame_name, "active_ui", "big_reward_bg")
		self:setImg(data.icon_name, data.atlas_name, "big_reward_icon")
		self:setObjectVisible("big_num_bg", data.data_num > 1)
		self:setTextByLanKey("big_reward_num", data.data_num)
	else
		self:setObjectVisible("big_reward_node", false)
	end
end

--设置消耗
function M:updateCostUI()
	local scroll_cfg = self.m_model:getScrollCfg()
	local scoreData = self.m_model:getCostNum()
    local consume_data = RewardUtil:getProcessRewardData(scoreData)
    self:setImg(consume_data.icon_name, consume_data.atlas_name, "consume_img")
    self:setTextByLanKey("desc", "gf_str_0049")
    if self.m_model.m_data.times >= scroll_cfg.free_time then
        self:setTextByLanKey("consume_num", "x"..consume_data.data_num)
    else
        self:setTextByLanKey("consume_num", "x0")
    end
end


function M:creatReward()
	local parent = self:findGameObject("parent")
	local cfg_list = self.m_model:getRecruitCfg()
	UIUtil.destroyAllChild(parent.transform)
	for k,v in ipairs(cfg_list) do
		local cfg = cfg_list[k]
		local show_d = true
		local score_data = self.m_model:getScoreData(k)
		local function callback(obj, data)
			if score_data == nil and self.m_model.m_data.score >= cfg.score then
				self:updateMsg("buy_score", k)
			end
		end
		value_table[k].num = cfg.score
		
		if score_data == nil and self.m_model.m_data.score >= cfg.score then
			show_d = false
		end
		local item = GameUtil:createItemElement(cfg.reward[1], true, show_d, callback)
		item.transform:SetParent(parent.transform, false)
		local reward_data = RewardUtil:getProcessRewardData(cfg.reward[1])
		if reward_data and reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS and score_data == nil then
			GameUtil:creatCommonActiveEffect(item, reward_data.quality, 0.9)
		end
		local LuaBehaviour = UIUtil.findLuaBehaviour(item)
		if LuaBehaviour then
			if score_data ~= nil then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_image", false)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", true)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img", false)	
			else
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_image", self.m_model.m_data.score >= cfg.score)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img", self.m_model.m_data.score >= cfg.score)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", false)	
			end
		end
		UIUtil.setScale(item.transform,  0.8)
		self:setTextByLanKey("num"..k, cfg.score)
	end
	local max_cfg = cfg_list[#cfg_list]
	if max_cfg then
		local rate = self.m_model.m_data.score/max_cfg.score
		self:setTextByLanKey("integral_text", self.m_model.m_data.score)
	end
	for k,v in pairs(value_table) do
		local cur_num = v.num
		local rate = self.m_model.m_data.score/cur_num
		local img = self:findImage(v.img)
		if k > 1 then
			local last_num = value_table[k-1].num
			if self.m_model.m_data.score >= cur_num then
				img.fillAmount = 1
			elseif self.m_model.m_data.score > last_num then
				img.fillAmount = 0.5
			else
				img.fillAmount = 0
			end
		end
	end
end

function M:creatItemObj()
	local item = ResourceUtil:LoadUIGameObject("HalfAnniversary/Secretscroll_item", Vector3.zero, nil)
	item.transform:SetParent(self.scroll_parent.transform, false)
    return item
end

function M:updateTime()
	if self.m_model.m_end_ts and self.m_model.m_end_ts > 0 then
		local time_show = self.m_model.m_end_ts - UserDataManager:getServerTime()
		self:setTextByLanKey("down_time", "activities_str_0012", GameUtil:formatTimeBySecond(time_show))
	else
		self:updateMsg(99999)
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("budoServer_text_0018"), delay_close = 2})
	end
end

--空节点
function M:checkNone(pos)
	for k,v in pairs(self.NONE_POS) do
		if pos == v then
			return true
		end
	end
	return false
end

--大节点
function M:checkBig(pos)
	for k,v in pairs(self.BIG_POS) do
		if pos == v then
			return true
		end
	end
	return false
end

--刷新大奖特效
function M:updateShuaXinEffect(bl)
	self:setObjectVisible("UI_GiftBag_ShuaXin_001", bl)
	if bl == true then
		self.m_control:setOnceTimer(2, function ()
			self:setObjectVisible("UI_GiftBag_ShuaXin_001", false)
		end)
	end
end

function M:destroy()
    if self.m_attr_node then
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
    M.super.destroy(self)
end



return M