local M = class("UnionBossPopView",LikeOO.OOPopBase)

M.m_uiName = "UnionBoss/UnionBossPop"
M.m_size_type = 1
M.m_iphoneXAdapter = true
function M:onEnter()
	self.title_text = self:findText("title_text")
	self.challenge_text = self:findText("challenge_text")
	self.times_text = self:findText("times_text")
	self.down_time_text = self:findText("top_down_time_text")
	self.skill_panel = self:findGameObject("skill_panel")
	self.tips_text = self:findGameObject("tips_text")
	self.reset_time_text = self:findText("reset_time_text")
	self:setObjectVisible("BosshpBar", false)
	self:setTextByLanKey("challenge_btn_text", "new_str_0219")
	self:setTextByLanKey("close_title_text", "union_boss_str_0005")
	self.challenge_text.text = Language:getTextByKey("union_boss_str_0003")
	self:refreshUI()
	self:updateBossSkill()
	self:initDownTime()
end

function M:refreshUI()
	local BossHead = self:findGameObject("BossHead")
	local boss_user = self.m_model:getDefenderUserData()
	GameUtil:setUserAvatar(BossHead, boss_user,nil,nil,{show_flag = true, scale = 1})
	local left_times = self.m_model:getLeftTimes()
	self.times_text.text = Language:getTextByKey("world_boss_str_0001") .. left_times
	local world_boss = ConfigManager:getCfgByName("guild_boss")
	local world_cfg = world_boss[self.m_model.guild_boss_id]
	self:updateLoopScroll()
	self:showHp()
end

function M:showHp()
	self:setObjectVisible("BosshpBar", true)
	self:setObjectVisible("dmg", true)
	self:setTextByLanKey("dmg", self.m_model:showBossHp())
	self.boss_hpValue = self:findImage("hpValue")
	local roat = self.m_model:showBossHpPercentage()
	self.boss_hpValue.fillAmount = roat
end


function M:updateBossSkill()
	local world_boss = ConfigManager:getCfgByName("guild_boss")
	local union_cfg = world_boss[self.m_model.guild_boss_id]
	--local stage_battle = ConfigManager:getCfgByName("stage_battle")
	local battle_cfg = ConfigManager:getCfgStageBattle(union_cfg.battle_id)--stage_battle[union_cfg.battle_id]
	local boss = battle_cfg.monster[battle_cfg.boss_position]
	local hero_detail = ConfigManager:getCfgByName("hero_detail")
	local boss_cfg = hero_detail[boss.id]
	local num = self.skill_panel.transform.childCount
	for i=1,num do
		local skill_bg = self.skill_panel.transform:GetChild(i-1)
		skill_bg.gameObject:SetActive(false)
		if i <= #boss_cfg.skill then
			skill_bg.gameObject:SetActive(true)
			local skill_img = self:findGameObject(string.format("skill_%d_img", i))
			local skill = GameUtil:getSkill(boss_cfg.skill[i][1][1]) 
			UIUtil.setImg(skill_img, skill.icon, "skill_icon")
		end
	end
end

function M:initDownTime()
	local function tick(dt)
		local end_ts = self.m_model.m_data.end_day_ts
		local down_time = end_ts - UserDataManager:getServerTime()
		if down_time >= 0 then
			local text = GameUtil:formatTimeBySecond(down_time)
			self.down_time_text.text = text..Language:getTextByKey("world_boss_str_0004")
		else
			self:updateMsg("fresh_data")
		end
	end
	self.tick_id = self.m_control:setTimer(1, tick)
	tick()
	local res_ts = self.m_model.m_data.end_week_ts
	local wk_time = res_ts - UserDataManager:getServerTime()
	if wk_time >= 0 then
		local w_text = self:getDay(wk_time)
		if w_text > 0 then
			self.reset_time_text.text = Language:getTextByKey("union_boss_str_0001", w_text)
		else
			self.reset_time_text.text = Language:getTextByKey("union_boss_str_0004", self:getHour(wk_time))
		end
	end
end

--[[
	创建掉落列表
]]
function M:updateLoopScroll()
    self.m_cell_tab = {}
	local data = self.m_model.m_reward
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
                self.m_cell_tab[index] = cell_object
                GameUtil:updateItemElement(cell_object, cell_data,false,true)
			end,
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end


function M:showTipsDetail(flag)
	self.tips_detail_panel:SetActive(flag)
end

local __math_modf = math.modf
local __math_max = math.max

function M:getDay(tim)
	local n = __math_max(0,tim)
	local day = __math_modf(n / 86400)
	return day
end

function M:getHour(tim)
	local n = __math_max(0,tim)
	local hour = __math_modf(n / 3600)
	return hour
end


return M