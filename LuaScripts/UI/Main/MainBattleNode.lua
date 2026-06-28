--- 上阵
---@class MainBattleNode : OOUIbase
local M = class("MainBattleNode",LikeOO.OOUIbase)

M.m_uiName = "Main/MainBattleNode"
M.m_iphoneXAdapter = true

M.BOX_POS = {
	[1] = {pos = Vector3.New(262.2,-291.4,0)},
	[2] = {pos = Vector3.New(262.2,-291.4,0)},
	[3] = {pos = Vector3.New(262.2,-291.4,0)},
	[4] = {pos = Vector3.New(262.2,-291.4,0)},
	[5] = {pos = Vector3.New(262.2,-291.4,0)}
}

function M:onEnter()
	self.m_world_map_limit_event_time_text = self:findText("world_map_limit_event_time_text")
	self.m_gold = {}
	self.m_gold_get = {}
	self.m_gold_index = 0
	self:goldGetSpineInit()
	self:setText("hang_box_text",Language:getTextByKey("hang_str_0002"))
	self:setObjectVisible("next_stage_btn",false)
	local content_node = self:findGameObject("content_node")
	self:setParticleRenderOrder(content_node)
	self.UI_Main_weiruo_01 = self:findGameObject("UI_Main_weiruo_01")
	self.UI_Main_jiaqiang_01 = self:findGameObject("UI_Main_jiaqiang_01")
	self:setObjectVisible("verse_panel",false)
	self:setObjectVisible("UI_Main_Text_001",false)
	--self:setObjectVisible("guaji_btn",not GameVersionConfig.Is_BIGGAMEAPP)
	self:setObjectVisible("guaji_btn",false)
	self:setObjectVisible("helpdog_btn", GameVersionConfig.Is_BIGGAMEAPP)
	self:setText("guaji_box_text",Language:getTextByKey("idlereward_reward"))
	self:setText("guaji_btn_text",Language:getTextByKey("idlereward_quick_reward"))
	self:setText("helpdog_btn_text",Language:getTextByKey("idlereward_help_dog"))
	self:switchBoxType(UserDataManager:getServerTime())
	self:refreshUI()

	self.quest_special_btn_obj = self:findGameObject("quest_special_btn")
	self:updateChapterTask()

	--挂机场景
	--self:refreshSceneTexture()

	--tween
	local challenge_text_img = self:findGameObject("challenge_btn_text_img")
	local pos = challenge_text_img.transform.localPosition
	challenge_text_img.transform:DOLocalMoveX(pos.x + 10, 1):SetEase(Tweening.Ease.OutSine):SetLoops(-1, Tweening.LoopType.Yoyo)
end

function M:refreshUI()
	self:setText("exp_num", self.m_model:getIdlePlayerExp().."/"..Language:getTextByKey("new_str_0121"))
	self:setText("hero_exp_num",self.m_model:getIdleHeroExp().."/"..Language:getTextByKey("new_str_0121"))
	self:setText("gold_num",self.m_model:getIdleMoney().."/"..Language:getTextByKey("new_str_0121"))
	if self.m_model.m_data and self.m_model.m_data.idle_event_count and self.m_model.m_data.idle_event_count > 0 then
		self:setObjectVisible("idle_count_text", false)
		self:setTextByLanKey("idle_count_text", self.m_model.m_data.idle_event_count)
	else
		self:setObjectVisible("idle_count_text", false)
	end
	self:refreshRedPoint()
	self:refreshWorldMapLimitEvent()
	--self:creatMap()
	self:refreshChallengeBtnText()
	self:createGujiUpTips()
	local map_id = UserDataManager:getCurStage()
	self:battleGuideEffect()
	self:palyBeginAnim()
	local jian_1 = self:findGameObject("Jian_1")
	jian_1.transform.localRotation = Quaternion.Euler(0, 0, 0)
	local jian_2 = self:findGameObject("Jian_2")
	jian_2.transform.localRotation = Quaternion.Euler(0, 0, 0)
