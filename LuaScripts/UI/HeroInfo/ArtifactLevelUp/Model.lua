local M = class("ArtifactLevelUpModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_heroid = self.m_params.hero_id 
	self.m_artid = self.m_params.art_id 
	self.m_art_data, self.m_art_cfg = self:gerArtData()
end

function M:refreshData()
	self.m_art_data, self.m_art_cfg = self:gerArtData()
end

function M:gerArtData()
	local h_data, h_cfg = UserDataManager.hero_data:getHeroDataById(self.m_heroid)
	local data = h_data.artifact
	local cfg = UserDataManager.artifact_data:getArtifactConfigByCid(data.id)
	return data, cfg
end

function M:getAttrs()
	local attrs = self.m_art_cfg.level_up[self.m_art_data.lv].attr
	local list_ = {}
	if self.m_art_data.lv < #self.m_art_cfg.level_up then
		local next_attrs = self.m_art_cfg.level_up[self.m_art_data.lv+1].attr
		for k,v in pairs(next_attrs) do
			local parm = {
				c_attr = attrs[k],
				n_attr = v,
			}
			table.insert(list_, parm)
		end
	else
		local next_attrs = self.m_art_cfg.level_up[self.m_art_data.lv].attr
		for k,v in pairs(next_attrs) do
			local parm = {
				c_attr = attrs[k],
				n_attr = v,
			}
			table.insert(list_, parm)
		end
	end
	return list_
end

function M:getCostMoney()
	local cost =  self.m_art_cfg.level_up[self.m_art_data.lv].levelup_cost
	local data_money = RewardUtil:getProcessRewardData(cost[1])
	local data_item = RewardUtil:getProcessRewardData(cost[2])
	return data_money, data_item
end

function M:getCostItem()
	
end

--下级解锁
function M:nextUnLock()
	if self.m_art_data.lv < #self.m_art_cfg.level_up then
		local next_desc = self.m_art_cfg.level_up[self.m_art_data.lv+1]
		if next_desc.param_des and #next_desc.param_des > 0 then
				return next_desc.param_des
		end
	end
	return nil
end

function M:getNextLockDes()
	for i = (self.m_art_data.lv+1), #self.m_art_cfg.level_up do
		local next_desc = self.m_art_cfg.level_up[i]
		if next_desc.param_des and #next_desc.param_des > 0 then
			return i,next_desc.param_des
		end
	end
	return -1, ""
end

return M
