local M = class("JuBaoShanHeroSelectPopView",LikeOO.OOPopBase)

M.m_uiName = "JuBaoShan/JuBaoShanHeroSelectPop"
M.m_size_type = 2

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

local __BuildConfig = {
	[2] = { imgName = "a_jbs_qianzhuang" },
	[8] = { imgName = "a_jbs_jianghugaoshi" },
	[9] = { imgName = "a_jbs_xiakexunlianying" },
	[10] = { imgName = "a_jbs_jiaozigongfang" },
	[11] = { imgName = "a_jbs_danlu" },
	[12] = { imgName = "a_jbs_jieyuankezhan" },
}

local SEND_LIST = {} --槽位缓存 {key = k, obj = hero_item}
local RACE_LIST = {} --需要种族类型缓存 { race = v, iden = false, obj = race_item}

function M:onEnter()	
	self.cacheSpineName = ""
	self.slotLockInfo = {
		[1] = 
		{
			lock = true
		},
		[2] =
		{
			lock = true
		},
		[3] =
		{
			lock = true
		},
		[4] =
		{
			lock = true
		},
	}
	self.m_camp_type = 1
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local item = self:findGameObject(v.btn)
		if self.m_model:hasRace(v.race) then
			UIUtil.setObjectVisible(item.transform, self.m_model.selectType_index == i,"UI_ShareLv_Xuanze_01")
			UIUtil.addToggleListener(tog_btn, function(is_on, data)
				if is_on then
					self:updateMsg("tab_btn",{index = data,value = __TAB_BTN_NODE[data]})
					UIUtil.setObjectVisible(item.transform, true,"UI_ShareLv_Xuanze_01")
				else
					UIUtil.setObjectVisible(item.transform, false,"UI_ShareLv_Xuanze_01")
				end
			end, i, self.m_uiName)
		else
			UIUtil.setObjectVisible(item, false)
		end
	end
	
	local common = ConfigManager:getCfgByName("common")
	self:setTextByLanKey("hero_num", Language:getTextByKey("coach_str_0017")..": "..#self.m_model.hero_list)
	local lv = self.m_model.cell_data.lv;
	if lv < 0 then
		self:setTextByLanKey("title_name_txt", Language:getTextByKey(self.m_model.cell_config.name))
	else
		self:setTextByLanKey("title_name_txt", Language:getTextByKey(self.m_model.cell_config.name).." "..lv..Language:getTextByKey("new_str_0428"))
	end
    local item_data,item_cfg = UserDataManager.item_data:getItemDataById(common[324].value[2])
    self:setImg(item_cfg.icon, "item_icon", "order_img") --悬赏
	self.left_icon = self:findImage("left_icon");
	self:creatItem()
	self.bottom_obj = self:findGameObject("bottom_bg")
	self.lang_bg = self:findGameObject("lang_bg")
	local send_btn = self:findButton("send_btn")
	send_btn.interactable = false
	self:updateCurHero()
	self:setObjectVisible("hero_spine",false)
	self:setTextByLanKey("common_title_text", "bounty_str_0013")
	self:setTextByLanKey("tips_txt","tid#credit_dicel_origin_4")
	self:setTextByLanKey("reward_hero_name", "bounty_str_0022")
	self:setObjectVisible("tips_txt",false)
	self:setTextByLanKey("ok_text","bounty_str_0013");
	self.info_btn = self:findGameObject("info_btn")
	self.dispatch = self:findGameObject("send_btn")
	self.one_keydispatch = self:findGameObject("one_keydispatch")
	--if self.m_model.m_cell_type == 2 then
	--	self:setObjectVisible("one_keydispatch",false)
	--end
	self:btnSetActive(false,true)
	self:updateSendList();
	self.reward1 = self:findGameObject("reward1");
	self.rewardObj = self:findGameObject("my_reward");
	self.reward1_localPos_x = self.reward1.transform.localPosition.x
	self:setTextByLanKey("yijian_ok_text", "paiqian_yijian_text" )
	--刷新奖励展示
	self:refreshReward();
end


function M:refreshReward()
	self.m_model:updateRewardData()
	if _G.next(self.m_model.m_reward_data) then
		--显示奖励
		if self.m_model.cell_data.gift ~= nil and _G.next(self.m_model.cell_data.gift) ~= nil then
			self.rewardObj:SetActive(true)
			local data = RewardUtil:getProcessRewardData(self.m_model.cell_data.gift[1])
			GameUtil:updateItemElementByData(self.rewardObj, data, true)
		else
			self.rewardObj:SetActive(false);
		end
		
		if self.m_model.m_cell_type ~= 2 then
			self:setObjectVisible("info_btn",false)
		end
		--4 表示建筑
		if self.m_model.m_cell_type == 4 then
			self:setObjectVisible("reward_txt",false)
			self:setObjectVisible("reward1_txt",true)
			self:setObjectVisible("reward2_txt",true)
			if self.m_model.cell_data.id == 8 then
				self:setObjectVisible("reward1",true)
				self:setObjectVisible("reward2",true)
				local data = RewardUtil:getProcessRewardData(self.m_model.m_reward_data)
				local rewardStr = "       x"..data.data_num or 1;
				local bonus_data = RewardUtil:getProcessRewardData(self.m_model.m_bonus_data)
				local once_num = bonus_data.data_num/self.m_model.max_solt_num
				local bonus_rewardStr = "       x"..math.floor(once_num) or 1;

				local reward1 = self:findGameObject("reward1");
				GameUtil:updateItemElementByData(reward1, data, false)
				local reward2 = self:findGameObject("reward2");
				GameUtil:updateItemElementByData(reward2, bonus_data, false)
				--当前等级每掷%d 骰子可获得%s,当侠客派遣满时额外获得 %s
				local award = self.m_model.cell_config.param.award or 0;
				if award <= 0 then
					award = 1;
				end
				self:setTextByLanKey("reward1_txt",self.m_model.cell_config.Architectural_1, award, rewardStr);
				self:setTextByLanKey("reward2_txt",self.m_model.cell_config.Architectural_2, bonus_rewardStr);
			else
				self:setObjectVisible("reward1",true)
				self:setObjectVisible("reward2",false)
				local data = RewardUtil:getProcessRewardData(self.m_model.m_reward_data)
				local rewardStr = "       x"..data.data_num;
				GameUtil:updateItemElementByData(self.reward1, data, false)
				--当前等级每掷%d 骰子可获得%s,当侠客派遣满时额外获得 %s
				local award = self.m_model.cell_config.param.award or 0
				if award <= 0 then
					award = 1;
				end
				if self.m_model.cell_data.id == 12 then
					award = self.m_model.cell_data.max_award or 0
					local slot = self.m_model.cell_config.slot;
					local hero = 0;
					for i, v in pairs(self.m_model.solt_players) do
						if v ~= "" then
							hero = hero + 1;
						end
					end
					local reduce = 0;
					for i, v in pairs(slot) do
						if hero >= i then
							reduce = reduce + v[3] or 0
						end
					end
					award = award - reduce;
					if award <= 0 then
						award = 1;
					end
				end
				if award > 9 then
					local localPos = self.reward1.transform.localPosition
					localPos.x = self.reward1_localPos_x + 8;
					self.reward1.transform.localPosition = localPos;
				end
				self:setTextByLanKey("reward1_txt",self.m_model.cell_config.Architectural_1, award, rewardStr);
				self:setTextByLanKey("reward2_txt",self.m_model.cell_config.Architectural_2);
			end
		else
			self:setObjectVisible("reward_txt",true)
			self:setObjectVisible("reward1_txt",false)
			self:setObjectVisible("reward2_txt",false)
			self:setObjectVisible("reward1",false)
			self:setObjectVisible("reward2",false)
			local num = self.m_model.m_reward_data[1] or 0
			if num > 0 then
				local reward_txt = self.m_model.m_reward_data[1]..Language:getTextByKey("jubaoShan_str_017");
				self:setTextByLanKey("reward_txt","jubaoShan_str_018", reward_txt);
			else
				self:setTextByLanKey("reward_txt","jubaoShan_str_020");
			end
		end
	else
		self:setObjectVisible("reward_txt",true)
		self:setObjectVisible("reward1_txt",false)
		self:setObjectVisible("reward2_txt",false)
		self:setObjectVisible("reward1",false)
		self:setObjectVisible("reward2",false)
		if self.m_model.m_cell_type == 2 then
			self:setTextByLanKey("reward_txt","jubaoShan_str_020");
		else
			self:setObjectVisible("reward_txt",false)
		end
	end
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
	--槽位显示
	SEND_LIST = {}
	for i = 1,self.m_model.slotNum do
		local grid_hero = self:findGameObject("hero_node")
		local hero_item = self:findGameObject("bounty_item"..i)
		hero_item.transform:SetParent(grid_hero.transform, false)
		local LuaBehaviour = UIUtil.findLuaBehaviour(hero_item.transform)
		local type_node = LuaBehaviour:FindGameObject("type_node")
		type_node:SetActive(false)
		self:updateHeroElement(hero_item, nil, true)
		UIUtil.setScale(hero_item.transform, 0.9,0.9)
		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "quality_up_img" , false)
		table.insert(SEND_LIST, {key = i, obj = hero_item})
	end

	if self.m_model.slotNum < 4 then
		for i = 4, self.m_model.slotNum+1,-1 do
			local hero_item = self:findGameObject("bounty_item"..i)
			hero_item:SetActive(false);
			local need_item = self:findGameObject("need_slot"..i)
			need_item:SetActive(false);
		end
	end
	
	--种族列表
	RACE_LIST = {}
	local race_index = 0;
	if self.m_model:hasRace(-1) then
		local grid_race = self:findGameObject("grid_race")
		grid_race:SetActive(false);
	else
		--种族图标
		for k,v in pairs(self.m_model:getNeedRace()) do
			if v > 0 then
				race_index = race_index + 1;
				local race_item = self:findGameObject("race_item"..race_index)
				race_item:SetActive(true);
				local race_data = GlobalConfig.TYPE_HERO_RACE[v]
				if race_data ~= nil then
					UIUtil.setImg(race_item.transform,race_data.big_race_icon, ResourceUtil:getLanAtlas(),"race_img")
				end
				UIUtil.setScale(race_item.transform, 0.5,0.5)
				UIUtil.setObjectVisible(race_item.transform,false,"yes")
				table.insert(RACE_LIST,{ race = v, iden = false, obj = race_item})
			end
		end
	end
	

	for k,v in pairs(SEND_LIST) do
		local LuaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
		local function btns()
			self:updateMsg("check_send_btn",v.key)
			audio:SendEvtUI("Play_UI_HeroSelected")
		end
		LuaBehaviour:RegistButtonClick(btns)
	end
	
	self:updateCellLv();
	--self:setTaskCell()
