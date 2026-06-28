local M = class("BountyMissionsSendView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissionsSend"
M.m_size_type = 2
M.m_iphoneXAdapter = true
local __TAB_BTN_NODE = {
	{btn = "martial_all_toggle", name = "martial_all_text", lan_text = "new_str_0065"},
	{btn = "martial_1_toggle", name = "martial_1_text", lan_text = "new_str_0144"},
	{btn = "martial_2_toggle", name = "martial_2_text", lan_text = "new_str_0145"},
	{btn = "martial_3_toggle", name = "martial_3_text", lan_text = "new_str_0143"},
	{btn = "martial_4_toggle", name = "martial_4_text", lan_text = "new_str_0142"},
	{btn = "martial_5_toggle", name = "martial_5_text", lan_text = "new_str_0237"},
	{btn = "martial_6_toggle", name = "martial_6_text", lan_text = "new_str_0238"},
}

local SEND_LIST = {} --槽位缓存 {key = k, obj = hero_item}
local RACE_LIST = {} --需要种族类型缓存 { race = v, iden = false, obj = race_item}

function M:onEnter()	
	self.cacheSpineName = ""
	self.m_camp_type = 1
	for i,v in ipairs(__TAB_BTN_NODE) do
		local tog_btn = self:findToggle(v.btn)
		local lan_text = "new_str_0065"
		if i > 1 then
			lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
		end
		self:setTextByLanKey(v.name, lan_text)
		UIUtil.addToggleListener(tog_btn, function(is_on, data) 
			if is_on then 
				self:updateMsg("tab_btn",data) 
			end 
		end, i, self.m_uiName)
	end
	self:setTextByLanKey("hero_num", Language:getTextByKey("coach_str_0017")..": "..#self.m_model.hero_list)
	self:setTextByLanKey("title_name_text", self.m_model.m_task.name)
	local data = GlobalConfig.BOUNTY_RANK[self.m_model.m_task.rank]
	self:setTextColor("title_name_text",data.RGBA)
	self:setTextByLanKey("msg_text", self.m_model.m_task.text)
	--奖励
	local m_reward_obj = self:findGameObject("reward_obj")
	local drop = self.m_model.m_reward or {}
	GameUtil:createRewards(m_reward_obj.transform, drop, true, true, nil, 1)
	
	self:creatItem()
	self.bottom_obj = self:findGameObject("bottom_bg")
	self.lang_bg = self:findGameObject("lang_bg")
	local send_btn = self:findButton("send_btn")
	send_btn.interactable = false
	self:setObjectVisible("send_gray",true)
	self:updateCurHero()
	self:setObjectVisible("hero_spine",false)
	self:setObjectVisible("ying_bg",true)
	self:setObjectVisible("bottom_bg", false)
	self:setTextByLanKey("close_title_text", "bounty_str_0013")
end

--派遣名单
function M:creatItem()
	local grid_hero = self:findGameObject("grid_hero")
	SEND_LIST = {} 
	for k,v in pairs(self.m_model:getNeedRace()) do
		local hero_item = CommonUIUtil:createHeroElement()
		hero_item.transform:SetParent(grid_hero.transform, false)
		CommonUIUtil:updateHeroElementAdd(hero_item, nil, true)
		UIUtil.setScale(hero_item.transform, 0.8,0.8)
		if self.m_guide_cell == nil then
			self.m_guide_cell = hero_item
		end
		local LuaBehaviour = UIUtil.findLuaBehaviour(hero_item.transform)
		local function btns()
			self:updateMsg("check_send_btn",k)
		end
		LuaBehaviour:RegistButtonClick(btns)
		table.insert(SEND_LIST, {key = k, obj = hero_item})
	end

	local grid_race = self:findGameObject("grid_race")
	RACE_LIST = {}
	for k,v in pairs(self.m_model:getNeedRace()) do
		local race_item = self:createObj("BountyMissions/race_item",grid_race)
		local race_data = GlobalConfig.TYPE_HERO_RACE[v]
		UIUtil.setImg(race_item.transform,race_data.big_race_icon, ResourceUtil:getLanAtlas(),"race_img")
		UIUtil.setScale(race_item.transform, 0.6,0.6)
		UIUtil.setObjectVisible(race_item.transform,false,"yes")
		table.insert(RACE_LIST, k,{ race = v, iden = false, obj = race_item})
	end

	local evo_condition = self.m_model.m_task.evo_condition -- [品质，数量]
	local evo_data = GlobalConfig.QUALITY_COMMON_SETTING[evo_condition[1]]
	local need_bs = self:findImage("need_bs")
	if need_bs then
		self:setImg(evo_data.icon,"common_ui","need_bs")
		self:setText("need_num","0/"..evo_condition[2])--当前需要的特定等级英雄数量
	end
end

--打开英雄列表
function M:openHeroList()
	self:setObjectVisible("bottom_bg", true)
	self:createLoopScroll()
	self:runAnim()
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
function M:updateSendList(refresh_Spine)
	for k,v in pairs(SEND_LIST) do
		CommonUIUtil:updateHeroElementAdd(v.obj, nil, true)
	end
	--更新槽位
	for k,v in pairs(SEND_LIST) do
		if self.m_model:getHeroByIndex(k) ~= nil then	
			local data,cfg = self.m_model:getHeroByIndex(k)
			local luaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "have_panel" , true)
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel" , false)
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
			CommonUIUtil:updateHeroElementByData(v.obj, itemData)
			local camp_ = GlobalConfig.TYPE_HERO_RACE[cfg.race]
			local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon, ResourceUtil:getLanAtlas())
		end
	end
	self:checkCondition()
	self:createLoopScroll()
	if refresh_Spine then
		local solt_tab = self.m_model:getSlot()
		local a_num = table.nums(solt_tab)
		if a_num >= 1 then
			for k,v in pairs(solt_tab) do
				self:updateCurHeroSpine(v)
				break
			end
		else
			self:setObjectVisible("hero_spine",false)
			self:setObjectVisible("ying_bg",true)
			self.cacheSpineName = ""
		end
	end
