local M = class("GroupGameNode", LikeOO.OOUIbase)

M.m_uiName = "PeakArena/GroupGameNode"

function M:onEnter()
    self.left_index = 1
    self.right_index = 1
    self:refreshUI()
end

function M:refreshUI()
    local left_data = self.m_model:getBattlePlayerData(1)
	local right_data = self.m_model:getBattlePlayerData(2)
	if left_data == nil or right_data == nil or right_data.user == nil then
		return
	end
	local left_head = self:findGameObject("left_head")
	local right_head = self:findGameObject("right_head")
	self:setTextByLanKey("left_name", left_data.user.name)
	self:setTextByLanKey("right_name", right_data.user.name)
    local left_server_name = UserDataManager.server_data:getServerNameById(left_data.user.server)
    local right_server_name = UserDataManager.server_data:getServerNameById(right_data.user.server)
    self:setTextByLanKey("left_server_text", left_server_name)
	self:setTextByLanKey("right_server_text", right_server_name)
	self:setTextByLanKey("left_combat", Language:getTextByKey("friend_str_0041")..left_data.combat or 0 )
	self:setTextByLanKey("right_combat", Language:getTextByKey("friend_str_0041")..right_data.combat or 0)
	self:setSpine(1,self.m_model:getUserHeadAvatar(left_data.user.avatar))
	self:setSpine(2,self.m_model:getUserHeadAvatar(right_data.user.avatar))
	GameUtil:setUserAvatar(left_head, left_data.user, false, false,{show_flag = true, scale = 1})
	GameUtil:setUserAvatar(right_head, right_data.user, false, false,{show_flag = true, scale = 1})
    self:upeateSelectTeam()
    self.hero_team = self.m_model:geMyGameTeams()
end

function M:upeateSelectTeam()
    for i = 1,3 do
        if self.left_index == i then
            self:setImg("a_dflj_yeqian_liangdi", "active_ui", "l_team_btn_"..i)
            self:setTextColor("left_team_name"..i, GlobalConfig.COMMON_COLLOR.COMMON_2)
        else
            self:setImg("a_dflj_yeqian_andi", "active_ui", "l_team_btn_"..i)
            self:setTextColor("left_team_name"..i, GlobalConfig.COMMON_COLLOR.COMMON_5)
        end
        if self.right_index == i then
            self:setImg("a_dflj_yeqian_liangdi", "active_ui", "r_team_btn_"..i)
            self:setTextColor("right_team_name"..i, GlobalConfig.COMMON_COLLOR.COMMON_2)
        else
            self:setImg("a_dflj_yeqian_andi", "active_ui", "r_team_btn_"..i)
            self:setTextColor("right_team_name"..i, GlobalConfig.COMMON_COLLOR.COMMON_5)
        end
    end
    local l_data = self.m_model:getTeams(1)
    local r_data = self.m_model:getTeams(2)
    local team_l = l_data[self.left_index] or {}
    local team_r = r_data[self.right_index] or {}
    self:updateTeams(team_l, team_r)
end

function M:updateTeams(team_1, team_2)
    for i = 1,10 do
        local hero_cfg_id = i<=5 and team_1[i] or team_2[i-5]
        local hero_node = self:findGameObject("hero_"..i)
        if hero_cfg_id then
            if hero_cfg_id == "" then
				CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
			else
				local data, cfg = UserDataManager.hero_data:getHeroDataById(hero_cfg_id) 
				if data then
					local reward_data = RewardUtil:getProcessRewardData({101,data.id,1, hero_cfg_id})
					local function lookHero(item_object, item_data)
						self:updateMsg("look_hero", {oid = hero_cfg_id, data = self.hero_team})
					end
					CommonUIUtil:updateHeroElementByData(hero_node, reward_data,lookHero)
				else
					data = self.m_model:getEnemyHeroData(hero_cfg_id)
					local function lookHero(item_object, item_data)
						self:updateMsg("look_hero", {oid = hero_cfg_id, data = self.hero_team})
					end
					if data then
						local reward_data = RewardUtil:getProcessRewardData({101,data.id,1})
						CommonUIUtil:updateHeroElementByData(hero_node, reward_data,lookHero)
						CommonUIUtil:updateHeroLvByData(hero_node, data)
					else
						CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
					end
				end
			end
        else
            CommonUIUtil:updateHeroElementAdd(hero_node, nil, true)
        end
    end
end

function M:onButtonClick(obj, name)
    if self.m_model:checkCanClick() == false then
        self.m_control:checkIsClose()
        return
    end
    if name == "l_team_btn_1" then
        self.left_index = 1
        self:upeateSelectTeam()
    elseif name == "l_team_btn_2" then
        self.left_index = 2
        self:upeateSelectTeam()
    elseif name == "l_team_btn_3" then
        self.left_index = 3
        self:upeateSelectTeam()
    elseif name == "r_team_btn_1" then
        self.right_index = 1
        self:upeateSelectTeam()
    elseif name == "r_team_btn_2" then
        self.right_index = 2
        self:upeateSelectTeam()
    elseif name == "r_team_btn_3" then    
        self.right_index = 3
        self:upeateSelectTeam()
    elseif name == "left_btn" then
        if self.m_model.m_selete_index == 3 and self.m_model.m_battle_index_64 > 1 then
            self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 - 1
            self:refreshUI()
        end
    elseif name == "right_btn" then
        if self.m_model.m_selete_index == 3 and self.m_model.m_battle_index_64 < 8 then
            self.m_model.m_battle_index_64 = self.m_model.m_battle_index_64 + 1
            self:refreshUI()
        end    
    else
        self:updateMsg(name)
    end
end

function M:setSpine(index, hero_spine)
	local play_img = index == 1 and self:findGameObject("left_hero_spine") or self:findGameObject("right_hero_spine")
	if hero_spine == nil then
		hero_spine = "hero_0181_SkeletonData"
	end
	GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..hero_spine, "idle", 0, true)
end



function M:destroy()
    M.super.destroy(self)
end

return M
