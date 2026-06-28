local M = class("FightDetailsPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_top_data = self.m_params
	self.m_id = UserDataManager.user_data:getUid()
	self.m_battle_logs = self:getBattleLogs()
end

function M:getBattleLogs()
	local new_tab = {}
	if self.m_top_data.group_data == nil or self.m_top_data.group_data.battle_log == nil then
		return new_tab
	end
	for k,v in pairs(self.m_top_data.group_data.battle_log) do
		for kk,vv in pairs(v.match) do
			if vv == self.m_id and v.win > 0 then
				if kk == 1 then
					local play_data = self:getGroupPlayerData(v.match[2])
					table.insert(new_tab, {id = v.match[2], battle_id = v.battle_id, play_data = play_data, win_id = v.win, team_id = v.team_id})
				else
					local play_data = self:getGroupPlayerData(v.match[1])
					table.insert(new_tab, {id = v.match[1], battle_id = v.battle_id, play_data = play_data, win_id = v.win, team_id = v.team_id})
				end
				break
			end
		end
	end
	for i = 127, 2, -1 do
		local c_playe = self.m_top_data.players[tostring(i)]
		if c_playe and c_playe.uid == self.m_id then
			local win_id, bt_id = self:getWinPy(i)
			if win_id > 0 then
				local other_data = self:getOtherPy(i)
				local parent_index = math.floor(i/2)
				table.insert(new_tab, {id = other_data.uid, battle_id = bt_id,play_data = other_data, win_id = win_id, team_id = parent_index})
			end
		end
	end
    local function sortFunc(id_one, id_two)
		return id_one.team_id < id_two.team_id
    end
    table.sort(new_tab, sortFunc)
	return new_tab
end

function M:getGroupPlayerData(id)
	return self.m_top_data.group_data.users[tostring(id)]
end

function M:getPlayerData(id)
	return self.m_top_data.players[tostring(id)]
end


function M:getWinPy(index)
	if index == 1 then
		return self.m_top_data.players[tostring(2)].uid, self.m_top_data.players[tostring(3)].battle_id
	end
	local parent_index = math.floor(index/2)
	if self.m_top_data.players[tostring(parent_index)] then
		return self.m_top_data.players[tostring(parent_index)].uid, self.m_top_data.players[tostring(parent_index)].battle_id
	end
	return  0
end

function M:getOtherPy(index)
	local parent_index = math.floor(index/2)
	if parent_index*2 == index then
		return self.m_top_data.players[tostring(parent_index*2 +1)]
	else
		return self.m_top_data.players[tostring(parent_index*2)]
	end
	return  0
end

function M:getDataById(team_id ,id)
	if team_id >= 1000 then
		return self.m_top_data.group_data.users[tostring(id)]
	else

	end
end

return M
