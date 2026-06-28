local M = class("CompareSwordResultView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/CompareSwordResult/CompareSwordResult"
M.m_iphoneXAdapter = true
M.m_size_type = 1

local bg_btn = {first_node_img = 1,second_node_img =2,thirdly_node_img=3}

function M:onEnter()
	self.CompareSwordUtil = require("UI.CompareSwordWithWorld.compareSwordWithWorldUtil").new(self.m_model.m_version)
	--排名1 2 3 的格子 
	self.m_frist_rank = self:findGameObject("first_node"):GetComponent("LuaBehaviour");
	self.m_second_rank = self:findGameObject("second_node"):GetComponent("LuaBehaviour")
	self.m_third_rank = self:findGameObject("thirdly_node"):GetComponent("LuaBehaviour")
	self.m_rank_behaviour = {
		[1] = self.m_frist_rank,
		[2] = self.m_second_rank,
		[3] = self.m_third_rank,
	}
	self:refreshUI()
	local info_cfg , time_cfg = self.CompareSwordUtil:parseRacePhaseCfg()
	self:setTextByLanKey("close_title_text" , info_cfg[4].name)
end

function M:refreshUI()
	local cfg = self.m_model.m_all_actives_cfg or {}
	self:setObjectVisible("btn_history",table.nums(cfg) > 1)
	local time_str = ""
	for k,v in ipairs(cfg) do
		if v.version == self.m_model.m_version then
			time_str = GameUtil:getTimeStrByActivves(v)
		end
	end
	self:setTextByLanKey("text_time",time_str)
	self:updateTopData()
end

function M:updateTopData()
	local top_data = self.m_model:getTopData()
	for i = 1, 3 do
		if top_data[i] ~= nil then
			self:updateRank(self.m_rank_behaviour[i], top_data[i]);
		else
			self:hideRank(self.m_rank_behaviour[i], i)
		end
	end
end

function M:hideRank( cur_LuaBehaviour, rank )
	if cur_LuaBehaviour ~= nil then

		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "img_spine_node", false)
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_playerName", "")
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_playerPowerVlaue", "")
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_serverName", "")
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "Img_fightBG", false)
	end
	--local good = cur_LuaBehaviour:FindGameObject("good"..rank);
	--good:SetActive(false);
	--local good_num_bg = cur_LuaBehaviour:FindGameObject("good" .. rank .. "_bg");
	--good_num_bg:SetActive(false);
	--local good_num_txt = cur_LuaBehaviour:FindGameObject("good_num_txt");
	--good_num_txt:SetActive(false);
	--
	--local player_name_txt = cur_LuaBehaviour:FindText("player_name");
	--player_name_txt.text = Language:getTextByKey("new_str_0079");
end

function M:updateRank( cur_LuaBehaviour, rank_data )
	if cur_LuaBehaviour ~= nil then
		--玩家名字
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_playerName", rank_data.name)
		--玩家战力
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "Img_fightBG", true)
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_playerPowerVlaue", rank_data.full_combat)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "img_spine_node", true)
		----加载spine动画
		local hero = cur_LuaBehaviour:FindGameObject("img_spine_node")
		local cfg = ConfigManager:getPlayerPictureCfg(rank_data.avatar);
		local spine_name = cfg.hero_spine or "hero_0216_SkeletonData" ;
		GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
		
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "HeadNode", false)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "tx_mask", false)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "border_img", false)
		LuaBehaviourUtil.setObjectVisible(cur_LuaBehaviour, "lv_bg", false)
		local server_name = rank_data.server_name or ""
		if server_name == "" then
			server_name = tonumber(rank_data.server) == 0 and  UserDataManager.server_data:getServerName() or UserDataManager.server_data:getServerNameById(rank_data.server)
		end
		server_name = "[" .. server_name .. "]"
		LuaBehaviourUtil.setTextByLanKey(cur_LuaBehaviour, "text_serverName", server_name)
	end
end

function M:onButtonClick(obj, name)
	if name == "close_btn" or name == "big_close_btn" then
		self:updateMsg(99999)
		audio:SendEvtUI("Ui_Page_Close")
	else
		if bg_btn[name] then
			self:updateMsg("look_player", {bg_btn[name]})
		else
			self:updateMsg(name, obj)
		end
		local full_btn_name = self.m_uiName .. "/" .. name
		GameUtil:playBtnSound(full_btn_name)
	end
	
end

function M:destroy()
	M.super.destroy(self)
end

return M