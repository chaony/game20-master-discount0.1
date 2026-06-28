--悬赏列表
local M = class("RewardHeroDispatchControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Reward.RewardSend.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
    elseif msg == "tab_btn" then
        local params = self.m_model:switchHeroList(data)
        self.m_view:refreshUI(params)
    elseif msg == "send_btn" then --确定
        local data = self.m_model.m_quest_list
        if table.nums(data) > 0 then
            self:sendToNet()
        else
            self:updateMsg(99999) 
        end
    elseif msg == "ok_btn" then
        self.m_view:ok_Handler(data)
        self.m_model:selectTaskItem(data.cell_data)
    end
end

function M:sendToNet()
    local function callfunc(data)
        self:updateMsg("resreshAll", data,"Reward")
        self:updateMsg(99999)
    end
    local quests = self.m_model:getToNetData()
    self.m_model:getNetData("auto_do_quest", {quests = quests}, callfunc,false,nil, GlobalConfig.POST)
end


--点击某个英雄
function M:clickHero(hero_id)
    if self.m_model:isInSlot(hero_id) then
        --下阵    
        self.m_model:removeHeroInSendSlot(hero_id)
        self.m_view:updateSendList(hero_id)
    else
        --上阵
        --if self.m_model:isHaveNull() then --空位
            self.m_view:btnSetActive(false,true)
            local success = self.m_model:addHeroInSendSlot(hero_id)
            if success == false then
                GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("worldMap_reward_send"), delay_close = 2})
            end
            -- self.m_view:updateCurHeroSpine(hero_id)
            self.m_view:updateSendList(hero_id)  
        --end
    end 
end

--点击某个槽位
function M:clickSlot(data)
    self.m_model.select_send_index = data
    self.m_view:isMercenary(data)
    if self.m_model:isHaveHero(data) then
        self.m_model:removeByIndex(data)
        self.m_view:setSEND_LIST(data)
        --self.m_view:updateSendList(true)
    else
        self.m_view:openHeroList()
    end
end

function M:sendHero()
    if self.m_model:checkNumCondition() and self.m_view:checkRaceCondition() then
        local quest_id = self.m_model.m_task_id
        local quest_type = self.m_model.m_task.type
        local function callfunc(data)
            self:updateMsg("resresh", {quest_id =  self.m_model.m_task_id,cell_data = data },"Reward")
            self:updateMsg(99999)
        end
        if quest_type == 1 then
            local self_hero = {}
            self_hero = self.m_model:getSendSlot()
            self.m_model:getNetData("bounty_do_quest", {quest_id = quest_id, quest_type = quest_type, self_hero = self_hero}, callfunc,false,nil, GlobalConfig.POST)
        elseif quest_type == 3 then 
            local _heros = self.m_model:getSendSlot() 
            local self_hero = {} 
            local master_hero = {}
            table.insert(self_hero, _heros[1])
            table.insert(master_hero, _heros[2])
            local params = {
                quest_id = quest_id,
                quest_type = quest_type,
                self_hero = self_hero,
                team_hero = master_hero,
            }
            self.m_model:getNetData("bounty_do_quest", params, callfunc,false,nil, GlobalConfig.POST)
        end 
    else
    end
end

return M;
