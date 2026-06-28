local M = class("WorldMapRewardSendView",LikeOO.OOPopBase)

M.m_uiName = "WorldMap/WorldMapReward/WorldMapHeroSelectPop"
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
	if UserDataManager.active_double_id ~= 0 then
		local num = m_reward_obj.transform.childCount
		for i = 1, num do
			local reward_cell = m_reward_obj.transform:GetChild(i-1)
			local LuaBehaviour = UIUtil.findLuaBehaviour(reward_cell)
			if LuaBehaviour then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"double_earn", true)
			end
		end
	end
	self:creatItem()
	self.bottom_obj = self:findGameObject("bottom_bg")
	self.lang_bg = self:findGameObject("lang_bg")
	local send_btn = self:findButton("send_btn")
	send_btn.interactable = false
	--self:setObjectVisible("send_gray",true)
	self:updateCurHero()
	self:setObjectVisible("hero_spine",false)
	--self:setObjectVisible("ying_bg",true)
	--self:setObjectVisible("bottom_bg", false)
	self:setTextByLanKey("close_title_text", "bounty_str_0013")

	self.dispatch = self:findGameObject("send_btn")
	self.one_keydispatch = self:findGameObject("one_keydispatch")

	self:btnSetActive(false,true)
	self:createLoopScroll()
end

function M:btnSetActive(dispatchActive,one_keydispatchActive)
	self.dispatch:SetActive(dispatchActive)
	self.one_keydispatch:SetActive(one_keydispatchActive)

end

--派遣名单
function M:creatItem()
	local grid_hero = self:findGameObject("hero_node")
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

		LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "add_img" , false)
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

	self:setTaskCell()
end

function M:setTaskCell(task,obj)

	
	self:setTextByLanKey("reward_name", Language:getTextByKey(self.m_model.m_params.cell_data.cfg.name))

	local desc = "悬赏任务描述:"
	desc = desc .. Language:getTextByKey(self.m_model.m_params.cell_data.cfg.text)
	self:setTextByLanKey("reward_desc", desc)
	
	self:setTextByLanKey("life_time", self.m_model.m_params.lifetime)
	
	--life_time_text.text = self.m_model:checkDeadTime(task.data.expire_ts) 


	-- local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	-- local name = luaBehaviour:FindText("offer_name_text")--任务名字
	-- name.text = Language:getTextByKey(task.cfg.name)
	-- local data = GlobalConfig.BOUNTY_RANK[task.cfg.rank]
	-- --name.color = data.RGBA
	-- --任务奖励
	-- local drop = task.data.reward or {}
	-- local reward_node = luaBehaviour:FindGameObject("reward_obj") 
	-- UIUtil.destroyAllChild(reward_node.transform)
	-- local rewadd_item = GameUtil:createItemElement(drop[1], true, true, nil)
	-- rewadd_item.transform:SetParent(reward_node.transform, false)
	-- --local count_text = luaBehaviour:FindText("count_text")
	-- local tim_text = luaBehaviour:FindText("time_text")
	-- --local slider = luaBehaviour:FindGameObject("slider")
	-- --local doing_img = luaBehaviour:FindGameObject("doing_img")
	-- local fill = luaBehaviour:FindImage("Fill")
	-- local reward_btn = luaBehaviour:FindGameObject("reward_btn")
	-- --local send_btn = luaBehaviour:FindGameObject("send_btn")
	-- local life_time_text = luaBehaviour:FindText("life_time_text") 
	-- --count_text.gameObject:SetActive(false)
	-- tim_text.gameObject:SetActive(false)
	-- life_time_text.gameObject:SetActive(false)
	-- --slider:SetActive(false)
	-- reward_btn:SetActive(false)
	-- --send_btn:SetActive(false)
	-- --doing_img:SetActive(false)
	-- --任务状态
	-- if task.data.quest_status == 0 then --未派遣
	-- 	local tim = GameUtil:formatTimeBySecond(task.cfg.duration_time*60)
	-- 	--count_text.text = Language:getTextByKey("new_str_0123")..tim
	-- 	life_time_text.text = self.m_model:checkDeadTime(task.data.expire_ts) 
	-- 	life_time_text.gameObject:SetActive(true)
	-- 	--count_text.gameObject:SetActive(true)
	-- 	if self.m_model.cur_type == 2 then
	-- 		--send_btn:SetActive(not self.m_model:chechMasterStatue())
	-- 	else
	-- 		--send_btn:SetActive(true)
	-- 	end
	-- elseif task.data.quest_status == 1 then --派遣中
	-- 	if task.count_down then
	-- 		if task.count_down <= 0 then
	-- 			tim_text.text = Language:getTextByKey("new_str_0063")
	-- 			tim_text.gameObject:SetActive(true)
	-- 			doing_img:SetActive(false)
	-- 			reward_btn:SetActive(true)
	-- 			--slider:SetActive(true)
	-- 			fill.fillAmount = 1
	-- 			task.data.quest_status = 2
	-- 		else
	-- 			local ratio = task.count_down/(task.cfg.duration_time*60)
	-- 			fill.fillAmount = 1- ratio
	-- 			tim_text.text = GameUtil:formatTimeBySecond(task.count_down)
	-- 			tim_text.gameObject:SetActive(true)
	-- 			--slider:SetActive(true)
	-- 			--doing_img:SetActive(true)
	-- 			if self.m_model.cur_type == 2 and  self.m_model:chechMasterStatue() == true then
	-- 				life_time_text.text = task.data.name 
	-- 				life_time_text.gameObject:SetActive(true)
	-- 			end
	-- 		end
	-- 	end
	-- elseif task.data.quest_status == 2 then --待领取 	
	-- 	tim_text.text =  Language:getTextByKey("new_str_0063")
	-- 	tim_text.gameObject:SetActive(true)
	-- 	if self.m_model.cur_type == 2 then
	-- 		reward_btn:SetActive(not self.m_model:chechMasterStatue())
	-- 	else
	-- 		reward_btn:SetActive(true)
	-- 	end
	-- 	--slider:SetActive(true)
	-- 	fill.fillAmount = 1
	-- end
	-- local star_tab = {}
	-- local st = luaBehaviour:FindGameObject("star_1")
	-- st:SetActive(false)
	-- for i = 1, 6 do
	-- 	local st = luaBehaviour:FindGameObject("star_"..i)
	-- 	st:SetActive(false)
	-- 	table.insert(star_tab, i, st)
	-- end
	-- for k,v in pairs(star_tab) do
	-- 	if task.cfg.rank >= k then
	-- 		v:SetActive(true)
	-- 	end
	-- end
