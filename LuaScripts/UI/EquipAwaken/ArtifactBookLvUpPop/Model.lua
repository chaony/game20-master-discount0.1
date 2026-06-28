local M = class("ArtifactBookLvUpPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_type_index = self.m_params.type_index or 1 --类型
	self.m_quality_level = self.m_params.quality_level or 0 --等级
end


function M:getThronsUpgrade()
	return UserDataManager.m_thrones_upgrade
end

--当前强化等级
function M:getThronslvByIndex(id)
	if next (UserDataManager.m_thrones_upgrade) == nil then
		return 0
	end
	if UserDataManager.m_thrones_upgrade.level and UserDataManager.m_thrones_upgrade.level[tostring(id)] then
		return UserDataManager.m_thrones_upgrade.level[tostring(id)].lv or 0
	end
	return 0
end

--当前等级上限
function M:getThronsMaxlvByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level
	local cur_throne = tag_tab[evo]
	return cur_throne.limit
end

--下级等级上限
function M:getThronsNextMaxlvByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level+1
	local cur_throne = tag_tab[evo]
	return cur_throne.limit
end

--当前星级
function M:getThronsStarByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level or 0
	local cur_throne = tag_tab[evo] 
	return cur_throne.star
end

--下一星级
function M:getNextThronsStarByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level or 0
	local cur_throne = tag_tab[evo+1] 
	if cur_throne then
		return cur_throne.star
	end
	return 3
end

--当前展示品质等级
function M:getThronsShowQualityByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level or 0
	local cur_throne = tag_tab[evo] or {}
	return cur_throne.show_quality or 0
end

--下一展示品质等级
function M:getNextThronsShowQualityByIndex()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local evo = self.m_quality_level or 0
	local cur_throne = tag_tab[evo + 1] or {}
	return cur_throne.show_quality or 0
end

--进阶消耗
function M:getThronsConsByIndex() 
	local lv = self:getThronslvByIndex(self.m_type_index)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	return tag_tab[self.m_quality_level].consume or {}
end

--加成属性
function M:getThronsAttrByIndex() 
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local attr = {}
	local next_throne = tag_tab[self.m_quality_level+1]
	local cur_throne = tag_tab[self.m_quality_level]
	local next_attr = next_throne.attr1
	local cur_attr = cur_throne.attr1
	return next_attr
end

--根据属性类型获取当前属性
function M:getThroneCurAttr(id)
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local cur_throne = tag_tab[self.m_quality_level]
	local cur_attr = cur_throne.attr1
	for k,v in pairs(cur_attr) do
		if id == v[1] then
			return v[2]
		end
	end
	return 0
end

--附加属性
function M:getAddAttrsStr()
	local tag_tab = ConfigManager:getCfgByName("equip_throne_evo")
	local cur_throne = tag_tab[self.m_quality_level]
	local cur_attr = cur_throne.attr2
	local next_throne = tag_tab[self.m_quality_level+1]
	local next_attr = next_throne.attr2
	local str = Language:getTextByKey("equip_awake_013")
	local keep_out_flag = false
	for i,v in ipairs(next_attr) do
		keep_out_flag = false
		local cur_num = v[2]
		for ii, vv in ipairs(cur_attr) do
			if v[1] == vv[1] then
				cur_num = cur_num - vv[2]
				if cur_num <= 0 then
					keep_out_flag = true
					break
				end
			end
		end
		if keep_out_flag == false then
			local atk_key = GameUtil:getAttrsKey(v[1])
			local atk_name =  GameUtil:getAttrsName(atk_key)
			if GameUtil:canPerAttrTransition(atk_key) == true then
				cur_num = cur_num*100
			end
			if GameUtil:attrTransition(atk_key) == true then
				str = str..atk_name.."  +"..cur_num.."%".."  "
			else
				str = str..atk_name.."  +"..cur_num.."  "
			end
		end
		
	end
	return str
end

return M
