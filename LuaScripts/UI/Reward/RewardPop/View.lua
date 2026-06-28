local M = class("RewardPopView",LikeOO.OOPopBase)

M.m_uiName = "Reward/RewardPop"
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
	-- for i,v in ipairs(__TAB_BTN_NODE) do
	-- 	local tog_btn = self:findToggle(v.btn)
	-- 	local lan_text = "new_str_0065"
	-- 	if i > 1 then
	-- 		lan_text = GlobalConfig.TYPE_HERO_RACE[i-1].name
	-- 	end
	-- 	self:setTextByLanKey(v.name, lan_text)
	-- 	UIUtil.addToggleListener(tog_btn, function(is_on, data) 
	-- 		if is_on then 
	-- 			self:updateMsg("tab_btn",data) 
	-- 		end 
	-- 	end, i, self.m_uiName)
	-- end
	-- self:setTextByLanKey("hero_num", Language:getTextByKey("coach_str_0017")..": "..#self.m_model.hero_list)
	-- self:setTextByLanKey("title_name_text", self.m_model.m_task.name)
	-- local data = GlobalConfig.BOUNTY_RANK[self.m_model.m_task.rank]
	-- self:setTextColor("title_name_text",data.RGBA)
	-- self:setTextByLanKey("msg_text", self.m_model.m_task.text)
	-- --奖励
	-- local m_reward_obj = self:findGameObject("reward_obj")
	-- local drop = self.m_model.m_reward or {}
	-- GameUtil:createRewards(m_reward_obj.transform, drop, true, true, nil, 1)
	
	-- self:creatItem()
	-- self.bottom_obj = self:findGameObject("bottom_bg")
	-- self.lang_bg = self:findGameObject("lang_bg")
	-- local send_btn = self:findButton("send_btn")
	-- send_btn.interactable = false
	-- --self:setObjectVisible("send_gray",true)
	-- self:updateCurHero()
	-- self:setObjectVisible("hero_spine",false)
	-- --self:setObjectVisible("ying_bg",true)
	-- --self:setObjectVisible("bottom_bg", false)
	-- self:setTextByLanKey("close_title_text", "bounty_str_0013")

	-- self.dispatch = self:findGameObject("send_btn")
	-- self.one_keydispatch = self:findGameObject("one_keydispatch")

	-- self:btnSetActive(false,true)
	self:createLoopScroll()
end


--刷新槽位
function M:updateSendList(refresh_Spine)
	for k,v in pairs(SEND_LIST) do


		CommonUIUtil:updateHeroElementAdd(v.obj, nil, true)
		local luaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
	end
	--更新槽位
	for k,v in pairs(SEND_LIST) do
		if self.m_model:getHeroByIndex(k) ~= nil then	
			local data,cfg = self.m_model:getHeroByIndex(k)
			local luaBehaviour = UIUtil.findLuaBehaviour(v.obj.transform)
			-- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "have_panel" , true)
			-- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_panel" , false)
			local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
			CommonUIUtil:updateHeroElementByData(v.obj, itemData)
			
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "add_img" , false)
			local camp_ = GlobalConfig.TYPE_HERO_RACE[cfg.race]
			local camp_img = LuaBehaviourUtil.setImg(luaBehaviour,"camp_img", camp_.race_icon,  ResourceUtil:getLanAtlas())
		end
	end
	self:checkCondition()
	self:createLoopScroll()
	-- if refresh_Spine then
	-- 	local solt_tab = self.m_model:getSlot()
	-- 	local a_num = table.nums(solt_tab)
	-- 	if a_num >= 1 then
	-- 		for k,v in pairs(solt_tab) do
	-- 			--self:updateCurHeroSpine(v)
	-- 			break
	-- 		end
	-- 	else
	-- 		self:setObjectVisible("hero_spine",false)
	-- 		self:setObjectVisible("ying_bg",true)
	-- 		self.cacheSpineName = ""
	-- 	end
	-- end
end


--英雄列表
function M:createLoopScroll(cur_race_key)
	if cur_race_key then
		self.m_camp_type = cur_race_key 
	end
	self.m_model:getHeroByRace(self.m_camp_type - 1)
	local data = self.m_model.cur_logData.data.log --self.m_model.hero_list
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
            --one_line_count = 1,
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
function M:updateHeroContent(obj, cell_data)

	local luaBehaviour = obj:GetComponent("LuaBehaviour")

	local task_tim = UserDataManager:getServerTime() - cell_data.ctime--任务进行的时间

	 local count_down = self.m_model.cfg.duration_time * 60 - task_tim

	-- tim_text.text = GameUtil:formatTimeBySecond(task.count_down)
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", GameUtil:formatTimeBySecond(count_down) )

	
	local des_value = Language:getTextByKey(cell_data.params[2])

	local cur_des_value = string.split(des_value, "]")


	local bounty_eventdes = ConfigManager:getCfgByName("bounty_eventdes")

 
	local random_des = Language:getTextByKey(bounty_eventdes[cell_data.params[3]].text)

	local card_hero = ConfigManager:getCfgByName("card_hero")
    local card_hero_item = card_hero[UserDataManager.hero_data:getHeroDataById(cell_data.params[1]).id]

    local item_cfg = UserDataManager.hero_data:getHeroConfigByCid(card_hero_item.hero_id)

	local hero_name = Language:getTextByKey(item_cfg.name)

	local value =  hero_name..cur_des_value[2]..random_des

	for k,v in pairs(self.m_model.cfg.event_des) do
		if v == cell_data.params[2] then
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "desc_text", value )
		end
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