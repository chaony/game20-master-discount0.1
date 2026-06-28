local M = class("HeroInfoControl",LikeOO.OOControlBase)

function M:onEnter()
	--self.m_view.m_luaBehaviour:UseFingersSliding(handler(self,self.fingerSliding))
	UIUtil:registerDragEvent(self.m_view.m_ui_obj, handler(self,self.fingerSliding))
	self.slid_lock = false
	self.talk_tim =	self:setTimer(self.m_model.talk_interval ,handler(self,self.playTalk))
	self.long_click_interval = true
	self.m_guide_file_name = "UI.HeroInfo.Guide"
	ResourceUtil:LoadRoleCV(self.m_model:subName())
	self:switchTabBtn(self.m_model.m_open_tab_index, true)
	self:playTalk(true) -- 先来一句
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("common_refresh",nil,"parent")
		self:sendLvUpNet()
		self:closeView()
	elseif msg == "closeNode_btn" then
		self:updateMsg(99999)
		-- 1属性、2经脉、3逸闻 
	elseif type(msg) == "number" and msg >= 1 and msg <= 3 then
		self:switchTabBtn(msg)
	elseif msg == "put_on_btn" then
		self:putOn()
	elseif msg == "get_out_btn" then
		self:getUp()
	elseif msg == "eq1_btn" then
		self:checkEqp(1)
	elseif msg == "eq2_btn" then
		self:checkEqp(2)
	elseif msg == "eq3_btn" then
		self:checkEqp(3)
	elseif msg == "eq4_btn" then
		self:checkEqp(4)
	elseif msg == "eq5_btn" then
		--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
		self:openArtifact()
	elseif msg == "update_equip" then --穿脱装备、属性修改、装备升级的刷新回调
		self.m_model:getHeroData()
		if data == nil then
			data = true
		end
		self.m_view:refreshUI(data)
	elseif msg == "last_btn" then --切换英雄
		self:lastHero()
	elseif msg == "next_btn" then
		self:nextHero()
	elseif msg == "check_btn" then
		if self.m_model.m_look_model == 1 then
			local params =
			{
				heroid = self.m_model.m_heroid,
				look_model = self.m_model.m_look_model,
				hero_data = self.m_model.m_herodata,
				hero_cfg =  self.m_model.herocfg
			}
			self:openView("Pops.Pro_Pop", params)
		else
			self:openView("Pops.Pro_Pop",{heroid = self.m_model.m_heroid, look_model = self.m_model.m_look_model })
		end
	elseif msg == "open_levelup" then
		local params = {
			callback = function ()
				self.slid_lock = false
				self.m_model:refreshMoneyNum()
				self.m_view:refreshUI(false)
			end,
			data = data
		}
		self.slid_lock = true
		self:openView("HeroInfo.EquipmentLevelUp", params)
	elseif msg == "money_img_3" or msg == "money_img_2" or msg == "money_img_1" or msg == "money_img" or msg == "jingyan_img" or msg == "yueli_img" then
		self.m_view:clickTips(msg)
	elseif msg == "skill1_img" then
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[1], index = 1, cur_lv = hero_lv })
		self.m_view:updateSkillRedPoint(1, false)
	elseif msg == "skill2_img" then
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		local click_obj = self.m_view.m_cur_tab_node:findGameObject(msg)
		-- if click_obj then
		-- 	self:openView("Pops.SkillPop",{click_transform = click_obj.transform , skill = skills[2], index = 2, cur_lv = hero_lv })
		-- end
		self:openView("Pops.SkillPop",{skill = skills[2], index = 2, cur_lv = hero_lv })
		self.m_view:updateSkillRedPoint(2, false)
	elseif msg == "skill3_img" then
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[3], index = 3, cur_lv = hero_lv })
		self.m_view:updateSkillRedPoint(3, false)
	elseif msg == "skill4_img" then
		local skills = self.m_model:getHeroSkill()
		local hero_lv = self.m_model:getHero_lv()
		self:openView("Pops.SkillPop",{skill = skills[4], index = 4, cur_lv = hero_lv })
		self.m_view:updateSkillRedPoint(4, false)
	elseif msg == "lock_btn" then
		self:lockHero()
	elseif msg == "click_up" then -- 升级按钮抬起/短按
		self.click_down = false
		self:checkSkillLvUp()
	elseif msg == "pass_on" then --长按循环
		self.click_down = true
		self:checkSkillLvUp()
	elseif msg == "desc_btn" then
		self:openView("HeroBookShow",{h_id = self.m_model.herocfg.id,type = 2})
	elseif msg == "apostle_rm_btn" then
		local params =
		{
			on_ok_call = function(msg)
				self:giveBackApostles()
			end,
			no_close_btn = false,
			text = Language:getTextByKey("friend_str_0033")
		}
		self:openView("Pops.CommonPop", params)
	elseif msg == "in_crystal_img" then
		local params =
		{
			no_close_btn = true,
			text = Language:getTextByKey("new_str_0207")
		}
		if self.m_model:inCrystal(self.m_model.m_heroid) == true then
			self:openView("Pops.CommonPop", params)
		end
	elseif msg == "skip_btn" then
		if self.m_model:checkMaxLv() == true and self.m_model:checkEvoMax()  then --跳转神木
			static_rootControl:closeAllViewPop()
			QuickOpenFuncUtil:openFunc(21)
		elseif self.m_model:checkMaxLv() == true then
			static_rootControl:closeAllViewPop()
			QuickOpenFuncUtil:openFunc(7)
		end
	elseif msg == "camp_img_btn" then
		local data_desc = "tid#status_"..self.m_model:getHeroRace()
		local btns = self.m_view.m_cur_tab_node:findGameObject("camp_img_btn")
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc)  } )
	elseif msg == "pro_img_btn" then
		local data_desc = "tid#herotype"..self.m_model:getHeroType()
		local btns = self.m_view.m_cur_tab_node:findGameObject("pro_img_btn")
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = Language:getTextByKey(data_desc) } )
	elseif msg == "meridian_btn" then
		if self.m_model:checkExclusive() == false then
			local name = self.m_model:getEvoName(9)
			local params =
			{
				text = Language:getTextByKey("new_str_0281", name)
			}
			self:openView("Pops.CommonPop",params)
		else
			local params =
			{
				hero_id = self.m_model.m_heroid
			}
			self:openView("HeroInfo.Meridian", params)
		end
	elseif msg == "activate_btn" then
		self:activateExcWeap()
	elseif msg == "tog_lock" then
		--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0426"), delay_close = 2})
	elseif msg == "tog_lock2" then
		--提示内容为制作中
		--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0507"), delay_close = 2})
		GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0306"), delay_close = 2})
	elseif msg == "intensify_btn" then
		self:intensifyExcWeap()
	elseif msg == "souchs"	then
		local cfg = GlobalConfig.HERO_QUALITY_COMMON_SETTING[self.m_model:getEvo()]
		local show_name = Language:getTextByKey(cfg.hero_show_name)
		if cfg.is_add then
			show_name = show_name.. "+"
		end
		local data_desc = Language:getTextByKey("tid#herorank_taxt", show_name)
		local btns = self.m_view.m_cur_tab_node:findGameObject("souchs")
		GameUtil:lookInfoTips(self.m_control, {click_transform = btns.transform, msg = show_name.."\n"..data_desc })
	elseif msg == "goto1_btn" or msg == "goto2_btn" or msg == "goto3_btn" or msg == "goto4_btn" or msg == "goto5_btn" then
		self:openView("WorldMap.WorldMapMain")
	elseif msg == "skill1_btn" or msg == "skill2_btn" or msg == "skill3_btn" or msg == "skill4_btn" or msg == "skill5_btn"  then
		if self.m_view.m_cur_tab_node ~= nil then
			msg = string.split(msg, "skill")[2]
			msg = string.split(msg, "_btn")[1]
			self.m_view.m_cur_tab_node:skillOnClick(tonumber(msg))
		end
	elseif msg == "base_info_btn" then
		if self.m_view.m_cur_tab_node ~= nil then
			self.m_view.m_cur_tab_node:showBaseInfo()									  
		end
	elseif msg == "anecdote1_btn" or msg == "anecdote2_btn" or msg == "anecdote3_btn" or msg == "anecdote4_btn" or msg == "anecdote5_btn" then
		if self.m_view.m_cur_tab_node ~= nil then
			msg = string.split(msg, "anecdote")[2]
			msg = string.split(msg, "_btn")[1]
			self.m_view.m_cur_tab_node:anecdoteOnClick(tonumber(msg))
		end
	end
