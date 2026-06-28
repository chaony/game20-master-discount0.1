local M = class("HelpDagMainView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/HelpDog/HelpDagMain"
M.m_size_type = 2

function M:onEnter()
	local active_date = self.m_model:getActiveName()
	if active_date then
		self:setTextByLanKey("close_title_text", active_date.name)
		self:setTextByLanKey("title_name_text", active_date.name)
	end
	self.m_dog_head = self:findGameObject("dog_head")
	self.m_dog_head_img = self:findImage("dog_head")
	self.m_hui = self:findImage("hui")
	self.m_progress_line = self:findImage("progress_line")
	self.m_progress_line.fillAmount = 0
	if self.m_model.stage then
		self:updateMsg("begin_btn",{id = self.m_model.m_params.id,guide = 1})
	end
	audio:SendEvtBGM("Set_State_ChongWu")
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("dog_head",false)
	self.m_dog_head_img.material = nil
	self:setLevelData()
	self:setLevel()
	self:setRewardData()
end

--设置关卡显示数据
function M:setLevelData()
	local level_data = self.m_model:getLevelData()
	for i, v in ipairs(level_data) do
		--设置选中图片
		local rank_bg_name = "rank_bg_"..i 
		local rank_bg_light = "rank_bg_light_"..i 
		self:setObjectVisible(rank_bg_name,i ~= self.m_model.m_show_level_num)
		self:setObjectVisible(rank_bg_light,i == self.m_model.m_show_level_num)
		--设置名称
		local name_text = "name_text_"..i
		local name_light_text = "name_light_text_"..i
		self:setTextByLanKey(name_text,v.name_text)
		self:setTextByLanKey(name_light_text,v.name_text)
		--刷新子关卡显示
		self:setObjectVisible(v.show_level_name,i == self.m_model.m_show_level_num)
		self:setObjectVisible(v.show_level_line_name,i == self.m_model.m_show_level_num)
	end
end

--设置子关卡数据
function M:setLevel()
	local show_data = self.m_model:getLevelCompleteNum()
	local current_level = show_data + 1
	local next_level = show_data + 2
	for i = 1, 15 do
		local card_obj = self:findGameObject("level_"..self.m_model.m_show_level_num.."_stop_num_but_"..i)
		local luaBehaviour = UIUtil.findLuaBehaviour(card_obj)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_num",i)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_past",i <= current_level)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_current",false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_future",i >= next_level)
		local unlock = self.m_model:getLockStage(i)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_lock",unlock ~= 0 and unlock > UserDataManager:getCurStage())
		if unlock ~= 0 then
			local big = math.floor(unlock/100)
			local small = unlock - big * 100
			local stage_str = big.."-"..small
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"level_"..self.m_model.m_show_level_num.."_stop_lock",Language:getTextByKey("new_str_0823",stage_str))
		end
		if i == current_level then
			local pos = self.m_dog_head.transform.parent:InverseTransformPoint(card_obj.transform.position)
			local content_w,content_h = self.m_dog_head.transform.rect.width, self.m_dog_head.transform.rect.height
			pos.y = pos.y + content_h*0.5 
			local width,height = self.m_rt.rect.width, self.m_rt.rect.height
			if UserDataManager.client_data.is_iphonex == true then
				width = width - (GlobalConfig.UI_LEFT_OFFSET_X*2)
			end
			pos.y = math.max(math.min(pos.y,height*0.5 - content_h*0.5), - height*0.5)
			local scene_max = math.min(pos.x,width*0.5 - content_w*0.5)
			pos.x = math.max(scene_max, - width*0.5 + content_w*0.5)
			self.m_dog_head.transform.localPosition = pos
			self:setObjectVisible("dog_head",true)
			local isopen, unlock_stage =  self.m_model:getLevelIsOpen({ id = i })
			if isopen == 3 or isopen == 4 then
				self.m_dog_head_img.material = self.m_hui.material
			end
		end
		local function click(obj, name)
			local guide = self.m_model.stage and 1 or 0
			self:updateMsg("begin_btn", {id = i,guide = guide})
		end
		luaBehaviour:RegistButtonClick(click)
	end
end

--设置奖励数据
function M:setRewardData()
	local reward_data = self.m_model:getGameReward()
	local complete_num = self.m_model:getLevelCompleteNum()
	self.m_progress_line.fillAmount = 0
	for i, v in ipairs(reward_data) do
		local card_obj = self:findGameObject("progress_condition_bg_"..i)
		local luaBehaviour = UIUtil.findLuaBehaviour(card_obj)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"progress_point_name",Language:getTextByKey("little_game_text_008",v.id))
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"progress_point",v.id <= complete_num)
		local box_img = luaBehaviour:FindGameObject("item_reward") --奖励父物体
		local reward_item = GameUtil:createRewards(box_img.transform, v.cfg.reward, true, true, nil, 1)
		--local itemNode = UIUtil.findTrans(card_obj.transform, "ItemNode")
		local luaBehaviour_item = UIUtil.findLuaBehaviour(reward_item[1])
		--local function click_item(obj, name)
		--	self:updateMsg("ItemNode", v.cfg.reward[1])
		--end
		--luaBehaviour_item:RegistButtonClick(click_item)
		--GameUtil:updateItemElement(itemNode.gameObject, v.cfg.reward[1])
		if v.id <= complete_num then
			self.m_progress_line.fillAmount = i/#reward_data
		end
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"current_img",complete_num >= v.id and self.m_model:getRewardStage(v.id) == 0)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour_item,"duigoudi_img" ,self.m_model:getRewardStage(v.id) == 1)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"progress_condition_btn" ,complete_num >= v.id and self.m_model:getRewardStage(v.id) == 0)
		if self.m_model.stage == "guide" and i == 1 then
			LuaBehaviourUtil.setObjectVisible(luaBehaviour,"progress_condition_btn" ,true)
		end
		local function click(obj, name)
			self:updateMsg("receiveReward", v.id)
		end
		luaBehaviour:RegistButtonClick(click)
	end
end

function M:StartGame()
	self.GameManager:StartGame()
	local score = self.GameManager:GetScore()
	self:setTextByLanKey("score_text", "little_game_text_002", score)
	self:setText("finishScoreText", score)
end

function M:startAnimation()
	--self:setObjectVisible("begin_panel", false)
	--self:setObjectVisible("game_panel", true)
	--self:StartGame()
end


return M