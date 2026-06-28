local M = class("MaterialAcquisitionModel", LikeOO.OODataBase)

function M:onCreate()
    M.super.onCreate(self)
    self.m_transfer = "scale"
    --"hero_chest_receive_quest"
    self:getData()
end

function M:onEnter()
    self.m_quests = self.m_params.m_quests
    self.m_quest_buy_times = self.m_params.m_quest_buy_times
    self.m_quest_vsn = self.m_params.m_quest_vsn
end

--更新奖励领取数据
function M:updateServerData(serverData)
	if serverData and serverData["end"] then

		UserDataManager.active_121_end = true
		static_rootControl:updateMsg("end_summer", nil, "Summer.SummerMain")
		
	end

    table.merge(self.m_quests, serverData.quests)
end

--更新限购数据
function M:updateBuyServerData(serverData)
    self.m_quest_buy_times = serverData.quest_buy_times
end

--获取数据
function M:getCfgData()
    local show_data = {}
    local chest_quset = ConfigManager:getCfgByName("chest_quest")
    local chest_shop = ConfigManager:getCfgByName("chest_shop")
    -- local quest_id = self.quest_id or 1
    for k, v in pairs(chest_shop) do
        if k == self.m_quest_vsn then
            local shop_num = chest_shop[k]["times"]
            local quest_shop = {}
            quest_shop.cfg = v
            quest_shop["times"] = shop_num - self.m_quest_buy_times
            quest_shop["value"] = self.m_quest_buy_times
            quest_shop["target_value"] = shop_num
            quest_shop["sort"] = 1
            if quest_shop["times"] > 0 then --有购买次数
                quest_shop["status"] = 1
            else
                quest_shop["status"] = -1
             --已全部领取
            end
            table.insert(show_data, quest_shop)
        end
    end
    for k, v in pairs(chest_quset[self.m_quest_vsn]) do
        local quest = {}
        quest.cfg = v
        local string_k = tostring(k)
        quest["value"] = self.m_quests[string_k]["value"]
        quest["times"] = v.times - self.m_quests[string_k]["times"]
        quest["status"] = self.m_quests[string_k]["status"]
        quest["quest_id"] = string_k
        quest["sort"] = 2
        if self.m_quests[string_k]["status"] == 2 then
            quest["status"] = -1 --已全部领取
        end
        table.insert(show_data, quest)
    end
    --Logger.logError(show_data)
    --数据重新排列
    table.sort(
        show_data,
        function(data1, data2)
            if data1.status == data2.status then
                return data1.status > data2.status
            else
                return data1.status > data2.status
            end
        end
    )
    return show_data
end

return M