end

-- tab按钮切换
function M:switchTabBtn(index, first_enter)
	if self.m_model.m_sel_tab_index ~= index then
		self.m_model:detectionAttrs()
		if index == 2 then
			if self.m_model:checkExclusive() == true then
				self.m_view:switchTabNode(index, first_enter)
			else
				GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0426"), delay_close = 2})
				self.m_view:changeTab(self.m_model.m_sel_tab_index)
			end
		else	
			self.m_view:switchTabNode(index, first_enter)
		end
		self.m_model.m_sel_tab_index = index
    end
end

--一键穿装
function M:putOn()
	audio:SendEvtUI('PLAY_UI_EQUIPUP')
	local function callfunc()
		self.m_view:refreshUI(true)
	end
	self.m_model:getNetData("hero_auto_equip_wear",{hero_oid = self.m_model.m_heroid}, callfunc)
end

--一键脱下
function M:getUp()
	local function callfunc()
		self.m_view:refreshUI(true)
	end
	self.m_model:getNetData("hero_equip_down",{hero_oid = self.m_model.m_heroid, auto = "1"}, callfunc)
end

--升级前先检查是否会有技能解锁
function M:checkSkillLvUp()
	if self:canLevelUpCheck() == false then
		return
	end
	local up_expend = GameUtil:getHeroUpGrade(self.m_model.m_cur_Lv) --本级升级消耗资源
	if up_expend.special_num > 0 then
		self.isNeedSpecial = true
		local params = {
			cur_lv = self.m_model.m_cur_Lv,
			heroid = self.m_model.m_heroid,
			data_exp = self.m_model.data_exp.user_num,
			data_coin = self.m_model.data_coin.user_num,
			data_special = self.m_model.data_special.user_num,
			callback = function (newskill, bl)
				self:levelUp()
				if bl == true then
					self.m_view:updateSkillRedPoint(newskill, true)
				end
				self:sendLvUpNet()
				self.m_view:creatCurEffect(newskill, bl)
			end,
			close_callback = function ()
				self.slid_lock = false
			end
		}
		self:sendLvUpNet()
		self.slid_lock = true
		self:openView("Pops.SkillLvUpPop", params)	
	else
		self.isNeedSpecial = false
		self:levelUp()
	end 
