local M = class("DragonswordBattleView",LikeOO.OOPopBase)

M.m_size_type = 1
M.m_iphoneXAdapter = true
M.m_uiName = "Dragonsword/DragonswordBattle"


function M:onEnter()
    self:setTime()
    self:updateMsg("refresh_rank_info")
    if self.m_model.m_active_data ~= nil and self.m_model.m_active_data.name ~= nil then
        self:setTextByLanKey("close_title_text",self.m_model.m_open_data.name)
    end
    self:setTextByLanKey("battle_btn_text","new_str_0386") --挑战
    self:setTextByLanKey("reward_btn_text","new_str_0373") --奖励
    self:setTextByLanKey("ranking_btn_text","new_str_0235") --排行
    self:setTextByLanKey("my_record_text","dragonsword_text_0007") --我的战绩
    self:setTextByLanKey("ranking_reward_text","dragonsword_text_0008") --排名奖励
    self:setTextByLanKey("ranking_reward_text","dragonsword_text_0008") --排名奖励
    self:setTextByLanKey("reward_grant_text","dragonsword_text_0009") --奖励在挑战结束后通过邮件发放
    self:setTextByLanKey("surplus_time_text","new_str_0485") --剩余时间
    self:setTextByLanKey("buff_add_text","dragonsword_text_0013") --伤害加成
end

--刷新
function M:refreshUI()
	self:refreshShowData()
    self:setTime()
end

--刷新显示数据
function M:refreshShowData()
    self:setTextByLanKey("max_hurt_text",Language:getTextByKey("gf_str_0075",self.m_model.m_max_damage or 0)) --最高伤害
    self:setTextByLanKey("today_max_hurt_text",Language:getTextByKey("dragonsword_text_0010",self.m_model.m_max_damage or 0)) --最高伤害
    self:setTextByLanKey("my_ranking_text",Language:getTextByKey("dragonsword_text_0011",self.m_model.m_data.rank)) --我的排名
    local ranking_info = self.m_model:getRankingReward(self.m_model.m_data.rank)
    --奖励
    local reward = ranking_info.cfg.daily_rewards or {}
    local reward_node = self:findGameObject("reward_Content")
    local function callBack()
        audio:SendEvtUI("UI_TJL_Gold")
    end
    GameUtil:createRewards(reward_node.transform, reward, true, true, callBack, 1)
    --种族加成
    local buff_img = self:findGameObject("buff_img")
    UIUtil.destroyAllChild(buff_img.transform)
    local race_info = self.m_model:getRace()
    local race_data = race_info.race
    for i, v in ipairs(race_data) do
        local buff_item = self:createObj("Dragonsword/power_item",buff_img)
        local luaBehaviour = UIUtil.findLuaBehaviour(buff_item)
        local transform = buff_img.transform
        local race_data = GlobalConfig.TYPE_HERO_RACE[v]
        if race_data ~= nil then
            LuaBehaviourUtil.setImg(luaBehaviour,"power_img", race_data.big_race_icon, ResourceUtil:getLanAtlas())
        end
        local btn = luaBehaviour:FindButton("power_img")
        btn.onClick:AddListener(function() self:updateMsg("race_info",{percent = race_info.percent,race_data = race_data,btn = btn}) end)
    end
   
end

--设置时间
function M:setTime()
    local today_time = os.date("%Y-%m-%d",UserDataManager:getServerTime())
    local string_day = string.format("%s %d:%d:%d",today_time,23,59,59)
    self.day_time = GameUtil:stringToTimesTamp(string_day)
end

--更新时间
function M:updateTime()
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    local surplus_time = 0
    if self.day_time ~= nil then
        surplus_time = self.day_time - cur_tim
    end
    if surplus_time <= 0 then
        self:updateMsg("refresh_rank_info")
    else
        local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
        self:setTextByLanKey("time_text", string.format("%02d:%02d:%02d",remain_hour,remain_min,remain_sec)) --重置剩余时间
    end
end



--创建object
function M:createObj(name,parent)
    local obj = ResourceUtil:LoadUIGameObject(name,Vector3.zero,parent)
    return obj
end

function M:destroy()
    M.super.destroy(self)
end

return M