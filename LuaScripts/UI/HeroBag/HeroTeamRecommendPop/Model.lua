local M = class("HeroTeamRecommendPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData("hero_collect")
end

function M:onEnter()
	self.m_heros_cid = {}
	local heros_data = UserDataManager.hero_data.hero_collect
	for k,v in pairs(heros_data) do
		self.m_heros_cid[tonumber(k)] = true
	end

	local push_formation = ConfigManager:getCfgByName("push_formation")
	self.m_list_data = {}
	for i,v in ipairs(push_formation) do
		local collect_num = 0
		local received = self:getIsReceived(i)
		local receive_state = 2 -- 已领取
		if received == false then
			receive_state = 1 -- 可领取
			for ii,vv in ipairs(v.hero or {}) do
				if self:getHeroActivationFlag(vv) == 0 then
					receive_state = 0 -- 不可领取
				else
					collect_num = collect_num + 1
				end
			end
		else
			collect_num = #v.hero
		end
		self.m_list_data[i] = {cfg = v, collect_num = collect_num, visible = false, receive_state = receive_state}
	end
end

function M:getHeroActivationFlag(cid)
	if self.m_heros_cid[cid] then
		return 1
	end
	return 0
end

function M:setDesOpen(index)
	self.m_list_data[index].visible = not self.m_list_data[index].visible
end

function M:getIsReceived(id)
	if table.keyof(self.m_data.formations or {}, id) then
		return true
	end
	return false
end

function M:updateData(data)
	self.m_data.formations = data.formations
	for i,v in ipairs(self.m_data.formations or {}) do
		self.m_list_data[v].receive_state = 2
	end
end

return M
