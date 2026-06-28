local M = class("RpgScrollsUIModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("rpg_index")
end

function M:onEnter()
	self.team_datas = self.m_data.team_datas
	--self.cur_chapter = self.m_data.cur_chapter --正在挑战的关卡
	self.team_cfg = self:getList()
end

function M:getList()
	local cfg = {}
	local tab = ConfigManager:getCfgByName("roleplaying_team")
	for k,v in pairs(tab) do
		table.insert(cfg, {id = k , data = v})
	end
	self:sort(cfg)
	return cfg
end

--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(one, two)
        return one.id < two.id
    end
    table.sort(pros, sortFunc)
end
  
function M:getTypeName(id)
	local cur_data = self.team_datas[tostring(id)]
	if cur_data then
		if cur_data.status == 0 and cur_data.cur_chapter == -1 then
			return "a_ui_shenzhoutanmi_xin" -- 新
		elseif cur_data.status == 0 and cur_data.cur_chapter == 0 then
			return "" --  空
		elseif  cur_data.status == 0 then
			return "a_ui_shenzhoutanmi_jsz" --"进行中"
		elseif cur_data.status == 1 then
			return "a_ui_shenzhoutanmi_ywc" --"已完成"	
		end
	end
	return "a_ui_shenzhoutanmi_wkq" --未开启
end

function M:checkLock(id)
	local cur_data = self.team_datas[tostring(id)]
	if cur_data then
		return true
	end
	return false
end

function M:getChapterById(team_id)
	local cur_data = self.team_datas[tostring(team_id) ]
	return cur_data
end

function M:canlock(c_id)
	local tab = ConfigManager:getCfgByName("roleplaying_team")
	local t_data = tab[c_id]
	if t_data then
		for k,v in pairs(t_data.hero) do
			if self:checkHero(v) == false then
				return false
			end
		end
	end
	return true
end

function M:getHeroNames(c_id)
	local str = ""
	local tab = ConfigManager:getCfgByName("roleplaying_team")
	local t_data = tab[c_id]
	if t_data then
		for k,v in pairs(t_data.hero) do
			local cfg = UserDataManager.hero_data:getHeroConfigByCid(v)
			if self:checkHero(v) == true then
				str = str.." <color=#F5D181>".. Language:getTextByKey(cfg.name).."</color> \n"
			else
				str = str.." <color=#5E5E5E>".. Language:getTextByKey(cfg.name) .."</color> \n"
			end
		end
	end
	return str
end

function M:checkHero(c_id)
	local ids = UserDataManager.hero_data:getHerosId()
	for k,v in pairs(ids) do
		local cfg, data = UserDataManager.hero_data:getHeroDataById(v)
		if data.id == c_id then
			return true
		end
	end
	return false
end

function M:updateData(call_back)
    local function callback(response)
		self.team_datas = response.team_datas
        if call_back then
			call_back()
		end
    end
    self:getNetData("rpg_index", nil, callback, 0)
end

--检测是否可解锁
function M:checkCanUnlock(c_id)
	
end

return M
