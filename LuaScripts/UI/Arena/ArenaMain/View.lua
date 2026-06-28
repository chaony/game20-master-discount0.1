local M = class("ArenaMainView",LikeOO.OOPopBase)

M.m_uiName = "Arena/ArenaMain"
M.m_size_type = 2
local __arena_data_key = {"arena", "high_arena", "high_arena2"}

function M:onEnter()
	self:setTextByLanKey("close_title_text", "new_str_0504")
	self:refreshUI()
end

function M:refreshUI()
	self:updateArenaInfo()
end

function M:updateArenaInfo()
	for k,v in ipairs(__arena_data_key) do
		local arena_cell = self:findGameObject("arena_cell" .. k)
		local luaBehaviour = UIUtil.findLuaBehaviour(arena_cell)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_title_text", "new_str_0247")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_title_text", "new_str_0246")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "def_title_text", "new_str_0505")
		local cell_data = self.m_model:getArenaDataByKey(v)
		if cell_data then
			local rank = cell_data.rank or 0
			if rank <= 0 then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0506")
			else
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
			end
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "def_text", tostring(cell_data.combat))
			local time_text = luaBehaviour:FindGameObject("time_text")
			self:setLimitTimeText(cell_data, luaBehaviour)
			local luaGameObjectUpdater = time_text:GetComponent("LuaGameObjectUpdater")
			luaGameObjectUpdater:RegistLuaUpdate(function(dt, undt)
				self:setLimitTimeText(cell_data, luaBehaviour)
			end, 1)
			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "arena_coin_store_text", tostring(cell_data.arena_coin_store))
		end
	end
end

function M:setLimitTimeText(cell_data, luaBehaviour, text_key)
	local last_time = cell_data.last_time or 0
	local diff_time = last_time - UserDataManager:getServerTime()
	if diff_time > 0 then
		local ft = GameUtil:formatTimeBySecond(diff_time)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text",ft)
	else
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, text_key or "limit_time_text", Language:getTextByKey("new_str_0487"))
	end
end

return M