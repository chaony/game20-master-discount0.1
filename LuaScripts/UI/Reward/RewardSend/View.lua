local M = class("RewardSendView",LikeOO.OOPopBase)

M.m_uiName = "Reward/RewardHeroSelectPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = {
	{btn = "martial_all_toggle", name = "martial_all_text", lan_text = "new_str_0065",race = 0},
	{btn = "martial_1_toggle", name = "martial_1_text", lan_text = "new_str_0144",race = 1},
	{btn = "martial_2_toggle", name = "martial_2_text", lan_text = "new_str_0145",race = 2},
	{btn = "martial_3_toggle", name = "martial_3_text", lan_text = "new_str_0143",race = 3},
	{btn = "martial_4_toggle", name = "martial_4_text", lan_text = "new_str_0142",race = 4},
	{btn = "martial_5_toggle", name = "martial_5_text", lan_text = "new_str_0237",race = 6},
	{btn = "martial_6_toggle", name = "martial_6_text", lan_text = "new_str_0238",race = 5},
	{btn = "martial_7_toggle", name = "martial_7_text", lan_text = "new_str_0238",race = 7},
}

local SEND_LIST = {} --槽位缓存 {key = k, obj = hero_item}
local RACE_LIST = {} --需要种族类型缓存 { race = v, iden = false, obj = race_item}

