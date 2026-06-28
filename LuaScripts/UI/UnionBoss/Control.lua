local M = class("UnionBossPopControl",LikeOO.OOControlBase)

function M:onEnter()
    SceneManager:changeScene(SceneManager.SceneID.UnionBossScene, self.m_model)
    SceneManager:scenestart()
    local function callback()
        self:selectInitHeirLoom();
    end
    self.m_model.m_init_function = callback
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:updateMsg("fresh_red_point", nil, "Union.UnionHall")
        self:closeView()
        EventDispatcher:dipatchEvent("PlayShowAnimator",{ camp = -1,animator = "in" })
    elseif msg == "challenge_btn" then
        local left_times = self.m_model:getLeftTimes()
        if left_times > 0 then
            self:challengeWoldBossTeam()
            --SceneManager.curScene.plyMgr.enemy_list:get(0).tranformHelper:SetAnimator(false);
        else
            local params =
            {     
                text = "挑战次数已用完",
                no_close_btn = true,
            }
            self:openView("Pops.CommonPop",params)  
        end
    elseif msg == "record_btn" then
        local params = {}
        params.damage_log = self.m_model.m_data.damage_log
        self:openView("Activities.WorldBoss.WorldBossLog", params)
    elseif msg == "rank_btn" then
        self:openView("Activities.WorldBoss.WorldBossRank")
    elseif msg == "reward_btn" then
        if self.m_model.m_data.self_rank > 0 then
        local params = {}
            params.dan_data = self.m_model.m_reward
            params.rank = self.m_model.m_data.self_rank
            params.max_damage = self.m_model:getMaxBattleDamage()
            self:openView("Activities.WorldBoss.WorldBossReward", params)
        else
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("world_boss_str_0016"), delay_close = 2})
        end
    elseif msg == "help_btn" then
        local params = {}
        params.title = "tid#boss_rush4"
        params.content = "tid#boss_rush5"
        self:openView("Pops.CommonHelpPop", params)
    elseif msg == "tips_btn" then
        self.m_view:showTipsDetail(true)
    elseif msg == "tips_detail_panel" then
        self.m_view:showTipsDetail(false)
    elseif msg == "fresh_data" then
        self:freshNetData()
        SceneManager.curScene:resetCamera();
    elseif msg == "skill_1_img" then
        self:showSkill(1)
    elseif msg == "skill_2_img" then 
        self:showSkill(2)
    elseif msg == "skill_3_img" then 
        self:showSkill(3)
    elseif msg == "skill_4_img" then 
        self:showSkill(4)
    elseif msg == "select_heirloom" then
        self:selectHeirLoom(data)
    elseif msg == "heirloom_btn" then
        local params = {
            heirlooms = self.m_model.heirlooms,
            guild_heirlooms = self.m_model.guild_heirlooms
        }
        self:openView("UnionBoss.UnionRelicFormationShow", params)
    elseif msg == "kill_box_btn" then

    end
end

function M:selectInitHeirLoom()
    if self.m_model:checkFirstEnter() == true then
        local params = {
            heirloom_pool = self.m_model.free_heirloom_pool,
            mode = 1
        } 
        self:openView("UnionBoss.UnionRelicSelect", params)
    end
end

function M:checkKillHeirLoom()
    if next(self.m_model.battle_heirloom_pool) ~= nil then
        local params = {
            heirloom_pool = self.m_model.battle_heirloom_pool,
            mode = 0
        } 
        self:openView("UnionBoss.UnionRelicSelect", params)
    end
end

function M:showSkill(index)
	local world_boss = ConfigManager:getCfgByName("guild_boss")
	local union_cfg = world_boss[self.m_model.guild_boss_id]
	--local stage_battle = ConfigManager:getCfgByName("stage_battle")
	local battle_cfg = ConfigManager:getCfgStageBattle(union_cfg.battle_id)--stage_battle[union_cfg.battle_id]
	local boss = battle_cfg.monster[battle_cfg.boss_position]
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local boss_cfg = hero_detail[boss.id]
    self:openView("Pops.SkillPop",{skill = boss_cfg.skill[index], index = index, cur_lv = 1 })
end

function M:freshNetData()
    local function receivetCallback(response)
        self.m_model:updateData(response)
        self.m_view:refreshUI()
        self:checkKillHeirLoom()
    end
    self.m_model:getNetData("guild_boss_index", nil, receivetCallback)
end

function M:requestReceive(data)
	local function receivetCallback(response)
        RewardUtil:rewardTipsByData(response.reward)
        self.m_model:updateData(response.seven_tour_received)
        self.m_view:refreshUI()
    end
    local params = {}
    params.day = data
    self.m_model:getNetData("active_receive_seven_tour", params, receivetCallback)
end

function M:challengeWoldBossTeam()
    local giold_boss = ConfigManager:getCfgByName("guild_boss")[self.m_model.guild_boss_id]
    local params = {
        mode = GlobalConfig.BATTLE_MODE.UNION_BOSS,
        battle_id = giold_boss.battle_id,
        battle_config_id = self.m_model.guild_boss_id,
        boss_hp = self.m_model.boss_hp
    }
    self:openView("Formation", params)
    EventDispatcher:dipatchEvent("PlayShowAnimator",{ camp = -1,animator = "in" })
end

--选择遗物
function M:selectHeirLoom(data)
    self.m_model:getNetData("guild_boss_select_heirloom",{heirloom_id = data.id, is_free = data.mode})
end

--领取奖励
function M:getKillReward()
    local function callfunc(response)
        RewardUtil:rewardTipsByData(response.reward)
	end
    local data = {
        heirloom_id = 0,
        is_free = 0
    }
    self.m_model:getNetData("guild_boss_recv_killed_reward", data, callfunc)
end

function M:onDestroy()
    SceneManager:changeScene(SceneManager.SceneID.HangUpScene)
end

return M;
