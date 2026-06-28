local M = class("HeroBookShowModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_open_tab_index = 1
	self.m_sel_tab_index = 0
	self.m_cur_id = self.m_params.h_id
	self.m_type = self.m_params.type
	self.m_book_list = self:getHeroTj()
end

--英雄图鉴数据
function M:getHeroTj()
    local book_tab = ConfigManager:getCfgByName("book")
    local b_list = {}
	for k,v in pairs(book_tab) do
		if v.unlock == 1 then
			table.insert(b_list, {id = k, data = v})
		end
    end
    self:heroIdsSort(b_list)
    return b_list
end

function M:getByCid(id)
    return UserDataManager.hero_data:getHeroConfigByCid(id)
end

function M:heroIdsSort(bks)
    local function sortFunc(id_one, id_two)
        local sequence1 = id_one.data.sequence
		local sequence2 = id_two.data.sequence
		local type_1 = id_one.data.sequence
		local type_2 = id_two.data.sequence
		if type_1 == type_2 then
			return sequence1 < sequence2
		else
			return type_1 < type_2
		end
    end
    table.sort(bks, sortFunc)
end

function M:checkHave(id)
    return UserDataManager.hero_data:checkHeroCollect(id)
end

function M:getHeroBigAnim()
	local cfg = self:getCfgByCid(self.m_cur_id)
	return cfg.hero_spine
end

function M:getSpinePos()
	local cfg = self:getCfgByCid(self.m_cur_id)
	local data_pos = cfg["spine_position"]
	return data_pos
end

function M:getCfgByCid(id)
	return UserDataManager.hero_data:getHeroConfigByCid(id)
end

function M:changeHero(data)
	self.m_cur_id = data.id
end

function M:switchTo(add, callback)
	local index = -1
	for k,v in pairs(self.m_book_list) do
		if self.m_cur_id  == v.id then
			index = k 
			break
		end
	end
	if index < 1 then
		return
	end
	if add == true then
		if index == #self.m_book_list then
			return
		else
			self.m_cur_id  = self.m_book_list[index+1].id
		end 
	else
		if index == 1 then
			return
		end	
		self.m_cur_id  = self.m_book_list[index-1].id
	end
	if callback then
		callback()
	end
end

function M:getHeroImgName()
	local cfg = self:getCfgByCid(self.m_cur_id)
	local name_string = cfg.icon
	if #name_string > 0 then
		local res = string.split(name_string, "_")
		return "a_ui_"..res[2]
	else
		return "a_ui_shenji"	
	end
end

--获取技能信息
function M:getHeroSkill()
	local cfg = self:getCfgByCid(self.m_cur_id)
	return cfg.skill
end

function M:checkSig()
	local mer_tab = ConfigManager:getCfgByName("equip_heroes")
	local hero_cfg =self:getByCid(self.m_cur_id)
	local cur_hero_data = mer_tab[hero_cfg.equip_heroes_id]	
	return cur_hero_data
end

--根据个位index获取穴位数据
function M:getPassNameByIndex(index)
	local id =  index
	local sig_cfg = self:checkSig()
	return sig_cfg.level_up[id]
end

function M:getMeridianAttrs()
	local sig_cfg = self:checkSig()
	return sig_cfg.level_up[#sig_cfg.level_up]["attr"]
end

function M:getSigLv()
	local sig_cfg = self:checkSig()
	return #sig_cfg.level_up
end

function M:getBaseInfoCellByIndex(index)
	local cfg = self:getCfgByCid(self.m_cur_id)
	if index == 1 then
		return "anecdote_sex", cfg.sex
	elseif index == 2 then
		return "anecdote_height", cfg.height
	elseif index == 3 then
		return "anecdote_age", cfg.age
	elseif index == 4 then
		--return "anecdote_birthday", Language:getTextByKey("anecdote_birthday_2",cfg.birthday[1],cfg.birthday[2])
	elseif index == 5 then
		--return "anecdote_potential", cfg.potential
	elseif index == 6 then
		return "anecdote_nature", cfg.nature
	elseif index == 7 then
		return "anecdote_like", cfg.like
	elseif index == 8 then
		return "anecdote_hate", cfg.hate
	elseif index == 9 then
		return "anecdote_interest", cfg.interest
	elseif index == 10 then
		return "anecdote_characteristic", cfg.characteristic
	end
end

function M:checkRedPoint()
	local bl = UserDataManager.hero_data:checkHeroCollectPoint(self.m_cur_id)
	return bl
end

function M:getHeroAttrs()
	local hero_attr = {}
	local cfg = self:getCfgByCid(self.m_cur_id)
	local max_lv = self:getHero_lv()
	local hero_attr = UserDataManager:computCfgAttrs(cfg, max_lv,cfg.max_evo)
	local attrs = {
		{"lv", max_lv}
	}
	local hero_attar_tab = ConfigManager:getCfgByName("hero_enumeration")
	for k,v in pairs(hero_attr) do
		if k == "hp" or k == "atk" or k == "def" then
			local num =  math.floor(v + 0.5)  
			table.insert( attrs, {k, num} )
		end
	end
	return attrs
end

function M:getAncedoteDescByIndex(index)
	local cfg = self:getCfgByCid(self.m_cur_id)
	local legend = "legend"..index
	return Language:getTextByKey(cfg[legend])
end

function M:getHero_lv()
	local tab_ = ConfigManager:getCfgByName("hero_evolution")
	local cfg = self:getCfgByCid(self.m_cur_id)
	local max_lv = tab_[cfg.max_evo]["level_max"]
	return max_lv
end

--检测传记开启条件
function M:checkAncedoteOpenByIndex(index)
	local evo = self:gatMaxEvoHeroById(self.m_cur_id)
	local cfg = self:getCfgByCid(self.m_cur_id)
	if evo >= cfg.evo + index then
		return true
	else
		return false	
	end
end

function M:getAncedotName(index)
	if index == 1 then
		return "anecdote_2"
	elseif index == 2 then
		return "anecdote_3"
	elseif index == 3 then
		return "anecdote_4"
	elseif index == 4 then
		return "anecdote_5"
	elseif index == 5 then
		return "anecdote_6"
	end
end

function M:getEvoName(index)
	local cfg = self:getCfgByCid(self.m_cur_id)
	index = cfg.evo + index
	local evo_data = ConfigManager:getCfgByName("hero_evolution")
	local data = evo_data[index]
	local color = GlobalConfig.HERO_QUALITY_COMMON_SETTING[index]
	local evo_name = "<color=#"..color.HC..">"..Language:getTextByKey(data.evo_name).."</color>"
	return evo_name..Language:getTextByKey("anecdote_7")
end

function M:gatMaxEvoHeroById(id)
	local ids_tab = UserDataManager.hero_data:getHerosId()
	local evo = 0
	for k,v in pairs(ids_tab) do
		local data, cfg =  UserDataManager.hero_data:getHeroDataById(v)
		if id == data.id and data.evo > evo then
			evo = data.evo
		end
	end
	return evo
end


return M
