local M = class("TreasureBoxModel",LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self.m_draw_vsn = self.m_params.draw_vsn
	self.m_draw_box = self.m_params.draw_box
	self.m_draw_times = self.m_params.draw_times or 0
	self.active_time = self.m_params.active_time
	self.m_tab_info = self.m_params.tab_info
	self:initChestReward()
end

--初始化左边列表奖励
function M:initChestReward()
	self:getChestReward()
end

--更新服务器数据
function M:updateServerData( serverData )
	self.m_draw_box = serverData.draw_box
	--self.m_draw_vsn = serverData.draw_vsn
	self.m_draw_times = serverData.draw_times or 0
end

--获取chest配置,返回：可进行倒计时的宝箱数量
function M:getChest()
	local chest = ConfigManager:getCfgByName("chest")
	local verson = self.m_draw_vsn
	--Logger.logError(chest,"self.m_draw_vsn "..self.m_draw_vsn )
	local list = table.copy(chest[verson])
	return list
end

--设置右边宝箱配置
function M:getDrawListData()
	local draw_box = {}
	--Logger.logError(self:getChest(),"getchest")
	local draw = self:getChest()
	--Logger.logError(draw["num"],"num")
	local draw_num = draw["num"]
	for i = 1, 5 do
		local box = {}
		if self:hasDrawBox(i) then
			box.ts = self.m_draw_box[i].ts
			box.gift = self.m_draw_box[i].gift
		end
		table.insert(draw_box,box)
	end
	return draw_box
end

--获取左边奖品配置
function M:getChestReward()
	local chest_reward = ConfigManager:getCfgByName("chest_reward")
	self.rewards = table.copy(chest_reward[self.m_draw_vsn][1])
	for k,v in pairs(chest_reward[self.m_draw_vsn][0]) do
		table.insert(self.rewards,v)
	end
end

--返回左边奖品配置
function M:rightReward()
	return self.rewards
end

--是否有奖励
function M:hasDrawBox(id)
	if self.active_time.end_ts <= UserDataManager:getServerTime() then
		return false
	end
	return self.m_draw_box[id] ~=nil
end

function M:getDrawTimes()
	
end

function M:getActiveByOpenId()
    local active_tab = ConfigManager:getCfgByName("active")
    for i, v in pairs(active_tab) do
        if v.open_id == 125 and v.version == self.m_draw_vsn then
            return v
        end
    end
    return nil
end

return M
