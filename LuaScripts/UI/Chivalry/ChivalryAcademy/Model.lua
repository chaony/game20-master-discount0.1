local M = class("ChivalryAcademyModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.open_id = self.m_params.open_id or 398
	self.m_version = self.m_params.version or 1
	self.refresh_main = self.m_params.refresh_main or "Chivalry.ChivalryMain"
	self:getData("fillword_index",{open_id = self.open_id,vsn = self.m_version})
	--self:getData()
end

function M:onEnter() 
	--Logger.logError(self.m_data,"翰林书院~~~~~~~~~~~~~~~~")
	self.open_customs_num = self:setCurrentDay() --关卡开启数量
	self.customs = self.open_customs_num --关卡id
	self.fontLibrarys = {}  --字库
	self.writeFonts = {} --要填的字
end

function M:getRanks()
	return self.m_data.ranks or {}
end

--刷新服务器数据
function M:updateServer(response)
	table.merge(self.m_data.vsn_data,response)
end

--获取活动数据
function M:getActiveData()
	local active_tab = ConfigManager:getCfgByName("active")
	for i, v in pairs(active_tab) do
		if v.open_id == self.open_id and v.version == self.m_version then
			return v
		end
	end
	return nil
end

--获取活动类型
function M:getActiveType()
	local fillword = ConfigManager:getCfgByName("fillword")
	return fillword[self.open_id][self.m_version][self.customs]
end

--获取填字内容
function M:getContent()
	local active_type = self:getActiveType()
	local table_name = "fill_word~"..active_type.type 
	local table_data = ConfigManager:getCfgByName(table_name)
	local show_data = {}
	local writeFont = {}
	for i, v in pairs(table_data) do
		local pos_x = math.modf(i/100)
		local pos_y = i%100
		local pos_id = (pos_y - 1) * 10 + pos_x 
		table.insert(show_data,{id = i,cfg = v,pos = pos_id,is_write = 0})
		if v.status == 2 then
			local isCorrect = self:isCorrect(i)
			table.insert(writeFont,{value = v.value,pos = i,is_corrent = isCorrect})
		end
	end
	if self.writeFonts[active_type.type] == nil then
		self.writeFonts[active_type.type] = writeFont
	end
	table.sort(show_data,function(value_a,value_b)
		return value_a.pos < value_b.pos
	end)
	self.show_data = show_data
end

--计算时间
function M:setCurrentDay()
	local cur_tim = UserDataManager:getServerTime() --当前时间
	local active_data = self:getActiveData()
	local start_ts = GameUtil:stringToTimesTamp(active_data.start_time)
	local surplus_time = cur_tim - start_ts --从活动开始到当前时间的差值
	local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算活动开启时间
	remain_day = remain_day + 1
	if remain_day < 1 then
		remain_day = 1
	elseif remain_day > 10 then
		remain_day = 10
	end
	return remain_day
end


--设置随机字库
function M:setFontLibrary()
	local active_type = self:getActiveType()
	local random_words = active_type.random_words
	local des_1 = string.split(random_words,",")
	for i, v in ipairs(self.writeFonts[active_type.type]) do
		local current_isfillin = self:isFillIn(v.value,v.pos)
		table.insert(des_1,{value = v.value,status = current_isfillin}) --0：可选择 1，不可选择
	end
	for i, v in ipairs(des_1) do
		if v == "#VALUE!" or v == "" then
			table.remove(des_1,i)
		end
	end
	local new_table = self:randomWrite(des_1)
	self.fontLibrarys[active_type.type] = new_table
	return self.fontLibrarys[active_type.type]
end

--随机文字
function M:randomWrite(des_1)
	local new_table = {}
	local num = #des_1
	for i = 1, num do
		local value_id =  math.random(#des_1)
		if des_1[value_id].status == nil then
			local table_data = {value = des_1[value_id],status = 0}
			des_1[value_id] = table_data
		end
		table.insert(new_table,des_1[value_id])
		table.remove(des_1,value_id)
	end
	return new_table
end

--获取随机字库
function M:getFontLibrary()
	local active_type = self:getActiveType()
	if self.fontLibrarys[active_type.type] then
		self.font_table = self.fontLibrarys[active_type.type]
	else
		local font_table = self:setFontLibrary()
		self.font_table = font_table
	end
end

--判断是否填入
function M:isFillIn(font,pos)
	local active_type = self:getActiveType()
	if self.writeFonts[active_type.type] then
		for i, v in ipairs(self.writeFonts[active_type.type]) do
			if v.value == font and v.pos == pos and v.is_corrent then
				return 1
			end
		end
	end
	return 0
end

--判断填的字是否正确
function M:isCorrect(id)
	local active_type = self:getActiveType()
	if self.m_data.vsn_data and self.m_data.vsn_data.has_word and self.m_data.vsn_data.has_word[tostring(active_type.type)] then
		if self.m_data.vsn_data.has_word[tostring(active_type.type)] then
			for i, v in ipairs(self.m_data.vsn_data.has_word[tostring(active_type.type)]) do
				if v == id then
					return true
				end
			end
		end
	end
	return false
end

--获取是否已领过奖励
function M:getIsHasReward(customs)
	local customs_num = self.customs
	if customs then
		customs_num = customs
	end
	if self.m_data.vsn_data and self.m_data.vsn_data.receive_id then
		for i, v in ipairs(self.m_data.vsn_data.receive_id) do
			if v == customs_num then
				return true
			end
		end
	end
	return false
end

--是否可领取奖励
function M:getIsReceive()
	local active_type = self:getActiveType()
	if self.writeFonts[active_type.type] then
		for i, v in ipairs(self.writeFonts[active_type.type]) do
			if not v.is_corrent then --有没填的就不可领奖
				return false
			end
		end
	end
	return true
end

--保存填字状态
function M:preservationWriteStage(pos,type)
	if self.writeFonts[type] then
		for i, v in ipairs(self.writeFonts[type]) do
			if v.pos == pos then
				self.writeFonts[type][i].is_corrent = true
			end
		end
	end
end

return M