function M:onEnter()	
	self.cacheSpineName = ""
	self.m_camp_type = 1
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local item = self:findGameObject(v.btn)
		local lan_text = "new_str_0065"
		UIUtil.setObjectVisible(item.transform, self.m_model.selectType_index == i,"UI_ShareLv_Xuanze_01")
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",{index = data,value = __TAB_BTN_NODE[data]}) 
				UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
			else
				UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
			end 
		end, i, self.m_uiName)
	end

	
	local common = ConfigManager:getCfgByName("common")
	self:setTextByLanKey("all_ok_text", "paiqian_yijian_text")
    self:setText("ok_btn_order_text", "x"..common[324].value[3]) --悬赏令消耗
	self:setTextByLanKey("reward_hero_name", "reward_hero_name_text")
	self:setTextByLanKey("hero_num", Language:getTextByKey("coach_str_0017")..": "..#self.m_model.hero_list)
	self:setTextByLanKey("title_name_text", self.m_model.m_task.name)
	local data = GlobalConfig.BOUNTY_RANK[self.m_model.m_task.rank]
	self:setTextColor("title_name_text",data.RGBA)
	self:setTextByLanKey("msg_text", self.m_model.m_task.text)
    local item_data,item_cfg = UserDataManager.item_data:getItemDataById(common[324].value[2])
    self:setImg(item_cfg.icon, "item_icon", "order_img") --悬赏


	--奖励
	local m_reward_obj = self:findGameObject("reward_obj")
	local drop = self.m_model.m_reward or {}
	GameUtil:createRewards(m_reward_obj.transform, drop, true, true, nil, 1)
	if  self.m_model.m_type == 2  then
		self:setObjectVisible("zhuzhen_img", true)
		self:setImg("a_xuansahng_paiqian_bangpai", "common_ui", "zhuzhen_img")
	elseif self.m_model.m_type ==  3 then
		self:setObjectVisible("zhuzhen_img", true)
		self:setImg("a_xuanshang_paiqian_shitu", "common_ui", "zhuzhen_img")
	else
		self:setObjectVisible("zhuzhen_img", false)
	end
	self:creatItem()
	self.bottom_obj = self:findGameObject("bottom_bg")
	self.lang_bg = self:findGameObject("lang_bg")
	local send_btn = self:findButton("send_btn")
	send_btn.interactable = false
	self:updateCurHero()
	self:setObjectVisible("hero_spine",false)
	self:setTextByLanKey("common_title_text", "bounty_str_0013")

	self.dispatch = self:findGameObject("send_btn")
	self.one_keydispatch = self:findGameObject("one_keydispatch")

	self:btnSetActive(false,true)
	self:createLoopScroll()
end

function M:btnSetActive(dispatchActive,one_keydispatchActive)
	-- self.dispatch:SetActive(dispatchActive)
	-- self.one_keydispatch:SetActive(one_keydispatchActive)
end

function M:refreshUI(params)
	self:createLoopScroll(params)
	if self.m_loop_scroll_view ~= nil then 
		self.m_loop_scroll_view:moveToCellIndex(1)
	end
end

--派遣名单
function M:creatItem()
	SEND_LIST = {} 
	for k,v in pairs(self.m_model:getNeedRace()) do
		local grid_hero = self:findGameObject("hero_node")
		local hero_item = self:createObj("BountyMissions/bounty_item")
		--local hero_item = GameUtil:createItemElementByData()
		hero_item.transform:SetParent(grid_hero.transform, false)
		local LuaBehaviour = UIUtil.findLuaBehaviour(hero_item.transform)
		local type_node = LuaBehaviour:FindGameObject("type_node")
		type_node:SetActive(false)
		self:updateHeroElement(hero_item, nil, true)
		UIUtil.setScale(hero_item.transform, 0.9,0.9)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_up_img" , false)
		table.insert(SEND_LIST, {key = k, obj = hero_item})
	end
	if self.m_model.m_type ~= 1 then
		local LuaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[#SEND_LIST].obj.transform)
		local type_node = LuaBehaviour:FindGameObject("type_node")
		type_node:SetActive(true)
	end

	local grid_race = self:findGameObject("grid_race")
	RACE_LIST = {}
	for k,v in pairs(self.m_model:getNeedRace()) do
		--if v ~= 0 then
			local race_item = self:createObj("BountyMissions/race_item",grid_race)
			local race_data = GlobalConfig.TYPE_HERO_RACE[v]
			if race_data ~= nil then
				UIUtil.setImg(race_item.transform,race_data.big_race_icon, ResourceUtil:getLanAtlas(),"race_img")
			end
			UIUtil.setScale(race_item.transform, 0.4,0.4)
			UIUtil.setObjectVisible(race_item.transform,false,"yes")
			if v == 0 then
				race_item:SetActive(false)
			end
			table.insert(RACE_LIST, k,{ race = v, iden = false, obj = race_item})
		--end
	end

	for k,v in pairs(SEND_LIST) do
		local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
		local function btns()
			self:updateMsg("check_send_btn",v.key)
			audio:SendEvtUI("Play_UI_HeroSelected")
		end
		LuaBehaviour:RegistButtonClick(btns)
	end

	local evo_condition = self.m_model.evo_condition -- [品质，数量]
	local evo_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_condition[1]]
	--local img_data = nil
	local need_bs = self:findImage("need_bs")
	if need_bs and evo_data ~= nil then
		GameUtil:setLanImgText(self:findRectTransform("need_bs"), evo_data.hero_half_bg)
		self:setText("need_num","0/"..evo_condition[2])--当前需要的特定等级英雄数量
		local img_data = GlobalConfig.QUALITY_FRAME[evo_condition[1]]
		if img_data.hero_star > 0 then
			self:setObjectVisible("star_layout",true)
			for i = 1, 5 do
				local star = self:findGameObject("race_img_" .. i)
				if star then
					self:setImg(img_data.big_frame_add_name, "hero_head_ui", "race_img_" .. i)
					star:SetActive(img_data.hero_star >= i)
				end
			end
		else
			self:setObjectVisible("star_layout",false)
		end
		--if evo_condition[1] % 2 == 0 then
		--	img_data = GlobalConfig.QUALITY_FRAME[evo_condition[1]]
		--end
		--if img_data == nil then
		--	self:setObjectVisible("race_img", false)
		--else
		--	self:setObjectVisible("race_img", true)
		--	self:setImg(img_data.big_frame_add_name, "hero_head_ui", "race_img")
		--end
	end
	self:setTaskCell()
end

function M:updateHeroElement(obj,data,show_add)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local item_img = luaBehaviour:FindGameObject("item_img")
    local camp_img = luaBehaviour:FindGameObject("camp_img")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
	local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
	local top_star_obj = luaBehaviour:FindGameObject("top_star_obj")
	local fate_icon_img = luaBehaviour:FindGameObject("fate_icon_img")
	item_img:SetActive(false)
	quality_up_img:SetActive(false)
	camp_img:SetActive(false)
	top_star_obj:SetActive(false)
	fate_icon_img:SetActive(false)
	local quality_img = LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", "a_ui_currency_ws_kong", "hero_head_ui")
    if show_add then
        no_panel:SetActive(true)
    else
        no_panel:SetActive(true)
    end

    --luaBehaviour:RegistButtonClick() -- 重置事件
end


function M:setTaskCell(task,obj)
	self:setTextByLanKey("reward_name", Language:getTextByKey(self.m_model.m_params.cell_data.cfg.name))
	local desc = Language:getTextByKey(self.m_model.m_params.cell_data.cfg.text)
	self:setTextByLanKey("reward_desc", desc)
	self:setTextByLanKey("life_time", self.m_model.m_params.lifetime)
end

--打开英雄列表
function M:openHeroList()
	self:createLoopScroll()
end

--下阵
function M:setSEND_LIST(data_index)
	self:updateHeroElement(SEND_LIST[data_index].obj, nil, true)
	local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[data_index].obj.transform)
	RACE_LIST[data_index].iden = false
	self:checkCondition()
	self:createLoopScroll()
