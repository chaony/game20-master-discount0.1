local M = class("GuildHighWarMainModel", LikeOO.OODataBase)
local __CHAT_CHANNEL = {LOCAL = 1,WORLD = 2,GUILD = 3,PRIVATE = 4, GUILDHIGHWAR = 5, GUILDHIGHWARLOG = 6,}
function M:onCreate()
	M.super.onCreate(self)
	self:getData("guild_high_war_battlefield") 
end

function M:onEnter()
	self.m_guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
	self.m_round_id = self.m_params.round_id 
	self.m_is_watch = self.m_params.is_watch or 0 --是否是观战 0 1 0 不是 1 是
	self.m_show_staus = true
	self.m_chat_show = true -- false 关闭 true 开启
	self.m_guild_show = true -- 右上角  false 关闭  true 开启
	self.m_cur_channel_id = __CHAT_CHANNEL.GUILDHIGHWAR
	self:updateData()
	--self.m_all_buff_value = 0
	--self:initAllBuffValue()
end

function M:updateData(response)
	if response then
		table.merge(self.m_data, response)
	end
	self.m_ghw_stage = self.m_data.ghw_stage or 3
	--new
	self.big_stage = self.m_data.big_stage
	self.cycle = self.m_data.cycle --第几轮
	self.playoff_type = self.m_data.playoff_type  or self.m_params.playoff_type --季后赛后使用
	self.round_id = self.m_data.round_id --第几回合
	self.all_round_id = self:getBattleTimes()
	--new
	self.m_city_data = self.m_data.citys or {}
	self.m_guild_info = self.m_data.guild_info or {}
	self.m_position = self.m_data.position or 0
	self.m_type_end_time = self.m_data.type_end_time or 0
	self.m_cycle_end_time =  self.m_data.cycle_end_ts or 0
	self.m_declare_times = self.m_data.declare_times or 0
	self.m_pop_log = self.m_data.pop_log or {}
	self.m_my_city_id = self:getOwenerCityId()
	self.guild_high_war_buildline = {}
	self.guild_high_war_data = {}
	self.m_lines_status = {}
	self.m_fight_data = {} -- 自己宣战的帮会数据
	self.m_array_data = {} --被宣战的自已帮会数据
	self.m_line_data = {} -- 可宣战的帮会数据
	self:initLinesCfg()
	self:InitLinesOwerData()
end

function M:initLinesCfg()
	self.guild_high_war_buildline = ConfigManager:getCfgByName("guild_high_war_buildline") or {} --所有连线数据
	self.guild_high_war_data = ConfigManager:getCfgByName("guild_high_war_build")
	for k, cfg in pairs(self.guild_high_war_buildline ) do
		self.m_lines_status[cfg.linename] = {is_green = false, city_lv = cfg.buildlevel,onename = cfg.onename or 101,twoname = cfg.twoname or 101}
	end
end

