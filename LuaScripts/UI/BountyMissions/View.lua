local M = class("BountyMissionsView",LikeOO.OOPopBase)

M.m_uiName = "BountyMissions/BountyMissions"
M.m_size_type = 2

local TEST_TASK_LIST ={}

function M:onEnter()	
	self.m_loopScroll = LoopScrollUtil.new()
	local tiwn_tog_btn = self:findToggle("tog_1")
    local team_tog_btn = self:findToggle("tog_2")
	UIUtil.addToggleListener(tiwn_tog_btn, function(is_on) self:switchTabUpdate(is_on, "tiwn_tog") end, nil, self.m_uiName)
	UIUtil.addToggleListener(team_tog_btn, function(is_on) self:switchTabUpdate(is_on, "team_tog") end, nil, self.m_uiName)
	tiwn_tog_btn.isOn = true
	self:refreshUI()
end

function M:refreshUI()
	self:setText("reset_btn_text","刷新")
	self:setText("aid_btn_text","我的外援")
	self:setText("tog_1_text","个人悬赏")
	self:setText("tog_2_text","师徒悬赏")
	self:setTextByLanKey("common_title_text","new_str_0399")
	self:setTextByLanKey("offer_lv_text", "new_str_0075", self.m_model.bounty_lv)--当前等级
	self:setObjectVisible("tog1_hint",false)	
	self:setObjectVisible("tog2_hint",false)	
end

function M:refreshTask(data)
	local pos = self.m_loop_scroll_view:getContentOffset()
	self:refreshUI()
	self:updateLoopScroll()
	if data then
		self.m_loop_scroll_view:setContentOffset(pos)
	end
end


function M:switchTabUpdate(is_on, update_key)
	if is_on then
		self:updateMsg(update_key)
	end
end

--切换页签
function M:seleteTag(index)
	self:setResetTim()
	self:updateLoopScroll()
	local tog_1_text = self:findText("tog_1_text")
	local tog_2_text = self:findText("tog_2_text")
	if index == 1 then
		self:setObjectVisible("reset_btn",true)	
	elseif index == 2 then
		self:setObjectVisible("reset_btn",false)	
	end
end