end

--升级
function M:levelUp()
	local function callfunc()
		audio:SendEvtUI('PLAY_UI_LEVELUP')
		self.long_click_interval = true
		self.m_view:refreshUI(true)
		self.m_view:refreshRedPoint()
	end
	if self:canLevelUpCheck() == true then
		self.long_click_interval = false
		self.m_model:hero_lvUp(callfunc)
	end
end

--锁定英雄
function M:lockHero()
	local function callfunc()
		self.m_model:refreshData()
		self.m_view:setLock()
	end
	if self.m_model:getHeroLock() then
		self.m_model:getNetData("hero_unlock",{hero_oid = self.m_model.m_heroid}, callfunc)
	else
		self.m_model:getNetData("hero_lock",{hero_oid = self.m_model.m_heroid}, callfunc)
	end
end

function M:lastHero()
	audio:StopPlayingID(self.cur_cv)
	self.cur_cv = nil
	ResourceUtil:UnLoadRoleCV(self.m_model:subName())
	self:sendLvUpNet()
	self:removeTimer(self.talk_tim)
	-- 切换上一个英雄
	self.m_model:switchTo(-1,handler(self,self.update_Hero))
end

function M:nextHero()
	audio:StopPlayingID(self.cur_cv)
	self.cur_cv = nil
	ResourceUtil:UnLoadRoleCV(self.m_model:subName())
	self:sendLvUpNet()
	self:removeTimer(self.talk_tim)
	-- 切换下一个英雄
	self.m_model:switchTo(1,handler(self,self.update_Hero))
end

function M:update_Hero()
	self.m_model.m_cur_Lv = self.m_model.m_herodata.lv or 1
	self.m_model:detectionAttrs()
	self.m_model:detectionEqps()
	self.m_view:refreshUI(false)
	self.m_view:hideTalk()
	
	if self.m_view.m_cur_tab_node ~= nil then
		self.m_view.m_cur_tab_node:enterSetSkillRedPoint() --清空技能小红点
	end
	ResourceUtil:LoadRoleCV(self.m_model:subName())
	self.talk_tim =	self:setTimer(self.m_model.talk_interval, handler(self,self.playTalk))
	self:playTalk(true)
