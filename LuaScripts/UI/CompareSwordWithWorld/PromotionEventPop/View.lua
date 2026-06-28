local M = class("PromotionEventPopView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/PromotionEventPop" --CompareSwordWithWorld。PromotionEventPop
M.m_iphoneXAdapter = true
M.m_size_type = 1

function M:onEnter()
	self.CompareSwordUtil = require("UI.CompareSwordWithWorld.compareSwordWithWorldUtil").new(self.m_model.m_version)
	self:refreshUI()
end

function M:refreshUI()
	self:refreshTimeText()
	
	self:setPos16Rank()
	self:setPos8Rank()
	self:setPos4Rank()
	self:setPos2Rank()
	self:setPos3Rank()
	self:setPos1Rank()

	local img_top_bg = self:findImage("Img_top_bg")
	GameUtil:updateResourcesImg( img_top_bg, "Texture/zh_cn/" .. (self.m_model.raceType == 1 and "a_sjtx_tjjjs_title" or "a_sjtx_djjjs_title"))

	self:setTextByLanKey("text_fight_title" ,"compare_sword_race_text_055")
	self:setTextByLanKey("close_title_text" ,self.m_model.raceType == 1 and "compare_sword_race_text_057" or "compare_sword_race_text_058")
	
end

function M:setPos16Rank()
	local posRank = self.m_model:getRankRange(16)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_16_"..i)
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_006")
	end
end

function M:setPos8Rank()
	local posRank = self.m_model:getRankRange(8)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_8_"..i)
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_005")
	end
end

function M:setPos4Rank()
	local posRank = self.m_model:getRankRange(4)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_4_"..i)
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_004")
	end
end

function M:setPos2Rank()
	local posRank = self.m_model:getRankRange(2)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_2_"..i)
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_002")
	end
end

function M:setPos3Rank()
	local posRank = self.m_model:getRankRange(-2)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_3_"..i)
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_003")
	end
	
	local player_rank3 = self.m_model:getRankRange(-1)
	local btn = self:findGameObject("btn_report_rank3")
	if player_rank3[1].player  then
		self:setObjectVisible("btn_report_rank3" , true)
		UIUtil.setButtonClick(btn.transform, function()
			self:updateMsg("btn_report_onClick", { battle_id = player_rank3[1].player.battle_id })
		end)
	end
end

function M:setPos1Rank()
	local posRank = self.m_model:getRankRange(1)
	for i = 1, #posRank do
		local pos_go = self:findGameObject("player_info_1")
		self:setPlayerRank(pos_go , posRank[i] , "compare_sword_rank_title_001")
	end
end

function M:setPlayerRank(obj , data , normal_name , showFight_icon)
	local rank = data.rank
	local player = data.player
	
	local pos_lua = UIUtil.findLuaBehaviour(obj)
	local line_light_go = pos_lua:FindGameObject("line_before_light")
	local headNode = pos_lua:FindGameObject("HeadNode")
	local playerName =  pos_lua:FindText("player_name")
	local btn_report_go = pos_lua:FindGameObject("btn_report")
	
	--reset node
	if line_light_go then
		line_light_go:SetActive(false)
	end
	if btn_report_go then
		btn_report_go:SetActive(false)
	end
	if not player then
		if normal_name then
			local lang_txt = Language:getTextByKey(normal_name)
			playerName.text = lang_txt
		else
			playerName.text = ""
		end
		
		--UIUtil.setImg(obj.transform , "tx_img", "pet_ui" , "JN_cw_wenhao" )
		--LuaBehaviourUtil.setImg(pos_lua,"tx_img", "JN_cw_wenhao", "pet_ui") --消耗货币图标
	else
		--头像名称
		playerName.text = player.name
		GameUtil:setUserAvatar(headNode, player, false, false, { show_flag = true, scale = 1 })
		--回放按钮

		local btn_report = pos_lua:FindButton("btn_report")
		local btnClick = function()
			self:updateMsg("btn_report_onClick", { battle_id = player.battle_id })
		end
		if btn_report_go then
			UIUtil.setButtonClick(btn_report_go.transform, btnClick)
			if player.battle_id ~= nil and player.battle_id ~= 0 then
				btn_report_go:SetActive(true)
			end
		end
		UIUtil.setButtonClick(obj.transform, function()
			self:updateMsg("player_onClick" , {uid = player.uid})
		end)
		
		--晋级连线
		local promotion_data = self.m_model:checkPromotionDataByIndex(rank)
		local rank_txt_go = pos_lua:FindGameObject("text_player_rank")
		local rank_txt = pos_lua:FindText("text_player_rank")
		if promotion_data then
			if promotion_data.uid == player.uid	then
				line_light_go:SetActive(true)
				if rank < 0 then --季军 处理
					if rank_txt_go then rank_txt_go:SetActive(true) end
					if rank_txt then rank_txt.text = Language:getTextByKey("compare_sword_rank_title_003") end
				end
			else
				if rank == 2 or rank == 3 then --亚军
					if rank_txt_go then rank_txt_go:SetActive(true) end
					if rank_txt then rank_txt.text = Language:getTextByKey("compare_sword_rank_title_002") end
				end
			end
		end
		if rank == 1 then --冠军
			if rank_txt_go then rank_txt_go:SetActive(true) end
			if rank_txt then rank_txt.text = Language:getTextByKey("compare_sword_rank_title_001") end
		end
	end
end

function M:refreshTimeText()
	local cur_timeStamp = UserDataManager:getServerTime()
	local _ , next_round_ts  = self.CompareSwordUtil:getRiseRaceTimeStamp(self.m_model.m_version , self.m_model.m_active_day,function()
		if self.m_control then self.m_control:closeView() end
		GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_1087"), delay_close = 2})
	end)
	
	local next_round_timeStamp = next_round_ts - cur_timeStamp
	local next_round_txt =  GameUtil:formatTimeBySecond(next_round_timeStamp, 999)

	self:setTextByLanKey("text_fight_value" ,next_round_txt)
end


function M:destroy()

	M.super.destroy(self)
end


return M