end



function M:updateCellLv()
	for i = 1,self.m_model.slotNum do
		local evo_data_config = self.m_model.evo_condition[i]
		--Logger.logError(evo_data_config," 更新数据 ~~~~~~~~~~~~~~ ")
		--Logger.logError(self.m_model.cell_data.lv," 当前等级 ~~~~~~~~~~~~~~ ")
		local need_lv = evo_data_config[1]
		local slotObj = SEND_LIST[i];
		local luaBehaviour = UIUtil.findLuaBehaviour(slotObj.obj.transform)
		if self.m_model.cell_data.lv < need_lv then
			self.slotLockInfo[i].lock = true;
			--未解锁
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"have_panel", false);
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_image", true);
		else
			self.slotLockInfo[i].lock = false;
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"have_panel", true);
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"lock_image", false);
		end

		local evo_data = GlobalConfig.HERO_QUALITY_COMMON_SETTING[evo_data_config[2]]
		local name = "need_slot"..i;
		local img_data = nil;
		local need_bs = self:findImage(name)
		if need_bs and evo_data ~= nil then
			if self:hasAdd(evo_data_config[2]) then
				img_data = GlobalConfig.QUALITY_FRAME[evo_data_config[2]]
			end
			if img_data == nil then
				self:setObjectVisible("race_img"..i, false)
			else
				self:setObjectVisible("race_img"..i, true)
				self:setImg(img_data.big_frame_add_name, "hero_head_ui", "race_img"..i)
			end
			GameUtil:setLanImgText(self:findRectTransform(name), evo_data.hero_half_bg)
		end
	end