end

function M:battleGuideEffect()
	local stage_id = UserDataManager:getBattleStage()
	if stage_id then
		local stage_list = ConfigManager:getCommonValueById(296,{})
		for i,v in ipairs(stage_list) do
			if stage_id == v then
				self:setObjectVisible("figer_sp", true)
				return
			end
		end
	end
	self:setObjectVisible("figer_sp", false)
end

function M:palyBeginAnim()
	-- self:setObjectVisible("UI_Main_Challenge_001", false)
	-- self.challenge_anim.Skeleton:SetToSetupPose()
	-- self.challenge_anim.AnimationState:ClearTracks()
	-- self.challenge_anim.AnimationState:SetAnimation(0, "animation_1", true)
	-- self:setObjectVisible("UI_Main_Challenge_001", true)
end

function M:refreshRedPoint()
	for k, v in pairs({ { "guaji_red_point_img", 8 }}) do
		local red_flag = RedPointUtil:isFuncRedPointById(v[2])
		self:setObjectVisible(v[1], red_flag == true)
	end	
end

function M:switchBoxType(server_time)
	local m_hangup_tim = server_time - UserDataManager.idle_info.idle_start_time 
	local box_type = 1
	local show_red_point = false
	if m_hangup_tim > 43200 then--12小时
		box_type = 5
	elseif m_hangup_tim > 21600 then--6小时
		box_type = 4
	elseif m_hangup_tim > 14400 then--4小时
		box_type = 3
	elseif m_hangup_tim > 7200 then --2小时
		box_type = 3
	elseif m_hangup_tim > 60 then --一分钟
		box_type = 2
	else
		box_type = 1
	end
	if self.m_box_type == box_type then
		return
	end
	self.m_box_type = box_type
	if m_hangup_tim > 7200 then
		show_red_point = true
	end
	local img_name = "a_gj_guajijiangli_"..box_type
	local box_img = self:setImg(img_name, "main_ui2", "box_img")
	if not IsNull(box_img) then
		box_img:SetNativeSize()
		local box_data = self.BOX_POS[box_type]
		--UIUtil.setLocalPosition(box_img.gameObject.transform, box_data.pos.x , box_data.pos.y)
	end
	self:setObjectVisible("box_reward_red_point", show_red_point == true)
	for i = 1 ,6 do
		local ef_01 = self:findGameObject("UI_Main_BX0"..i.."_01")
		local ef_02 = self:findGameObject("UI_Main_BX0"..i.."_02")
		if ef_01 and not IsNull(ef_01) then
			ef_01:SetActive(box_type == i)
		end
		if ef_02 and not IsNull(ef_02) then
			ef_02:SetActive(box_type == i)
		end
	end
end

function M:showBoxSpine(tim)
	--local box_reward = self:findGameObject("box_reward")
	--local box_spine = box_reward:GetComponent("SkeletonGraphic")
	--if box_spine == nil then
	--	return
	--end
	--if tim > 21600 then
	--	if self.m_gold_index ~= 5 then
	--		self.m_gold_index = 5
	--		box_spine.AnimationState:SetAnimation(0, "animation_5", true)
	--	end
	--elseif tim > 14400 then
	--	if self.m_gold_index ~= 4 then
	--		self.m_gold_index = 4
	--		box_spine.AnimationState:SetAnimation(0, "animation_4", true)
	--	end
	--elseif tim > 7200 then
	--	if self.m_gold_index ~= 3 then
	--		self.m_gold_index = 3
	--		box_spine.AnimationState:SetAnimation(0, "animation_3", true)
	--	end
	--elseif tim > 60 then
	--	if self.m_gold_index ~= 2 then
	--		self.m_gold_index = 2
	--		box_spine.AnimationState:SetAnimation(0, "animation_2", true)
	--	end
	--else
	--	if self.m_gold_index ~= 1 then
	--		self.m_gold_index = 1
	--		box_spine.AnimationState:SetAnimation(0, "animation_1", true)
	--	end
	--end
