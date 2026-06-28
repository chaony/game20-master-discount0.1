local M = class("RacconGameModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_id = 360
	self.m_game_cfg = ConfigManager:getCfgByName("puzzle_jieyuanbao")
	self.m_item_cfg = ConfigManager:getCfgByName("puzzle_jieyuanbao_item")
	self.m_game_end_cfg = ConfigManager:getCfgByName("tongyong_little_game_end")
	self.m_little_game_cfg = ConfigManager:getCfgByName("tongyong_little_game")
	self.m_active_cfg = UserDataManager:getActivesDataByOpenId(self.m_open_id)
	self.m_version = self.m_active_cfg["version"]
	self.m_game_id = 6001
	self.m_current_score = 0
	self.m_character_state = 1  -- 1 idle, 2 run
	self.m_character_move_range =  {-610, 600}
	self.m_left_time = self.m_game_cfg[self.m_game_id]["time"]
end

-- 游戏分数
function M:getCurrentScore()
	return self.m_current_score
end

function M:addScore(delta_score)
	self.m_current_score = self.m_current_score + delta_score
end

-- 游戏时间
function M:getLeftTime()
	return self.m_left_time
end

function M:addLeftTime(delta_time)
	self.m_left_time = self.m_left_time + delta_time
end

function M:countDownLeftTime(delta_time)
	self.m_left_time = self.m_left_time - delta_time
end

-- 角色状态
function M:setCharacterState(state)
	self.m_character_state = state
end

function M:isCharacterRunning()
	return self.m_character_state == 2
end

-- 角色移动范围
function M:getCharacterMoveRange()
	return self.m_character_move_range
end

-- 获取配置数据
function M:getGameCfg()
	return self.m_game_cfg[self.m_game_id]
end

function M:getItemCfg()
	return self.m_item_cfg[self.m_game_id]
end

function M:getCharacterSpeed()
	return self.m_game_cfg[self.m_game_id]["human_speed"]
end

function M:getGameEndContent(score)
	local content
	for k, v in ipairs(self.m_game_end_cfg[1]) do
		if score >= v["ability"][1] and score <= v["ability"][2] then
			content = v["epilogue"]
			break
		end
	end
	return content
end

function M:getGameVersion()
	return self.m_version
end

function M:getOpenID()
	return self.m_open_id
end

function M:getGameID()
	return self.m_game_id
end

return M