--刷新获取所有可以宣战建筑
function M:InitLinesOwerData()
	self.m_fight_data = {} -- 自己宣战的帮会数据
	self.m_array_data = {} --被宣战的自已帮会数据
	self.m_line_data = {} -- 可宣战的帮会数据
	local ower_data = {} --临时保存的 跟人城池数据
	local my_citys = self.m_my_city_id
	local num = #my_citys
	local result = {}
	if num == 0 then
		for city_id, v in pairs( self.m_city_data ) do
			if self.guild_high_war_data[tonumber(city_id)].build_level <=1 then
				local data = {}
				data.id = tonumber(city_id)
				data.name = self.guild_high_war_data[data.id].build_name or ""
				data.level = self.guild_high_war_data[data.id].build_level or 1
				data.status = 0 --是否被宣战
				if v.challenger_guild and v.challenger_guild.guild_id == self.m_guild_id then
					data.status = 1  --1 已经被我宣战 0 未宣战
				end
				result[data.id] = data
			end
		end
	else
		for index, city_id in pairs(my_citys) do
			local line_nums = 0
			for line_name, cfg in pairs( self.m_lines_status ) do
				if string.find(line_name, tostring(city_id)) then
					local data = {}
					data.id = tonumber(city_id) == cfg.onename and cfg.twoname or cfg.onename
					data.name = self.guild_high_war_data[data.id].build_name or ""
					data.level = self.guild_high_war_data[data.id].build_level or 1
					data.status = 0 --是否被宣战
					for i, v in pairs(self.m_city_data) do
						if tonumber(i) == data.id and v.challenger_guild and v.challenger_guild.guild_id == self.m_guild_id then
							data.status = 1  --1 已经被我宣战 0 未宣战
							break
						end
					end
					line_nums = line_nums + 1
					result[data.id] = data
					--table.insert(result,data)
				end
				if line_nums >= 5 then
					line_nums = 0
					break
				end
			end
			local data_ = {}
			data_.id = tonumber(city_id)
			data_.name = self.guild_high_war_data[data_.id].build_name or ""
			data_.level = self.guild_high_war_data[data_.id].build_level or 1
			data_.status = 0 --是否被宣战
			table.insert(ower_data,data_)
		end
	end
	--去掉自己的 有可能出现 多个自己城池
	for i,v in pairs(result) do
		local flag = false
		for k,value in pairs(my_citys) do
			if i == tonumber(value) then
				flag = true
				break
			end
		end
		if not flag then 
			table.insert(self.m_line_data,v)
		end
	end
	table.sort(self.m_line_data,function(a, b) 
		return a.level> b.level
	end)
	
	--帮会被宣战的数据
	for i,value in pairs(ower_data) do
		for k, v in pairs(self.m_city_data) do
			if tonumber(k) == value.id and v.challenger_guild  then
				local data = value 
				data.guild_name = v.challenger_guild.guild_id and self:getGuildDataById(v.challenger_guild.guild_id).name or Language:getTextByKey("new_str_0092") --进攻者名字
				table.insert(self.m_array_data,data)
				break
			end
		end -- 3 58 178 215
	end
	table.sort(self.m_array_data,function(a, b)
		return a.level> b.level
	end)

	--帮会宣战的数据
	for i,value in pairs(self.m_line_data) do
		for k, v in pairs(self.m_city_data) do
			if tonumber(k) == value.id and v.challenger_guild.guild_id and v.challenger_guild.guild_id == self.m_guild_id  then
				local data = value
				data.guild_name = v.owner_guild.guild_id and self:getGuildDataById(v.owner_guild.guild_id).name or Language:getTextByKey("guild_high_war_text_0078") --防守方名字
				table.insert(self.m_fight_data,data)
				break
			end
		end
	end
	table.sort(self.m_fight_data,function(a, b)
		return a.level> b.level
	end)
	
end

-- 获取布阵和战斗阶段 已经宣战和自己被宣战的建筑
function M:getGuildArrayAndFightData()
	local array_data = {} -- 宣战数据
	local fight_data = {} -- 建筑数据
	
	
end

function M:updateDeclareTimes(dtimes)
	self.m_declare_times = dtimes
end

function M:updateCityData(response)
	if response then
		table.merge(self.m_city_data, response)
	end
end

function M:setChatChannelId(channel_id)
	self.m_cur_channel_id = channel_id
end

-- 检查发的消息是否是动图
function M:checkMsgIsEmojiGif(msg)
	local emoji = ConfigManager:getCfgByName("emoji")
	local emoji_gif_data = emoji[2] or {}
	for i, v in pairs(emoji_gif_data) do
		local str = "["..v.emoji .."]"
		if str == msg then
			return v
		end
	end
	return nil
end