end

function M:showTx(tim)
	--local img_name = "h_guaji_icon_0"
	--if tim > 21600 then
	--	if self.m_gold_index ~= 5 then
	--		self.m_gold_index = 5
	--	end
	--elseif tim > 14400 then
	--	if self.m_gold_index ~= 4 then
	--		self.m_gold_index = 4
	--	end
	--elseif tim > 7200 then
	--	if self.m_gold_index ~= 3 then
	--		self.m_gold_index = 3
	--	end
	--elseif tim > 60 then
	--	if self.m_gold_index ~= 2 then
	--		self.m_gold_index = 2
	--	end
	--else
	--	if self.m_gold_index ~= 1 then
	--		self.m_gold_index = 1
	--	end
	--end
	--img_name = img_name..self.m_gold_index
	--self:setImg(img_name,"common_ui","box_reward_icon")
end

function M:goldGetSpineInit()
	--[[local function goldGetComplete(data)
		self.m_gold_get[self.m_gold_index]:SetActive(false)
	end
	for i,v in ipairs(self.m_gold_get) do
		local animation = v:GetComponent("SkeletonGraphic")
		self:addSpineComplete(animation.AnimationState,goldGetComplete)
		v:SetActive(false)
	end]]
end

function M:playGoldGetSpin()
	--[[self.m_gold_get[self.m_gold_index]:SetActive(true)
	local animation = self.m_gold_get[self.m_gold_index]:GetComponent("SkeletonGraphic")
	animation.Skeleton:SetToSetupPose()
	animation.AnimationState:SetAnimation(0,"animation_" .. self.m_gold_index, false)]]
end

function M:playGetRewardSpine(callback)
	-- local box = self:findGameObject("box_spine")
	-- local box_anim = box:GetComponent("SkeletonGraphic")

	-- if box_anim.AnimationState:ToString() == "animation_4" then
	-- 	box_anim.AnimationState:SetAnimation(0, "animation_4_1", true)
	-- elseif  box_anim.AnimationState:ToString() == "animation_3"  then
	-- 	box_anim.AnimationState:SetAnimation(0, "animation_3_1", true)
	-- elseif  box_anim.AnimationState:ToString() == "animation_2"  then
	-- 	box_anim.AnimationState:SetAnimation(0, "animation_2_1", true)
	-- elseif  box_anim.AnimationState:ToString() == "animation_1"  then
	-- 	box_anim.AnimationState:SetAnimation(0, "animation_1_1", true)
	-- end
	-- self:addSpineComplete(box_anim.AnimationState,handler(self,self.resreshBoxSpine))
end

function M:creatMap()
	local map_id = UserDataManager:getBattleStage()
	if self.m_map_id ~= map_id then
		self.m_map_id = map_id
		if self.m_map then
			U3DUtil:Destroy(self.m_map)
		end
		local map_parent = self:findGameObject("map_img")
		local stage_tab = ConfigManager:getCfgByName("stage")
		local str = stage_tab[map_id].map_point_name
		self:setText("map_name_text", Language:getTextByKey(str))
		-- if not IsNull(map_parent) and map_id ~=nil then
		-- 	self.m_map = GameUtil:creatMap(map_parent, map_id, true)
		-- end
	end
end

