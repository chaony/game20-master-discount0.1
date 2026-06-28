local M = class("HeroFetterPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

M.dataTime = 22

function M:onEnter()
	self.reward = self.m_params.data.rewards
	self.m_callback = self.m_params.callback
	self.cur_feeter = self:getShowFetterData()
end

function M:getShowFetterData()
	local temp_data = nil
	self.new_reward = {}
	if table.nums(self.reward) > 0 then
		temp_data = self.reward[1]
		if table.nums(self.reward) > 1 then
			for i = 2, table.nums(self.reward) do
				table.insert(self.new_reward, self.reward[i])
			end
		end
	end 
	return temp_data
end

function M:getFetterName()
	local hero_friend = ConfigManager:getCfgByName("hero_friend")
	local temp_data = hero_friend[self.cur_feeter.id]
	return temp_data.name
end

function M:getFeeterProByLv()
	local hero_friend = ConfigManager:getCfgByName("hero_friend")
	local feeter_data = hero_friend[self.cur_feeter.id]
	local pro = feeter_data.level_buff[self.cur_feeter.level][1]
	local p_key = GameUtil:getAttrsKey(pro[1])
	local p_name = GameUtil:getAttrsName(p_key)
	local enum_cfg = GameUtil:getAttrCfg(pro[1])

	if GameUtil:attrTransition(enum_cfg.user_key) == true then
		if enum_cfg.user_key == "critrate" then
			return p_name.." +"..GameUtil:formatNum(pro[2]).."%"
		end
		return p_name.." +"..GameUtil:formatNum(pro[2]*100).."%"
	else
		return p_name.." +"..pro[2]	
	end
end


return M