function M:sortNewChatMsg(private_msg, other_msg)
	local sort_tab = {} -- 
	if other_msg and next(other_msg) then
		for i = #other_msg - 4, #other_msg do
			if other_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = other_msg[i].time, msg_index = i, is_private = false}
			end
		end
	end
	if private_msg and next(private_msg) then
		for i = #private_msg - 4, #private_msg do
			if private_msg[i] then
				sort_tab[#sort_tab + 1] = {msg_time = private_msg[i].time, msg_index = i, is_private = true}
			end
		end
	end
	table.sort(sort_tab, function(a, b)
		return a.msg_time < b.msg_time
	end)
	return sort_tab
end

function M:getChatMsgByChannel(channel_id)
	local other_msg, private_msg = {}, {}
	if channel_id == __CHAT_CHANNEL.PRIVATE then
		private_msg = ChatUtil:getLatestPrivateMsg(channel_id)
	else
		other_msg = ChatUtil:getChannelMsg(channel_id)
		private_msg =  ChatUtil:getLatestPrivateMsg()
	end

	local last_msg = {}
	local sort_tab = self:sortNewChatMsg(private_msg, other_msg)
	for i = #sort_tab - 4, #sort_tab do
		if sort_tab[i] and next(sort_tab) then
			local msg = sort_tab[i].is_private and private_msg[sort_tab[i].msg_index] or other_msg[sort_tab[i].msg_index]
			last_msg[#last_msg + 1] = msg
		end
	end
	local need_refresh = false
	local new_msg_id = last_msg[#last_msg] and last_msg[#last_msg].msg_id or "-1"
	if self.m_cur_msg_id ~= new_msg_id and new_msg_id ~= "-1" then
		self.m_cur_msg_id = last_msg[#last_msg].msg_id
		need_refresh = true
	end
	return last_msg, need_refresh
end

function M:setShowStatus()
	self.m_show_staus = not(self.m_show_staus)
end

function M:getCityInfoById(city_id)
	city_id = tostring(city_id)
	if self.m_city_data[city_id] then
		return self.m_city_data[city_id]
	end
	return nil
end

function M:getGuildDataById(guild_id)
	guild_id = tostring(guild_id)
	if self.m_guild_info[guild_id] then
		return self.m_guild_info[guild_id]
	end
	return nil
end

function M:getOwnerNameByCityId(city_id)
	city_id = tostring(city_id)
	local owner_name = ""
	local owner_flag = 0
	local city_data = self:getCityInfoById(city_id)
	if city_data then
		local owner_guild_data = city_data.owner_guild or {}
		local owner_guild_id = owner_guild_data.guild_id or 0
		local guild_data = self:getGuildDataById(owner_guild_id)
		if guild_data then
			owner_name = guild_data.name
			owner_flag = guild_data.flag
		end
	end
	return owner_name,owner_flag
end

function M:getAtkGuildNameByCityId(city_id)
	local atk_name = ""
	local city_data = self:getCityInfoById(city_id)
	if city_data then
		local challenger_guild = city_data.challenger_guild or {}
		local challenger_guild_id = challenger_guild.guild_id or 0
		local guild_data = self:getGuildDataById(challenger_guild_id)
		if guild_data then
			atk_name = guild_data.name
		end
	end
	return atk_name
end

function M:getStageName()
	local stage_name = ""
	if self.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.PREPARE then
		stage_name = "guild_high_war_text_0048"
	elseif self.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.FORMATION then
		stage_name = "guild_high_war_text_0050"
	elseif self.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.BATTLE then
		stage_name = "guild_high_war_text_0051"
	elseif self.m_ghw_stage == GlobalConfig.SERVER_GHW_STAGE.DECLARE then
		stage_name = "guild_high_war_text_0049"
	end
	return stage_name
end

function M:getEndTs()
	local end_ts = self.m_type_end_time - UserDataManager:getServerTime()
	return end_ts
end

function M:getEndCycleTs()
	local end_ts = self.m_cycle_end_time - UserDataManager:getServerTime()
	return end_ts
end

function M:getOwenerCityId()
	local my_city = {}
	local max_level = 1
	for i, v in pairs(self.m_city_data) do
		if v.owner_guild and v.owner_guild.guild_id and v.owner_guild.guild_id == self.m_guild_id then
			my_city[#my_city + 1] = i
			local city_lv = math.floor(i % 100) 
			math.max(max_level, city_lv)
		end
	end
	return my_city, max_level
end

--主页
function M:updateMainData(data)
	--table.merge(self.m_data, data)
	--self:initAllBuffValue()
end

function M:getBattleTimes()
	local cfg  = ConfigManager:getCfgByName("guild_high_war_base")
	local time = 10
	if cfg then
		for k,v in pairs(cfg) do
			if v.cycle == self.cycle and v.type == self.big_stage then
				time = v.battle_time
			end
		end
	end
	return time
end




return M