function M:refreshWorldMapLimitEvent()
	-- 屏蔽世界地图按钮
	--local server_time = UserDataManager:getServerTime()
	--local end_time, event_data = UserDataManager:getLimitMapEventMinEndTS()
	--local diff_time = end_time - server_time
	--self:setObjectVisible("world_map_limit_event_btn", diff_time > 0)
	--
	--if event_data then
	--	local deadline_task_cfg = ConfigManager:getCfgByName("deadline_task")
	--	local map_event_cfg_item = deadline_task_cfg[event_data.event_id] or {}
	--	self:setTextByLanKey("world_map_limit_event_btn_text", map_event_cfg_item.event_name)
	--	self:setLimitTimeText(event_data, self.m_luaBehaviour)
	--	local luaGameObjectUpdater = self.m_world_map_limit_event_time_text:GetComponent("LuaGameObjectUpdater")
	--	luaGameObjectUpdater:RegistLuaUpdate(function(dt, undt)
	--		self:setLimitTimeText(event_data, self.m_luaBehaviour)
	--	end, 1)
	--end
end

function M:setLimitTimeText(event_data)
	local end_ts = event_data.end_ts or 0
	local diff_time = end_ts - UserDataManager:getServerTime()
	if diff_time > 0 then
		local ft = GameUtil:formatTimeBySecond(diff_time)
		self.m_world_map_limit_event_time_text.text = Language:getTextByKey("new_str_0485") .. ft
	else
		self.m_world_map_limit_event_time_text.text = Language:getTextByKey("new_str_0486")
	end
end

function M:refreshChallengeBtnText()
	local chapter_over = UserDataManager:getChapterOver()
	if chapter_over then
		self:setTextByLanKey("challenge_btn_text", "new_str_0029")
		self.m_control:playNextChapter()
	else
		local map_id = UserDataManager:getBattleStage()
		if map_id then
			local stage_tab = ConfigManager:getCfgByName("stage")
			local str = Language:getTextByKey(stage_tab[map_id].map_point_name)
			local change_text = Language:getTextByKey("new_str_0587", str)
			self:setTextByLanKey("challenge_btn_text", change_text)
		end
	end
end

function M:createGujiUpTips()
	local stage_id = UserDataManager:getCurStage()
	if self.m_model.m_old_stage_id ~= stage_id then
		local stage = ConfigManager:getCfgByName("stage")
		local stage_idle = ConfigManager:getCfgByName("stage_idle")
		local old_stage_cfg = stage[self.m_model.m_old_stage_id]
		local cur_stage_cfg = stage[stage_id]
		local old_cfg = stage_idle[old_stage_cfg.idle_id]
		local cur_cfg = stage_idle[cur_stage_cfg.idle_id]
		if self.m_battle_node  then
			self.m_battle_node:destroy()
			self.m_battle_node = nil
		end
		if cur_cfg.coin > old_cfg.coin or cur_cfg.hero_exp > old_cfg.hero_exp then -- 只判断金币和英雄经验
			local tab_cls = CustomRequire("UI.Main.MainGuajiUpTips")
			self.m_battle_node = tab_cls.new(self.m_control, {parent = self.content_node, target = self:findGameObject("guaji_box")})
			self.m_control:setOnceTimer(1.8, function ()
				if self.m_battle_node  then
					self.m_battle_node:destroy()
					self.m_battle_node = nil
				end
			end)
		end
		self.m_model.m_old_stage_id = stage_id
	end
end

function M:showChapterVerse()
	local stage_cfg = GameUtil:getBattleStageCfg()
	if stage_cfg.img_event and stage_cfg.img_event ~= "" then
		self:setObjectVisible("verse_panel",true)
		local sentence = string.gsub(Language:getTextByKey(stage_cfg.img_event), "\\n", "\n")
		local sentences =  string.split(sentence,"\n")
		for i=1,4 do
			self:setText("verse_text_" .. i, sentences[i] or "")
		end

		--self:setObjectVisible("UI_Main_Text_001",true)
		self.m_control:setOnceTimer(9,function()
			self:setObjectVisible("verse_panel",false)
			--self:setObjectVisible("UI_Main_Text_001",false)
		end)
	end
	if stage_cfg.chapter_img_event and next(stage_cfg.chapter_img_event) ~= nil then
		self:setTextByLanKey("chapter_text", stage_cfg.chapter_img_event[1])
		self:setTextByLanKey("chapter_zi_text", stage_cfg.chapter_img_event[2])
	end
