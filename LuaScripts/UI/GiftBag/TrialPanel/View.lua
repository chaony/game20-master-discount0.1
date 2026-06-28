local M = class("TrialPanelView", LikeOO.OOPopBase)

M.m_uiName = "GiftBag/TrialPanel"
M.m_size_type = 2

function M:onEnter()
	self.rewards = {}
	self.reward_effect = {}
	self:setTextByLanKey("time_text", "gf_str_0051")
	self.m_content_panel = self:findGameObject("node_parent")
	for i = 1, self.m_model.m_sel_tab_index do
		local red_point = self.m_model:checkPoint(i)
		if red_point == true then
			self.m_model.m_sel_tab_index = i
			break
		end
	end
	RedPointUtil:recruitSetRedPoint(self.m_model.m_sel_tag_index ,GameUtil:formatNum(self.m_model.m_sel_tab_index))
	self.m_gray_img = self:findImage("gray_img")
	self:refreshUI()
end

function M:refreshUI()
	self:createLoopScroll()
	self:recruitLoopScroll()
	self.reward_effect = {}
	self:updateBottomCount()
	self:setSpine()
	self:updateTag()
	local index = self.m_model.m_sel_tab_index
	if self.m_scroll_view and index == 7 then
		self.m_scroll_view:moveToCellIndex(index)
	end
end

--更新活动期数
function M:updateTag()
	for i = 1, 3 do
		self:setObjectVisible("tag_"..i.."_light", self.m_model.m_sel_tag_index == i)
		local str = "a_dxsl_diyiqi_weixuanzhong_zi"
		if i == 1 then
			if self.m_model.m_sel_tag_index == i then
				str = "a_dxsl_diyiqi_xuanzhong_zi"
			else
				str = "a_dxsl_diyiqi_weixuanzhong_zi"
			end
		elseif i == 2 then
			if self.m_model.m_sel_tag_index == i then
				str = "a_dxsl_dierdi_weixuanzhong_zi"
			else
				str = "a_dxsl_dierqi_weixuanzhong_zi"
			end
		elseif i == 3 then
			if self.m_model.m_sel_tag_index == i then
				str = "a_dxsl_disanqi_xuanzhong_zi"
			else
				str = "a_dxsl_disanqi_weixuanzhong_zi"
			end
		end
		self:setObjectVisible("lock_img_"..i, self.m_model:checkVersionOpen(i) == false)
		self:setImg(str, ResourceUtil:getLanAtlas() ,"tag_"..i.."_img")
		self:updateTagRedPoint(i)
	end
end

function M:updateTagRedPoint(index)
	self:setObjectVisible("tag_red_point_"..index, self.m_model:chectVerTagRedPoint(index))
end

function M:refreshRedPoint()
	self:createLoopScroll()
	local index = self.m_model.m_sel_tab_index
	for i = 1,3 do
		self:updateTagRedPoint(i)
	end
end

--[[
    创建日期页签列表
]]
function M:createLoopScroll()
	local data = {}
	for i = 1, 7 do
		table.insert(data, {bl = false})
	end
    self.m_tag_tab = {}
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("tab_loopscroll")
        local params ={
			ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_tag_tab[index] = {data = cell_data, obj = cell_obj}
				self:update_tag(index, cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "mask_btn" then
					self:updateMsg("mask_btn")
				else
					self:updateMsg(index)
				end 
			end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.m_scroll_view:reloadData(data, true)
    end 
end

function M:update_tag(index, obj, data)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		local tag_name = luaBehaviour:FindText("tag_name_text")
		local tag_name2 = luaBehaviour:FindText("tag_name_text2")
		tag_name.text = Language:getTextByKey(index)
		tag_name2.text = Language:getTextByKey(index)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "di_text", "gf_str_0151")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "di_text2", "gf_str_0151")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tian_text", "gf_str_0152")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tian_text2", "gf_str_0152")
		local red_point = self.m_model:checkPoint(index) or false
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "red_point", red_point == true)
		local bg = luaBehaviour:FindImage("bg")
		local mask_btn = luaBehaviour:FindImage("mask_btn")
		if self.m_model.m_cur_version >= self.m_model.m_sel_tag_index then
			if self.m_model.m_day >= index then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_sel_tab_index == index)
				bg.material = nil
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", true)	
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
				bg.material = mask_btn.material
			end
		else
			if index == 1 then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", self.m_model.m_sel_tab_index == index)
				bg.material = nil
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_btn", true)	
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "light", false)
				bg.material = mask_btn.material
			end
		end
	end
end