end

function M:playEnd()
	--self.can_play = true
end

function M:checkEqp(index)
	--GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
	local equip_data = self.m_model:checkEqpForId(index)
	local function callback()
		self.slid_lock = false
	end
	if equip_data then --当前身上有装备
		if self.m_model.m_look_model == 1 then
			local params = {
				heroid = self.m_model.m_heroid,
				pos = index, 
				look_model = self.m_model.m_look_model,
				equip_data = equip_data,
				callback = callback
			}
			self:openView("HeroInfo.EquipmentPop", params)	--查看装备
		else
			local params = {
				heroid = self.m_model.m_heroid,
				pos = index, 
				look_model = self.m_model.m_look_model,
				callback = callback
			}
			self:openView("HeroInfo.EquipmentPop", params)	--查看装备
		end
	else
		if self.m_model.m_look_model ~= 1 then
			local params = {
				heroid = self.m_model.m_heroid,
				pos = index, 
				callback = callback
			}
			self:openView("HeroInfo.EquipmentList", params)	--穿戴装备
		end
	end
	self.slid_lock = true
end

function M:ShowTips(diff_attrs)
	self.jg = {}
	self.m_model:detectionAttrs()
	local gain = true
	for k,v in pairs(diff_attrs) do
		local count = ""
		if v~= 0 then
			if k == "atk" or k == "hp" or k == "def" then --只显示攻防血
				local name = GameUtil:getAttrsName(k)
				if v > 0 then
					gain = true
				else 
					gain = false
				end
				table.insert(self.jg, {name = name, num = v } )
			end
		end
	end
	for k,v in pairs(self.jg) do
	--	self:setOnceTimer(k*0.1, handler(self,self.att_tips))
	end
	local contentNode = self.m_view:findGameObject("content_node")
	for k,v in pairs(self.jg) do
		if v ~= 0 then
			local order = self.m_view.m_sortOrder
			GameUtil:addTips(self.jg, gain, contentNode, order)
		end
	end
	--
end