end


function M:runAnim()
	self:setObjectVisible("bottom_bg", true)
	local sequence = Tweening.DOTween.Sequence()
	sequence:Append(self.bottom_obj.transform:DOLocalMoveY(-258,0.3))
	sequence:SetAutoKill(true)
	local sequence2 = Tweening.DOTween.Sequence()
	sequence2:Append(self.lang_bg.transform:DOLocalMoveY(-138,0.3))
	sequence2:SetAutoKill(true)
end

--刷新槽位
function M:updateSendList(hero_id)
	for k,v in pairs(SEND_LIST) do
		local luaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
	end
	for k,v in pairs(RACE_LIST) do
		local data = self.m_model:getSendSlot()
		if data[k] ~= nil then
			local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[k].obj.transform)
			local function btns()
				self:updateMsg("check_send_btn",SEND_LIST[k].key)
				audio:SendEvtUI("Play_UI_HeroSelected")
			end
			luaBehaviour:RegistButtonClick(btns)
			if k == table.nums(self.m_model.m_task.race_condition) and self.m_model.m_type == 2 then
				local cur_hero_data, cur_hero_cfg = self.m_model:getMercenaryHero(data[k])
				local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cur_hero_data.id, 1, cur_hero_data.oid})
				itemData.quality = cur_hero_data.evo
				self:alterData(SEND_LIST[k].obj,itemData)
				local camp_ = GlobalConfig.TYPE_HERO_RACE[cur_hero_cfg.race]
				local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
				camp_img.gameObject:SetActive(true)
				v.iden = true
			else
				local cur_hero_data = UserDataManager.hero_data:getHeroDataById(data[k])
				local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_hero_data.id)
				local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cur_hero_data.id, 1, cur_hero_data.oid})
				self:alterData(SEND_LIST[k].obj,itemData)
				local camp_ = GlobalConfig.TYPE_HERO_RACE[cur_hero_cfg.race]
				local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
				camp_img.gameObject:SetActive(true)
				v.iden = true
			end
		else
			self:updateHeroElement(SEND_LIST[k].obj, nil, false)
			v.iden = false
		end
	end
	self:checkCondition()
	self:createLoopScroll()
end

--检查任务条件是否满足
function M:checkCondition()
	local num = self.m_model:getCurEvoNum().."/"..self.m_model:getNeedEvoNum() 
	self:setText("need_num",num)--当前需要的特定等级英雄数量
	--
	--for k,v in pairs (RACE_LIST) do
	--	v.iden = false
	--end
	--
	--for k,v in pairs(RACE_LIST) do
	--	for kk,vv in pairs(self.m_model:getSendSlot()) do
	--		if self.m_model.m_type ~= 1 and kk == 2 then
	--			local data,cfg = self.m_model:getMasterHero(vv)
	--			if v.race == cfg.race and v.iden ==false then
	--				v.iden =true
	--				break
	--			end
	--		else
	--			local data,cfg = self.m_model:getHero(vv)
	--			if v.race == cfg.race and v.iden ==false then
	--				v.iden =true
	--				break
	--			end
	--		end
	--	end
	--end

	--iden （用于判断是否是对应种族）
	-- for k,v in pairs (RACE_LIST) do
	-- 	UIUtil.setObjectVisible(v.obj.transform,v.iden,"yes")
	-- 	UIUtil.setObjectVisible(v.obj.transform,v.iden == false,"race_img")
	-- end
	local send_btn = self:findButton("send_btn")
	if self:checkRaceCondition() and self.m_model:checkNumCondition() then
		self:btnSetActive(true,false)
		send_btn.interactable = true
		--self:setObjectVisible("send_gray",false)
	else
		send_btn.interactable = false
		self:btnSetActive(false,true)
		--self:setObjectVisible("send_gray",true)
	end

