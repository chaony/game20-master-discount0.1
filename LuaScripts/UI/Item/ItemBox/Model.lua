local M = class("ItemBoxModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_show_data = self.m_params.show_data
	self.m_use_num = self.m_params.use_num or 1
	self.m_cur_select_index = 0
end

function M:getUseNum()
	return self.m_use_num
end

function M:getShowData()
	if self.m_show_data.item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		return self.m_show_data.item_effect or {}
	end
	return self.m_show_data.item_cfg.effect
end

function M:getDataCount()
	return #self.m_show_data.item_cfg.effect
end

function M:getDataByIndex(index)
    return self.m_show_data.item_cfg.effect[index]
end

--- 网络数据回调
function M:netData(data, tag)
	local item_id = self.m_show_data.data_id
	local item_data = UserDataManager.item_data:getItemDataById(item_id)
	self.m_show_data.user_num = item_data.num
end

function M:isHeroReward()
	local show_data = self.m_show_data
	local item_cfg = show_data.item_cfg or {}
	local effect = item_cfg.effect or {}
	if item_cfg.type == GlobalConfig.ITEM_TYPE.SEASON_BOX then
		effect = show_data.item_effect or {}
	end
	local flag = true
	for k,v in pairs(effect) do
		if v[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS then
			flag = false
			break
		end
	end
	return flag
end

return M