--[[
	创建任务列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getTaskList()
	TEST_TASK_LIST = {}
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:setTaskCell(cell_data,cell_object)
				table.insert(TEST_TASK_LIST, {data = cell_data, obj = cell_object})
				if index == 1 then
					self.m_guide_cell = cell_object
				end
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "send_btn" then
					self:updateMsg("open_send", {reward = cell_data.data.reward , id = cell_data.id } )
				end
				if click_name == "reward_btn" then
					self:updateMsg("get_reward", cell_data.id)
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
	if #data > 0 then
		self:setObjectVisible("nil_caneqp",false)
	else
		self:setObjectVisible("nil_caneqp",true)
	end
end

function M:setTaskCell(task,obj)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	local name = luaBehaviour:FindText("offer_name_text")--任务名字
	name.text = Language:getTextByKey(task.cfg.name)
	local data = GlobalConfig.BOUNTY_RANK[task.cfg.rank]
	name.color = data.RGBA
	--任务奖励
	local drop = task.data.reward or {}
	local reward_node = luaBehaviour:FindGameObject("reward_obj") 
	UIUtil.destroyAllChild(reward_node.transform)
	local rewadd_item = GameUtil:createItemElement(drop[1], true, true, nil)
	rewadd_item.transform:SetParent(reward_node.transform, false)
	local count_text = luaBehaviour:FindText("count_text")
	local tim_text = luaBehaviour:FindText("tim_text")
	local slider = luaBehaviour:FindGameObject("slider")
	local doing_img = luaBehaviour:FindGameObject("doing_img")
	local fill = luaBehaviour:FindImage("Fill")
	local reward_btn = luaBehaviour:FindGameObject("reward_btn")
	local send_btn = luaBehaviour:FindGameObject("send_btn")
	local life_time_text = luaBehaviour:FindText("life_time_text") 
	count_text.gameObject:SetActive(false)
	tim_text.gameObject:SetActive(false)
	life_time_text.gameObject:SetActive(false)
	slider:SetActive(false)
	reward_btn:SetActive(false)
	send_btn:SetActive(false)
	doing_img:SetActive(false)
	--任务状态
	if task.data.quest_status == 0 then --未派遣
		local tim = GameUtil:formatTimeBySecond(task.cfg.duration_time*60)
		count_text.text = Language:getTextByKey("new_str_0123")..tim
		life_time_text.text = self.m_model:checkDeadTime(task.data.expire_ts) 
		life_time_text.gameObject:SetActive(true)
		count_text.gameObject:SetActive(true)
		if self.m_model.cur_type == 2 then
			send_btn:SetActive(not self.m_model:chechMasterStatue())
		else
			send_btn:SetActive(true)
		end
	elseif task.data.quest_status == 1 then --派遣中
		if task.count_down then
			if task.count_down <= 0 then
				tim_text.text = Language:getTextByKey("new_str_0063")
				tim_text.gameObject:SetActive(true)
				doing_img:SetActive(false)
				reward_btn:SetActive(true)
				slider:SetActive(true)
				fill.fillAmount = 1
				task.data.quest_status = 2
			else
				local ratio = task.count_down/(task.cfg.duration_time*60)
				fill.fillAmount = 1- ratio
				tim_text.text = GameUtil:formatTimeBySecond(task.count_down)
				tim_text.gameObject:SetActive(true)
				slider:SetActive(true)
				doing_img:SetActive(true)
				if self.m_model.cur_type == 2 and  self.m_model:chechMasterStatue() == true then
					life_time_text.text = task.data.name 
					life_time_text.gameObject:SetActive(true)
				end
			end
		end
	elseif task.data.quest_status == 2 then --待领取 	
		tim_text.text =  Language:getTextByKey("new_str_0063")
		tim_text.gameObject:SetActive(true)
		if self.m_model.cur_type == 2 then
			reward_btn:SetActive(not self.m_model:chechMasterStatue())
		else
			reward_btn:SetActive(true)
		end
		slider:SetActive(true)
		fill.fillAmount = 1
	end
	local star_tab = {}
	local st = luaBehaviour:FindGameObject("star_1")
	st:SetActive(false)
	for i = 1, 6 do
		local st = luaBehaviour:FindGameObject("star_"..i)
		st:SetActive(false)
		table.insert(star_tab, i, st)
	end
	for k,v in pairs(star_tab) do
		if task.cfg.rank >= k then
			v:SetActive(true)
		end
	end
end

--更新刷新时间
function M:setResetTim()
	local tim = GameUtil:formatTimeBySecond(self.m_model.dataTime)
	if self.m_model.cur_type == 1 then
		local time_show = "重置全部个人任务".." "..tim
		self:setText("reset_time_text",time_show)
	elseif self.m_model.cur_type == 2 then
		local time_show = "新增师徒任务".." "..tim
		self:setText("reset_time_text",time_show)
	end
	self:updateItemTime()
end

--这里用于更新任务列表里面正在进行的时间v
function M:updateItemTime()
	for k, v in pairs(TEST_TASK_LIST) do
		if v.data.data.quest_status == 1 then --派遣中
			if IsNull(v.obj) then
				return
			end
			local luaBehaviour = UIUtil.findLuaBehaviour(v.obj)
			v.data.count_down = v.data.count_down - 1
			local fill = luaBehaviour:FindImage("Fill")
			local tim_text = luaBehaviour:FindText("tim_text")
			if v.data.count_down <= 0 then
				fill.fillAmount = 1
				UIUtil.setTextByLanKey(v.obj.transform, "tim_text", "new_str_0063") 
				UIUtil.setObjectVisible(v.obj.transform,true,"tim_text")
				UIUtil.setObjectVisible(v.obj.transform,true,"reward_btn")
				UIUtil.setObjectVisible(v.obj.transform,true,"slider")
				v.data.data.quest_status = 2
				break
			end
			local ratio = v.data.count_down / (v.data.cfg.duration_time * 60)
			fill.fillAmount = 1 - ratio
			tim_text.text = GameUtil:formatTimeBySecond(v.data.count_down)
			UIUtil.setObjectVisible(v.obj.transform,true,"tim_text")
			UIUtil.setObjectVisible(v.obj.transform,true,"slider")
		end
	end
end


return M