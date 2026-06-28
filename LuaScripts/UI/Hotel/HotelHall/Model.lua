local M = class("HotelHallModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData("hotel_main")
end

function M:onEnter()
	self.m_hotel_level = self.m_params.hotel_level
	self.m_his_run_times = self.m_params.his_run_times
	self.m_times = self.m_params.times
	self.m_spine_res = self.m_params.spine_res
	self:updateQuest(self.m_data.quests)
	self:formatRooms(self.m_data.rooms)
	--默认选中房间
	for k,v in ipairs(self.m_rooms) do
		if v.level >= 1 and self.m_his_run_times >= v.unlock_run_num then
			self.m_select_room = k
			self.m_select_room_heroes = v.heroes
			break
		end
	end
end

--格式化房间数据
function M:formatRooms(rooms)
	self.m_rooms = {}
	local base_cfg = ConfigManager:getCfgByName("hotel_room_base")
	for k,v in ipairs(base_cfg) do
		self.m_rooms[k] = {}
		self.m_rooms[k].name = Language:getTextByKey(v.name)
		self.m_rooms[k].unlock_run_num = v.unlock_run_num
		self.m_rooms[k].heroes = {"", "", ""}
		local data = rooms[tostring(k)]
		if data == nil then
			self.m_rooms[k].level = 1
			self.m_rooms[k].grade = 0
		else
			self.m_rooms[k].level = data.level
			table.merge(self.m_rooms[k].heroes, data.heros)
			local grade, grade_text = self:getRoomGrade(k, self.m_rooms[k])
			self.m_rooms[k].grade = grade --评级
		end
	end
end

--当前选择房间
function M:getSelectRoom()
	return self.m_rooms[self.m_select_room]
end

function M:setSelectRoom(room_id)
	self.m_select_room = room_id
	local room = self:getSelectRoom()
	self.m_select_room_heroes = room.heroes
end

--更新任务
function M:updateQuest(quests)
	if quests == nil then
		self.m_quest = nil
		return
	end
	self.m_quest = self:getQuest(quests)
end

--构建任务
function M:getQuest(quests)
	local quest_cfg = ConfigManager:getCfgByName("hotel_quest")
	local quest = {}
	for k,v in pairs(quests) do
		local key = tonumber(k)
		quest.id = key
		quest.status = v.status
		quest.value = v.value
		quest.cfg = quest_cfg[quest.id]
	end
	return quest
end

--房间升级
function M:updateRoomUpgrade(room_id, room_level)
	if self.m_rooms[room_id] == nil then
		return
	end
	self.m_rooms[room_id].level = room_level
	--升级后，评级会变化
	local grade, grade_text = self:getRoomGrade(room_id, self.m_rooms[room_id])
	self.m_rooms[room_id].grade = grade
	--酒楼等级
	self.m_hotel_level = 9999
	for k,v in ipairs(self.m_rooms) do
		if self.m_hotel_level > v.level then
			self.m_hotel_level = v.level
		end
	end
end

--是否可以升级房间
function M:isCanRoomUpgrade(room_id)
	local room = self.m_rooms[room_id]
	if room.unlock_run_num > self.m_his_run_times then
		return nil, nil
	end
	local level_cfg = ConfigManager:getCfgByName("hotel_room_level")
	local room_cfg = level_cfg[room_id]
	local cur_cfg = room_cfg[room.level]
	local next_cfg = room_cfg[room.level + 1]
	if next_cfg == nil then
		return cur_cfg, nil
	end
	return cur_cfg, next_cfg
end

--房间侠客更替
function M:updateRoomHero(room_id, room_heroes)
	if self.m_rooms[room_id] == nil then
		return
	end
	self.m_rooms[room_id].heroes = room_heroes
	--更替后，评级会变化
	local grade, grade_text = self:getRoomGrade(room_id, self.m_rooms[room_id])
	self.m_rooms[room_id].grade = grade
end

--更新经营
function M:updateRun(response)
	self.m_his_run_times = response.his_run_num
	self.m_times = response.lave_daily_run_num
	if response.quests ~= nil then
		self:updateQuest(response.quests)
	end
end

--评级，满足属性条数，评级文本
function M:getRoomGrade(room_id, room)
	if room.heroes == nil or #room.heroes <= 0 then
		return 0, "C"
	end
	local total_attrs = self:getRoomAttrs(room)
	local reach_num = self:getRoomGradeAttrReachNum(room_id, room.level, total_attrs)
	if reach_num == 3 then
		return reach_num, "S"
	elseif reach_num == 2 then
		return reach_num, "A"
	elseif reach_num == 1 then
		return reach_num, "B"
	elseif reach_num == 0 then
		return reach_num, "C"
	end
end

--计算房间属性，房间侠客各属性之和
function M:getRoomAttrs(room)
	local total_attrs = {0, 0, 0}
	if room.heroes == nil or #room.heroes <= 0 then
		return total_attrs
	end
	local hero_attrs_cfg = ConfigManager:getCfgByName("hotel_hero_attr")
	local length = #room.heroes
	for i = 1, length do
		local oid = room.heroes[i]
		if not(oid == nil or oid == "") then
			local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
			if hero_attrs_cfg[hero_data.id] ~= nil then
				local attrs = hero_attrs_cfg[hero_data.id][hero_data.evo].attrs
				for i = 1, #total_attrs do
					total_attrs[i] = total_attrs[i] + attrs[i]
				end
			end
		end
	end
	return total_attrs
end

--房间属性达标数
function M:getRoomGradeAttrReachNum(room_id, room_level, total_attrs)
	local room_level_cfg = ConfigManager:getCfgByName("hotel_room_level")
	local cfg = room_level_cfg[room_id][room_level]
	local attr_aims = cfg.attr_aims
	local num = 0
	for i = 1, #total_attrs do
		if total_attrs[i] >= attr_aims[i] then
			num = num + 1
		end
	end
	return num
end

--房间属性名
function M:getRoomAttrName(attr_id)
	if attr_id == 1 then
		return Language:getTextByKey("hotel_text_015")
	elseif attr_id == 2 then
		return Language:getTextByKey("hotel_text_016")
	elseif attr_id == 3 then
		return Language:getTextByKey("hotel_text_017")
	end
end

local __math_modf = math.modf
--经营收益
function M:getRunGain()
	local level_cfg = ConfigManager:getCfgByName("hotel_room_level")
	local gain = 0
	for k,v in ipairs(self.m_rooms) do
		if v.unlock_run_num <= self.m_his_run_times then
			local cfg = level_cfg[k][v.level]
			local rate = self:getRoomGradeRate(v.grade)
			gain = gain + (cfg.run_gain * rate / 100)
		end
	end
	return __math_modf(gain)
end

--评级收益比率
function M:getRoomGradeRate(grade)
	local grade_cfg = ConfigManager:getCfgByName("hotel_room_grade")
	for i = 1, #grade_cfg do
		local cfg = grade_cfg[i]
		if cfg.meet_num == grade then
			return cfg.gain_rate
		end
	end
	return 0
end

--获得侠客对应的酒楼属性
function M:getHeroAttrs(oid)
	local hero, hero_cfg = UserDataManager.hero_data:getHeroDataById(oid)
	if hero == nil then
		return nil
	end
	local attrs_cfg = ConfigManager:getCfgByName("hotel_hero_attr")
	local hero_attrs_cfg = attrs_cfg[hero.id]
	if hero_attrs_cfg == nil then
		return nil
	end
	if hero_attrs_cfg[hero.evo] == nil then
		return nil
	end
	local attrs = hero_attrs_cfg[hero.evo].attrs
	return attrs
end

--
function M:getHeroes()
	local ids = table.copy(UserDataManager.hero_data:getHerosId())
	local function sortFunc(id1, id2)
		local data1, cfg1 = UserDataManager.hero_data:getHeroDataById(id1)
		local data2, cfg2 = UserDataManager.hero_data:getHeroDataById(id2)
		return data2.evo < data1.evo
	end
	table.sort(ids, sortFunc)
	return ids
end

--判断侠客是否在某个房间
function M:heroInRoom(oid)
	for k,v in ipairs(self.m_rooms) do
		if v.heroes ~= nil then
			for i = 1, #v.heroes do
				if oid == v.heroes[i] then
					return v, k
				end
			end
		end
	end
	return nil
end

--相同侠客不可重复上阵同一房间
function M:isUniqueHeroInRoom(room_id, oid)
	local room = self.m_rooms[room_id]
	local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	for i = 1, #room.heroes do
		if room.heroes[i] ~= "" then
			local d, c = UserDataManager.hero_data:getHeroDataById(room.heroes[i])
			if data.id == d.id then
				return false
			end
		end
	end
	return true
end

--获得解锁房间
function M:getUnLockRoom()
	for k,v in ipairs(self.m_rooms) do
		--所有房间的解锁等级，按说是不一样的
		--只要等于解锁等级，等同于此房间被解锁了
		if v.unlock_run_num == self.m_his_run_times then
			return v, k
		end
	end
	return nil
end

return M