--[[
    创建试炼任务列表
]]
function M:recruitLoopScroll()
	local data = self.m_model:get_recruit_tab()
    self.m_task_tab = {}
    if self.r_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params ={
			ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
			update_cell =function(index, cell_obj, cell_data)
				self.m_task_tab[cell_data] = cell_obj
				self:updateTaskItem(cell_obj, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
				if click_name == "jifen_obj" then
					GameUtil:lookInfoTips(self.m_control, {click_transform = click_object.transform, msg = Language:getTextByKey("gf_str_0065")})
				else
					if cell_data.shop_type == true then
						if cell_data.log_type == true then
							if self.m_model:checkLogin() == false then
								self:updateMsg("sign_btn")
							end
						else
							if self.m_model:checkBuy() == false then
								self:updateMsg("buy_btn",cell_data.price_new)
							end
						end
						return
					end
					local data = self.m_model:getTaskCfg(cell_data.id)
					if data.status == 0 then
						self:updateMsg("go_to", cell_data.go_type)
					elseif data.status == 1 then    
						self:updateMsg("get_reward", cell_data.id)
					end
				end
			end
        }
        self.r_scroll_view = LoopScrollViewUtil.new(params)
    else
    	self.r_scroll_view:reloadData(data, true)
    end 
end

function M:updateTaskItem(obj, cfg)
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	if luaBehaviour then
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shop_img", cfg.shop_type)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shop_count", cfg.shop_type)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rate_text", cfg.shop_type == false)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", cfg.name)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jifen_obj", cfg.shop_type == false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", true)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "yuan_title_text", "daxia_yuan_title")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "xian_title_text", "daxia_xian_title")
		local btn_img = luaBehaviour:FindImage("ok_btn")
		local parent = luaBehaviour:FindGameObject("itemParent")
		if cfg.shop_type == true then
			UIUtil.setLocalPosition(parent.transform, -55,1.6,0)
		else
			UIUtil.setLocalPosition(parent.transform, 17.5,1.6,0)
		end
		-- UIUtil.destroyAllChild(parent.transform)
		-- GameUtil:createRewards(parent.transform, cfg.reward, true, true, nil)
		local get = false --奖励是否已领取
		LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", true)
		if cfg.shop_type == true then
			if cfg.log_type == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shop_count", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour, "shop_img", false)
				local bl = self.m_model:checkLogin()
				if bl == false then
					btn_img.material = nil
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0039")
				else
					btn_img.material = self.m_gray_img.material
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0040")
					get = true
				end
			else
				local bl = self.m_model:checkBuy()
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "yuan_num", cfg.price_old)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "xin_num", cfg.price_new)
				if bl == false then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0037")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = nil
				else
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "gf_str_0048")	
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = self.m_gray_img.material
					get = true
				end
			end		
			if self.m_model.m_cur_version > self.m_model.m_sel_tag_index and cfg.log_type == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0558")
			elseif self.m_model.m_cur_version < self.m_model.m_sel_tag_index then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0259")
			elseif self.m_model:checkLastVsn() == true and cfg.log_type == true then
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0558")
			end
		else
			local data = self.m_model:getTaskCfg(cfg.id)
			if data and next(data) ~= nil then
				local race_num = "" 
				if data.value > cfg.target_value then
					race_num = GameUtil:formatNum(cfg.target_value) .."/"..GameUtil:formatNum(cfg.target_value)
				else
					race_num = GameUtil:formatNum(data.value) .."/"..GameUtil:formatNum(cfg.target_value)
				end
				if cfg.target_type == 1 then
					if data.value > cfg.target_value then
						race_num = self.m_model:getStageName(cfg.target_value).."/"..self.m_model:getStageName(cfg.target_value)
					else
						race_num = self.m_model:getStageName(data.value).."/"..self.m_model:getStageName(cfg.target_value)
					end
				end
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "reward_num_text", cfg.score)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rate_text", race_num)
				if data.status == 0 then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0029")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
					btn_img.material = nil
				elseif data.status == 1 then    
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0056")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_2", "common_ui")
					btn_img.material = nil
				elseif data.status == 2 then
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "btn_text", "new_str_0080")
					LuaBehaviourUtil.setImg(luaBehaviour, "ok_btn", "a_ui_currency_btn_small_3", "common_ui")
					btn_img.material = self.m_gray_img.material
					get = true
				end
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", true)
				if self.m_model.m_cur_version > self.m_model.m_sel_tag_index and data.status ~= 1 then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0558")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
				elseif self.m_model.m_cur_version < self.m_model.m_sel_tag_index then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0259")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)	
				elseif self.m_model:checkLastVsn() == true and data.status ~= 1 then
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
					LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0558")
					LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rate_text", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"ok_btn", false)
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"btn_text", false)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_open_text", "new_str_0259")
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"no_open_text", true)
			end
		end
		self:createTaskRewards(parent.transform, cfg.reward, get)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "jifen_duigou_img", get == true)
	end
end