end

--打开英雄列表
function M:openHeroList()
	--self:setObjectVisible("bottom_bg", true)
	self:createLoopScroll()
	--self:runAnim()

	-- for k,v in pairs(RACE_LIST) do
	-- 	--if v.race == cur_hero_cfg.race then
	-- 		self:createLoopScroll(v.race)
	-- 	--end
	-- end
end

--下阵
function M:setSEND_LIST(data_index)
	CommonUIUtil:updateHeroElementAdd(SEND_LIST[data_index].obj, nil, true)
	local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[data_index].obj.transform)
	LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
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
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
	end
	
	for k,v in pairs(RACE_LIST) do
		local data = self.m_model:getSendSlot()
		if data[k] ~= nil then
			local luaBehaviour = UIUtil.findLuaBehaviour(SEND_LIST[k].obj.transform)
			
			local cur_hero_data = UserDataManager.hero_data:getHeroDataById(data[k])
			local cur_hero_cfg = UserDataManager.hero_data:getHeroConfigByCid(cur_hero_data.id)
			
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, cur_hero_data.id, 1, cur_hero_data.oid})
			CommonUIUtil:updateHeroElementByData(SEND_LIST[k].obj, itemData)

			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
			local camp_ = GlobalConfig.TYPE_HERO_RACE[cur_hero_cfg.race]
			local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon, ResourceUtil:getLanAtlas())
			v.iden = true
		else
			CommonUIUtil:updateHeroElementAdd(SEND_LIST[k].obj, nil, false)
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
	for k,v in pairs (RACE_LIST) do
		UIUtil.setObjectVisible(v.obj.transform,v.iden,"yes")
		UIUtil.setObjectVisible(v.obj.transform,v.iden == false,"race_img")
	end
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
function M:createLoopScroll()

	local data = self.m_model:getHeros(RACE_LIST)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
            show_data = data,
            one_line_count = 3,
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
		self.m_loop_scroll_view:reloadData(data,true)
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
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
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