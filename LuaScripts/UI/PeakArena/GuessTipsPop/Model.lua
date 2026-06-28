local M = class("GuessTipsPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "up_to_down"
	M.super.onCreate(self)
	self:getData("arena_inner_index")
end

function M:onEnter()
	self.m_team_id = self.m_params.team_id
end	

function M:checkIsWin()
	local guess_data = self:getGuessResult()
	if next(guess_data) ~= nil then
		if guess_data[1] == guess_data[2] then
			return true
		else
			return false	
		end
	end
	return false
end

function M:getCurBattleStatusName()
	local team_id = self.m_team_id
	if team_id >= 1000 then
		return Language:getTextByKey("peak_str_0032") 
	elseif team_id >= 32 then
		return Language:getTextByKey("peak_str_0039") 
	elseif team_id >= 16 then
		return Language:getTextByKey("peak_str_0040") 
	elseif team_id >= 8 then
		return Language:getTextByKey("peak_str_0041") 
	elseif team_id >= 4 then
		return Language:getTextByKey("peak_str_0042") 
	elseif team_id >= 2 then
		return Language:getTextByKey("peak_str_0034") 
	else
		return Language:getTextByKey("peak_str_0034") 
	end
end

function M:getGuessResult()
	return self.m_data.guess_data[tostring(self.m_team_id)] or {}
end

function M:getWinNum()
	local guess_data = self:getGuessResult()
	if next(guess_data) ~= nil then
		return guess_data[3]
	end
	return 0
end

function M:getGuessPlayer()
	local guess_data = self:getGuessResult()
	return self:getGuessPlayerData(guess_data[1])
end

function M:getGuessPlayerData(uid)
	return self.m_data.quiz_data.user_data[tostring(uid)]
end

return M