function M:createTaskRewards(reward_node,rewards, get)
    local rewards = rewards or {}
    local items = {}
    UIUtil.destroyAllChild(reward_node)
    for k,v in pairs(rewards) do
        local item = GameUtil:createItemElement(v, true, true)   
        item.transform:SetParent(reward_node, false)
        table.insert( items, item)
		local itemLuaBehaviour = UIUtil.findLuaBehaviour(item)
		if itemLuaBehaviour then
			LuaBehaviourUtil.setObjectVisible(itemLuaBehaviour, "duigoudi_img", get == true)
		end
    end
    return items
end

function M:updateBottomCount()
	self:setTextByLanKey("integral_text", self.m_model:getScore())
	local slider_node = {}
	for i = 1, 5 do
		local activation_item = self:findGameObject("activation_"..i)
		local activ_cfg = self.m_model:getRecruitCfg(i)
		local score_data = self.m_model:getScoreData(i)
		local num_text = UIUtil.findText(activation_item.transform, "activation_num")
		num_text.text = activ_cfg.score
		local function callback(obj, data)
			if score_data == nil and self.m_model:getScore() >= activ_cfg.score then
				self:updateMsg("buy_score", i)
			end
		end
		local show_d = true
		if score_data == nil and self.m_model:getScore() >= activ_cfg.score then
			show_d = false
		end
		GameUtil:updateItemElement(activation_item, activ_cfg.reward[1], true, show_d, callback)
		if i == 2 or i == 5 then
			local data = RewardUtil:getProcessRewardData(activ_cfg.reward[1])
			if self.reward_effect[i] == nil then
				local item_ef = GameUtil:creatCommonActiveEffect(activation_item)
				self.reward_effect[i] = item_ef
			end
		end
		local LuaBehaviour = UIUtil.findLuaBehaviour(activation_item)
		if score_data then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", true)
		else
			local add_panel = LuaBehaviour:FindGameObject("add_panel")
			if self.m_model:getScore() >= activ_cfg.score then
				local data = RewardUtil:getProcessRewardData(activ_cfg.reward[1])
				GameUtil:creatCommonItemEffect(add_panel, data.quality)	
			else
				UIUtil.destroyAllChild(add_panel.transform)
			end
		end
	end
	for i = 1,5 do
		local value_item = self:findImage("cell_value_"..i)
		local base_num = 0
		if i > 1 then
			local activ_cfg = self.m_model:getRecruitCfg(i-1)
			base_num = activ_cfg.score 
		end
		if base_num < self.m_model:getScore() then			
			local value = self.m_model:getScore() - base_num
			local max_value = self.m_model:getRecruitLength(i)
			value_item.fillAmount = value/max_value
		else
			value_item.fillAmount = 0
		end
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
			if score_data == nil and self.m_model:getScore() >= cfg.score then
				self:updateMsg("buy_score", k)
			end
		end
		value_table[k].num = cfg.score
		
		if score_data == nil and self.m_model:getScore() >= cfg.score then
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
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "select_image", self.m_model:getScore() >= cfg.score)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "red_point_img", self.m_model:getScore() >= cfg.score)
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "duigoudi_img", false)	
			end
		end
		UIUtil.setScale(item.transform,  0.8)
		self:setTextByLanKey("num"..k, cfg.score)
	end
	local max_cfg = cfg_list[#cfg_list]
	if max_cfg then
		local rate = self.m_model:getScore()/max_cfg.score
		self:setTextByLanKey("integral_text", self.m_model:getScore())
	end
	for k,v in pairs(value_table) do
		local cur_num = v.num
		local rate = self.m_model:getScore()/cur_num
		local img = self:findImage(v.img)
		if k > 1 then
			local last_num = value_table[k-1].num
			if self.m_model:getScore() >= cur_num then
				img.fillAmount = 1
			elseif self.m_model:getScore() > last_num then
				img.fillAmount = 0.5
			else
				img.fillAmount = 0
			end
		end
	end
end

function M:updateTime()
	local tim = GameUtil:formatTimeBySecond(self.m_model.down_Tim, 999)
	self:setTextByLanKey("down_time", tim)
	if self.m_model.down_Tim <= 0 then
		if self.m_model.m_cur_version > self.m_model.m_sel_tag_index then
			self:setTextByLanKey("time_text", "new_str_0558")
		else
			self:setTextByLanKey("time_text", "world_boss_str_0030")	
		end
		self:setObjectVisible("down_time", false)
	else
		self:setTextByLanKey("time_text", "gf_str_0051")
		self:setObjectVisible("down_time", true)
	end
end

function M:setSpine()
	local reward_data = RewardUtil:getProcessRewardData(self.m_model:checkRewardHero())
	if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
		if reward_data.item_cfg then
			local icon = reward_data.item_cfg.hero_spine
			if self.cacheSpineName == icon then
				return
			else
				self.cacheSpineName = icon
			end
			local play_img = self:findGameObject("hero_sk")
			GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
		end
	end
end


function M:destroy()
    M.super.destroy(self)
end

return M