end


function M:hasAdd( evo )
	if evo == 4 or evo == 6 or evo == 8 or evo == 9 or evo == 11 or evo == 12 or evo == 13 then
		return true;
	end
	return false;
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
function M:updateSendList()
	local cell_ui_config = __BuildConfig[self.m_model.cell_data.id]
	if cell_ui_config ~= nil then
		self.left_icon.sprite = ResourceUtil:GetSprite(cell_ui_config.imgName,"maze_stage_ui")
	end
	--槽位上的英雄
	local solt_players = self.m_model:getSendSlot()
	for k,v in pairs(solt_players) do
		--槽位数据
		if solt_players[k] ~= nil and solt_players[k] ~= "" then
			--找到槽位
			local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[k].obj.transform)
			local function btns()
				self:updateMsg("check_send_btn",SEND_LIST[k].key)
				audio:SendEvtUI("Play_UI_HeroSelected")
			end
			luaBehaviour:RegistButtonClick(btns)
			--获取英雄数据
			local cur_hero_data = UserDataManager.hero_data:getHeroDataById(solt_players[k])
			--获取英雄配置
			local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_hero_data.id)
			--获取道具人物头像数据
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cur_hero_data.id, 1, cur_hero_data.oid})
			--设置头像到槽位上
			self:alterData(SEND_LIST[k].obj,itemData)
			--设置种族信息
			local camp_ = GlobalConfig.TYPE_HERO_RACE[cur_hero_cfg.race]
			local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
			camp_img.gameObject:SetActive(true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isInSlot(solt_players[k]) == true)
		else
			self:updateHeroElement(SEND_LIST[k].obj, nil, false)
		end
	end
	self:checkCondition()
	self:createLoopScroll()