end

function M:playTiaoZhan()
	local anim = self.m_luaBehaviour:FindAnimation("Tiaozhan")
	if anim then
		--anim:Stop()
		anim:Play("Tiaozhan")
	end
end

function M:refreshSceneTexture()
	local sceneModel = SceneManager:getCurSceneModel()
	if sceneModel.sceneId ~= SceneManager.SceneID.HangUpScene then
		--Logger.logError(" not handup scene ")
		return
	end
	local sceneImage = self:findRawImage("sceneImage")
	local sceneView = SceneManager:getCurSceneView()
	if sceneView.camera_3d == nil then
		return
	end
	local camera_3d = sceneView.camera_3d:GetComponent("Camera")
	camera_3d.targetTexture = sceneImage.texture
	camera_3d.fieldOfView = 5
	camera_3d.clearFlags = 2
end

function M:updateChapterTask()
	GameUtil:updateQuestSpecialNode(self, 1)
	--[[
	local btn_show = BtnOpenUtil:isBtnOpen(134)
	btn_show = false
	if not IsNull(self.quest_special_btn_obj) then
		local rwdNode = self:findGameObject("quest_special_reward_node")
		rwdNode:SetActive(false)
		local rwdNodeTrans = rwdNode.transform
		local nodeTrans = nil --rwdNodeTrans:Find("ItemNode(Clone)")
		for i = 0, rwdNodeTrans.childCount - 1 do
			local testTran = rwdNodeTrans:GetChild(i)
			if testTran.gameObject.name == "ItemNode(Clone)" then
				nodeTrans = testTran
			end
		end

		-------------------
		local lightVal = 0
		local chapter_quest = UserDataManager:getChapterQuestSpecialData(1, nil)
		local chapter_quest_first = chapter_quest[1]
		if chapter_quest_first then
			if chapter_quest_first.status == 2 then -- 完成可领取
				lightVal = 1
			end
		end
		-------------------

		if nodeTrans then
			self.quest_special_btn_obj:SetActive(btn_show)
			local optObj = self:findGameObject("quest_special_reward_node_opt")
			if btn_show then
				-- self.m_control:setOnceTimer(0.0, function()
				local itemroot = nodeTrans.gameObject
				local item_lua = UIUtil.findLuaBehaviour(itemroot)
				local baseImg = item_lua:FindImage("quality_img")
				local iconImg = item_lua:FindImage("item_img")
				local mat = optObj.transform:GetComponent("MaterialInstance")
				mat:SetImg("_MainTex", baseImg)
				mat:SetImg("_ItemTex", iconImg)
				-- mat:SetVector_ImgScale("_ItemScale", iconImg, 84)
				local textRect = iconImg.sprite.textureRect
				local scaleX = textRect.width / 84
				local scaleY = textRect.height / 84
				if (scaleX > scaleY) then
					if (scaleX > 1.) then
						scaleY = scaleY / scaleX
						scaleX = 1.0
					end
				else
					if scaleY > 1.0 then
						scaleX = scaleX / scaleY
						scaleY = 1.0
					end
				end
				mat:SetVector("_ItemScale", scaleX, scaleY, 1, 1)
				-- set reward num text
				local newTxtObj = self:findGameObject("quest_special_num")
				local numOutTxt = newTxtObj.transform:GetComponent("Text")
				local numTxt = item_lua:FindText("count_text")
				numOutTxt.text = numTxt.text
				local selfActive = numTxt.gameObject.activeSelf
				newTxtObj:SetActive(selfActive)
				optObj:SetActive(true)
				mat:SetVector("_RewardColor", lightVal, 1, 1, 1)
			else
				optObj:SetActive(false)
			end
		end
	end
	]]--
end

function M:destroy()
	if self.m_battle_node  then
		self.m_battle_node:destroy()
		self.m_battle_node = nil
	end
	M.super.destroy(self)
end

return M