end

function M:switchTeamTabByProCell(is_on, update_key)
	if is_on then
		self:createLoopScroll2(update_key)
	end
end

--英雄列表
function M:createLoopScroll(data_value)
	local data = self.m_model:getHeros()
	if data_value then
		data = data_value
	end
	local spacing = 0
	if self.m_model.m_type ~= 1 then
		spacing = 40
	end
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
            show_data = data,
			one_line_count = 5,
			spacing = spacing,
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", cell_data)
			end,
			ui_name = self.m_uiName,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, heroOid)
	if obj == nil then 
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return 
	end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	--local ItemNode = luaBehaviour:FindGameObject("ItemNode")--任务名字
	local hero_data,hero_cfg = self.m_model:getShowHeroById(heroOid)
	if hero_data and hero_cfg then
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
		if self.m_model.m_type == 2 then
			itemData.quality = hero_data.evo
			itemData.oid = nil
		end
		--self:alterData(ItemNode,itemData)
		GameUtil:updateItemElementByData(obj, itemData)	
		--GameUtil:updateHeroStarsByQuality(obj, itemData.quality)
		GameUtil:updateHeroInfo(obj, itemData)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isInSlot(heroOid) == true)
	else
			
	end
end

function M:alterData(obj, data )
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local item = luaBehaviour:FindGameObject("item_img")--任务名字
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    item:SetActive(true)
    local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
    local frame = GlobalConfig.HERO_QUALITY_COMMON_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.hero_item_frame, "hero_head_ui")
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "count_text", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel", false)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "camp_img", true)
    local race_data = GlobalConfig.TYPE_HERO_RACE[data.race]
    local type_data = GlobalConfig.TYPE_HERO_PROPERTY[data.item_cfg.type]
    if race_data then
        LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", race_data.race_icon,  ResourceUtil:getLanAtlas())
	end
	local quality_up_img = luaBehaviour:FindGameObject("quality_up_img")
	quality_up_img:SetActive(frame.is_add == true)
	quality_up_img:SetActive(false)
	if frame.is_add == true then
        LuaBehaviourUtil.setImg(luaBehaviour, "quality_up_img", frame.add_img, "hero_head_ui")
    end

    local top_star_obj = luaBehaviour:FindGameObject("top_star_obj")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_star_obj", true)
	local data_value = {quality = data.quality }
	GameUtil:updateHeroInfo(top_star_obj,data_value)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fate_icon_img", false)
	local is_fate = UserDataManager:getHeroIsFates(data.oid)
	if is_fate then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "fate_icon_img", true)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "stars", false)
	end

end
--检查派遣列表是否还有空位
function M:IsHaveVac()
	if #SEND_LIST >= #self.m_model:getSendSlot() then
		return true
	else
		return false	
	end
end

--检查种族条件
function M:checkRaceCondition()
	for k,v in pairs(RACE_LIST) do
		if v.race ~= 0 and v.iden == false then
			return false
		end
	end
	return true
end
--判断是不是点击了佣兵框
function M:isMercenary( data )
	local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[data].obj)
	local type_node = luaBehaviour:FindGameObject("type_node")--type_node
	if type_node.activeInHierarchy then
		if self.m_model.m_type == 2 then
			self:createLoopScroll(self.m_model.mercenarys_ids)
		elseif self.m_model.m_type == 3 then
			self:createLoopScroll(self.m_model.master_ids)
		end
		self.is_Mercenary = true
	end
	
end

function M:createObj(name,parent)
	local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
	return obj
end

function M:updateCurHero()
	local num_text = Language:getTextByKey("new_str_0012").."（".. UserDataManager.hero_data:getHerosCount().."/"..self.m_model:getHeroGrideNum().."）"
	self:setText("list_tips_text",num_text)
end

function M:showQuickHeroSpine()
	local slot_tab = self.m_model:getSlot()
	for k,v in pairs(slot_tab) do
		if v then
			self:updateCurHeroSpine(v)
			break
		end
	end
end

function M:updateCurHeroSpine(id)
	local icon = self.m_model:getHeroBigAnim(id)
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon	
	end
	self:setObjectVisible("hero_spine",true)
	self:setObjectVisible("ying_bg",false)
	local pos_x = -300
	local pos_y = -40
	local play_img = self:findGameObject("hero_spine")
 	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos =self.m_model:getSpinePos(id)
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

return M