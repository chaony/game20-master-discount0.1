local M = class("PSQPopView",LikeOO.OOPopBase)
--问卷调查
M.m_uiName = "Pops/PSQPop"
M.m_size_type = 2

function M:onEnter()	
	self:setTextByLanKey("home_title_text", "psq_str_0001")
	self:setTextByLanKey("home_content_text", "psq_str_0002")
	self:setTextByLanKey("reward_title_text", "psq_str_0003")
	self:setTextByLanKey("started_text", "psq_str_0004")
	self:setTextByLanKey("common_title_text", "psq_str_0001")
	self:setObjectVisible("home_show", true)
	self:setObjectVisible("ask_show", false)
	self.quest_input = self:findInputField("InputField")
	self.answer_parent = self:findGameObject("ScrollView_Content")
	self.base_obj_fitter = self.answer_parent:GetComponent("ContentImmediate")
	local parent = self:findGameObject("item_parent")
	local reward = nil
	if self.m_model.question_tab == nil or next(self.m_model.question_tab.reward) == nil then
		reward = {107,0,100}
	else
		reward = self.m_model.question_tab.reward[1]
	end
	local rewadd_item = GameUtil:createItemElement(reward, true, true, nil)
	rewadd_item.transform:SetParent(parent.transform, false)
	local tog = self:findGameObject("scroll_content")
	self.p_toggle = UIUtil.findComponent(tog.transform, typeof(U3DUtil:Get_ToggleGroup()))
	self:refreshUI()
	local hero_sk = self:findGameObject("hero_sk")
	GameUtil:updateSpineLoadSet(hero_sk, "RoleSpine/hero_0302_SkeletonData", "idle", 0, true)
end

function M:refreshUI()
	self:setObjectVisible("home_show", not self.m_model.is_open)
	self:setObjectVisible("ask_show", self.m_model.is_open)
	if self.m_model.is_open then
		if self.m_model:checkLastQuest() == true then
			self:setTextByLanKey("send_text", "psq_str_0008"  )
		else
			self:setTextByLanKey("send_text", "psq_str_0007" )
		end
		local quest_cfg = self.m_model:getQuestion()
		local type_name = self.m_model:getSortName()
		local title_text =  self.m_model.m_qid.."、"..type_name.." "..quest_cfg.question
		if quest_cfg.type == 1 then
			self:setTextByLanKey("topic_text", "psq_str_0005" , title_text)
		else
			self:setTextByLanKey("topic_text", title_text)
		end
		self:setObjectVisible("loopscroll", false)
		self:setObjectVisible("Scroll View", false)
		self:setObjectVisible("InputField", false)
		if quest_cfg.sort == 1 or quest_cfg.sort == 2  then --单选/多选
			--self:setLoopScroll()
			self:creatAnswer(quest_cfg.sort)
		elseif	quest_cfg.sort == 3 then --填空	
			self:setSortThree()
		end
		self:setTextByLanKey("progress_text", "psq_str_0012",self.m_model:getProgress() )
	end
end

function M:setLoopScroll()
	local ans_list = table.copy(self.m_model:getAnswer()) 
	--Logger.log(ans_list,"<color=yellow>答案</color>")
	self:setObjectVisible("loopscroll", true)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = ans_list,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				if luaBehaviour then
					local tog_btn = luaBehaviour:FindToggle("tag_btn")
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "answer_text", cell_data.answer)
					local quest_cfg = self.m_model:getQuestion()
					if quest_cfg.sort == 2 then
						tog_btn.group = nil
					else
						tog_btn.group = self.p_toggle
					end
					tog_btn.isOn = false
					if tog_btn then
						UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, index) end, nil, self.m_uiName)	
					end
				end
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(ans_list)
	end
end

function M:creatAnswer(type)
	local ans_list = table.copy(self.m_model:getAnswer2())
	ans_list = self:randomTable(ans_list)
	self:setObjectVisible("Scroll View", true)
	UIUtil.destroyAllChild(self.answer_parent.transform)
	UIUtil.setLocalPosition(self.answer_parent.transform,5000,0,0)
	self.psq_list = {}
	for k,v in pairs(ans_list) do
		local item = self:creatItem()
		self.psq_list[k] = item
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		if luaBehaviour then
			local tog_btn = luaBehaviour:FindToggle("tag_btn")
			local cell_data = ans_list[k]
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "answer_text", cell_data.answer)
			local quest_cfg = self.m_model:getQuestion()
			if quest_cfg.sort == 2 then
				tog_btn.group = nil
			else
				tog_btn.group = self.p_toggle
			end
			tog_btn.isOn = false
			if tog_btn then
				UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k, v.id) end, nil, self.m_uiName)	
			end
		end
	end
	self.base_obj_fitter:ForceRefreshSize()
	self.m_control:setOnceTimer(0.1, function ()
		UIUtil.setLocalPosition(self.answer_parent.transform,0,0,0)
	end)
end

function M:randomTable(_table, _num) 
    local _result = {}
    local _index = 1
    local _num = _num or #_table
    while #_table ~= 0 do
        local ran = math.random(0, #_table)
        if _table[ran] ~= nil then
            _result[_index] = _table[ran]
            table.remove(_table,ran)
            _index = _index + 1
            if _index > _num then 
                break
            end 
        end
    end
    return _result
end

function M:creatItem()
	local item = GameUtil:createPrefab("Pops/PSQ_Cell")
	item.transform:SetParent(self.answer_parent.transform, false)
	return item
end

--单选 or 多选
function M:switchTabUpdate(is_on, index, id)
	local quest_cfg = self.m_model:getQuestion()
	if quest_cfg.sort == 2 then
		if is_on == true and self.m_model:checkAnswerNum() >= 6 then
			GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("psq_str_0013"), delay_close = 2})
			local psq_item = self.psq_list[index]
			local luaBehaviour = UIUtil.findLuaBehaviour(psq_item)
			if luaBehaviour then
				local tog_btn = luaBehaviour:FindToggle("tag_btn")
				tog_btn.isOn = false
			end
			return 
		end
		self.m_model:seleType2Answer(is_on, id)
	else	
		if is_on then
			self.m_model.m_select_id = id
		elseif is_on == false and self.m_model.m_select_id == id then			
			self.m_model.m_select_id = nil
		end
	end
end

function M:setSortThree()
	UIUtil.destroyAllChild(self.answer_parent.transform)
	self:setObjectVisible("InputField", true)
	self.quest_input.text = ""
end

function M:getInputCount()
	return self.quest_input.text
end

return M