function M:att_tips()
	local contentNode = self.m_view:findGameObject("content_node")
	local data = self.jg[#self.jg]
	table.remove( self.jg, #self.jg)
	if data then
		GameUtil:addTips(data.count, data.gain, contentNode)
	end
end

function M:fingerSliding(locat)
	if self.m_model.m_sel_tab_index ~= 1 or self.slid_lock == true then
		return
	end
	if self.m_model.m_look_model == 2 then
		return
	end
	if self.click_down and self.click_down == true then --
		return
	end
	if locat == true then
		self:lastHero()
	else
		self:nextHero()
	end
end

function M:playTalk(first)
	local id = 0
	audio:StopPlayingID(self.cur_cv)
	self.cur_cv = nil
	if self.m_model.m_look_model == 2 then
		id = self.m_model.tj_id
	else
		id = self.m_model.herocfg.id
	end
	local TalkData = require("Battle.Tool.TalkData")
	--TalkData:getRandomCV(id)
	local talk = TalkData:getDataByHeroID(id, 3)
	if talk.Count > 0 then
		if first and type(first) == "boolean" then
		
			local data = TalkData:getRandomCV(id)
			--self.m_view:talk(data)
			if data and data.se_id and data.se_id ~= "" then
				--self.cur_cv = audio:SendEvtCV( data.se_id ,self.m_model:subName())
			end
		
		else
			
			local index = math.random(0, talk.Count-1)
			--self.m_view:talk(talk:get(index))
			local data = talk:get(index)
			if data and data.se_id and data.se_id ~= "" then
				--self.cur_cv = audio:SendEvtCV( data.se_id ,self.m_model:subName())
			end
		end
	end
end

function M:openExclusiveWeapons()
	if self.m_model:checkHaveExclusive() == true then
		self:openView("ExclusiveWeapons.ExclusiveWeaponsPop", {hero_id = self.m_model.m_heroid})
	else	
		self:openView("ExclusiveWeapons", {hero_id = self.m_model.m_heroid})
	end
end

function M:giveBackApostles()
	local function callback(response)
        self:updateMsg("give_back", nil, "Friend")
        self:closeView()
    end
    local params = {}
    params.hero_oid = self.m_model.m_heroid
    self.m_model:getNetData("apostle_give_back", params, callback)
end

--查看神器
function M:openArtifact()
	local function callback()
		self.slid_lock = false
	end
	if self.m_model.m_look_model == 1 then --查看别人的英雄
		if self.m_model:checkHaveArtifact() == true then --当前身上有神器
			local art_data = self.m_model.m_herodata.artifact
			local params = {
				heroid = self.m_model.m_heroid,
				look_model = self.m_model.m_look_model , 
				artid = self.m_model.m_herodata.artifact.oid,
				art_data = art_data,
				callback = callback
			}
			self:openView("HeroInfo.ArtifactPop", params)	
		end
	else
		local flag, tips = self.m_model:checkArtifact()
		if flag == false then
			local params =
			{   
				text = tips
			}
			self:openView("Pops.CommonPop",params)
			return
		end
		if self.m_model:checkHaveArtifact() == true then --当前身上有神器
			local params = {
				heroid = self.m_model.m_heroid,
				look_model = self.m_model.m_look_model , 
				artid = self.m_model.m_herodata.artifact.oid,
				callback = callback
			}
			self:openView("HeroInfo.ArtifactPop", params)
		else
			self:openView("HeroInfo.ArtifactList",{ heroid = self.m_model.m_heroid, callback = callback})
		end
	end
	self.slid_lock = true
end

--发送升级请求
function M:sendLvUpNet()
	local function callfunc(data)	
		if self.m_view then
			self.m_view:refreshUI(true)
		end
	end
	if self.m_model.m_look_model == 1 or self.m_model.m_look_model == 2 then
		return
	end 
	if self.m_model.m_herodata.lv ~= self.m_model.m_cur_Lv then
		self.m_model:getNetData("hero_fast_level_up", {hero_oid = self.m_model.m_heroid, level = self.m_model.m_cur_Lv }, callfunc, 0)
	end
end

function M:canLevelUpCheck()
	if self.m_model:checkMaxLv() == true and self.m_model:checkMaxEvo() == true then
		local params =
		{
			text = Language:getTextByKey("new_str_0279")
		}
		self:openView("Pops.CommonPop", params)	
		return false
	elseif self.m_model:checkMaxLv() == true then
		return false
	end
	local can_lv_up, index, count = self.m_model:checkCanLevelUp()
	if self.long_click_interval == true and can_lv_up ==false then
		if index == 1 then
			local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_COIN_NUM)
			if not flag then
				local params =
				{
					text = string.format(Language:getTextByKey("new_str_0204"))
				}
				self:openView("Pops.CommonPop", params)	
			end
		elseif index == 2 then
			local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_HERO_EXP_NUM)
			if not flag then
				local params =
				{
					text = string.format(Language:getTextByKey("new_str_0203"))
				}
				self:openView("Pops.CommonPop", params)
			end
		elseif index == 3 then
			local flag = QuickOpenFuncUtil:serverCostsTips(RewardUtil.ERROR_GIFT.ERROR_GIFT_DUST_NUM)
			if not flag then
				local params =
				{
					text = string.format(Language:getTextByKey("tid#NoticeText_01"))
				}
				self:openView("Pops.CommonPop", params)
			end
		elseif index == 4 then	
			local params =
			{
				text = string.format(Language:getTextByKey("new_str_0205"),count)
			}
			self:openView("Pops.CommonPop", params)
		end
	end
	return can_lv_up
end

function M:activateExcWeap()
    local function callfunc()
        -- 激活成功
        self:updateMsg("update_equip")
    end
    self.m_model:getNetData("sig_enable",{ hero_oid = self.m_model.m_heroid}, callfunc)
end

function M:intensifyExcWeap()
    local function callfunc()
		-- 强化成功
		self.m_view:creatJuQiEffect()
		self:setOnceTimer(1, function()
			self:updateMsg("update_equip")
		end)
	end
	local lock, tips = self.m_model:meridanCanLevelUp() 
	if lock == true then
		self.m_model:getNetData("sig_lvlup",{ hero_oid = self.m_model.m_heroid}, callfunc)
	else
		GameUtil:lookInfoTips(self, {msg = tips, delay_close = 2})
	end
end

function M:onDestroy()
	self:sendLvUpNet()
	audio:StopPlayingID(self.cur_cv)
	self.cur_cv = nil
	ResourceUtil:UnLoadRoleCV(self.m_model:subName())
end

function M:onUpdate()
	self.m_model:refreshMoneyNum()
	self.m_view:refreshUI(true)
end

return M