end

--检查任务条件是否满足
function M:checkCondition()
	local send_btn = self:findButton("send_btn")
	--mode == 2 撤回
	if self.m_model:isChangeHeroList() == false then
		self:setTextByLanKey("ok_text","jubaoShan_str_003");
		send_btn.interactable = true
	else
		self:setTextByLanKey("ok_text","bounty_str_0013");
		if self.m_model:getSlotHeroNumNow() > 0 then
			self:btnSetActive(true,false)
			send_btn.interactable = true
			--self:setObjectVisible("send_gray",false)
		else
			send_btn.interactable = false
			self:btnSetActive(false,true)
			--self:setObjectVisible("send_gray",true)
		end
	end
end

function M:switchTeamTabByProCell(is_on, update_key)
	if is_on then
		self:createLoopScroll2(update_key)
	end
end

--英雄列表
function M:createLoopScroll(data_value)
	local loopscroll = self:findGameObject("list_scroll")
	loopscroll:SetActive(true)
	self:setObjectVisible("tips_txt",false)
	local data = self.m_model:filtrateHero(self.m_model.m_cur_race)
	if data_value then
		data = data_value
	end
	if #data > 0 then
		local spacing = 0
		if self.m_model.m_type ~= 1 then
			spacing = 40
		end
		if self.m_loop_scroll_view == nil then
			self:setObjectVisible("race_toggle_bg",true)
			self:setObjectVisible("tips_txt",false)
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
	else
		local loopscroll = self:findGameObject("list_scroll")
		loopscroll:SetActive(false);
		--self:setObjectVisible("race_toggle_bg",false)
		self:setObjectVisible("tips_txt",true)
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
	local hero_data,hero_cfg = self.m_model:getHero(heroOid)
	if hero_data and hero_cfg then
		local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
		if self.m_model.m_type == 2 then
			itemData.quality = hero_data.evo
			itemData.oid = nil
		end
		GameUtil:updateItemElementByData(obj, itemData)
		--GameUtil:updateHeroStarsByQuality(obj, itemData.quality)
		GameUtil:updateHeroInfo(obj, itemData)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "duigoudi_img", self.m_model:isInSlot(heroOid) == true)
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
	--quality_up_img:SetActive(frame.is_add == true)
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
	local slot_tab = self.m_model:getSendSlot()
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