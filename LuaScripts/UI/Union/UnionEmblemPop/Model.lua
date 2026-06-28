local M = class("UnionEmblemModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_guild = self.m_params.guild
	self.m_parent = self.m_params.parent
	self.m_select = self.m_guild and self.m_guild.flag or 1
	self.m_lv = self.m_guild and self.m_guild.level or 1
	self:updateListData()
end

function M:updateListData()
	local flag_tab = ConfigManager:getCfgByName("guild_flag")
	local new_tab = {}
	local num = 0
	for k,v in pairs(flag_tab) do
		if k%8 == 0 then
			new_tab[k] = {icon="a_bh_icon_1" ,kong=true,unlock_level=1}
			num = num + 1
		end
		v.kong = false
		v.id = k
		new_tab[k+num] = v
	end
	local tab_all_num = table.nums(new_tab)
	local c_tab_num = tab_all_num%4
	for i=c_tab_num+1, 4 do
		table.insert(new_tab, {icon="a_bh_icon_1" ,kong=true,unlock_level=1})
	end
	self.m_list_data = new_tab
end

function M:setSelect(index)
	self.m_select = index
end

return M