end

--检查任务条件是否满足
function M:checkCondition()
	local num = self.m_model:getCurEvoNum().."/"..self.m_model:getNeedEvoNum() 
	self:setText("need_num",num)--当前需要的特定等级英雄数量

	for k,v in pairs (RACE_LIST) do
		v.iden = false
	end

	for k,v in pairs(RACE_LIST) do
		for kk,vv in pairs(self.m_model:getSendSlot()) do
			if self.m_model.m_type ~= 1 and kk == 2 then
				local data,cfg = self.m_model:getMasterHero(vv)
				if v.race == cfg.race and v.iden ==false then
					v.iden =true
					break
				end
			else
				local data,cfg = self.m_model:getHero(vv)
				if v.race == cfg.race and v.iden ==false then
					v.iden =true
					break
				end
			end
		end
	end

	--iden （用于判断是否是对应种族）
	for k,v in pairs (RACE_LIST) do
		UIUtil.setObjectVisible(v.obj.transform,v.iden,"yes")
	end
	local send_btn = self:findButton("send_btn")
	if self:checkRaceCondition() and self.m_model:checkNumCondition() then
		send_btn.interactable = true
		self:setObjectVisible("send_gray",false)
	else
		send_btn.interactable = false
		self:setObjectVisible("send_gray",true)
	end

end

function M:switchTeamTabByProCell(is_on, update_key)
	if is_on then
		self:createLoopScroll2(update_key)
	end
end

--英雄列表
function M:createLoopScroll(cur_race_key)
	if cur_race_key then
		self.m_camp_type = cur_race_key 
	end
	self.m_model:getHeroByRace(self.m_camp_type - 1)
	local data = self.m_model.Filtrate_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", cell_data)
			end
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
	local hero_data,hero_cfg = self.m_model:getHero(heroOid)
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
	CommonUIUtil:updateHeroElementByData(obj, itemData)
	CommonUIUtil:updateHeroLvByData(obj, hero_data)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	if luaBehaviour then
		local duigoudi_img = luaBehaviour:FindGameObject("duigou_img")
		local in_team_flag = self.m_model:isInSlot(heroOid)
		duigoudi_img:SetActive(in_team_flag)
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
		if v.iden == false then
			return false
		end
	end
	return true
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