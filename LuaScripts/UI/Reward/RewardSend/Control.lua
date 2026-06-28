--悬赏列表
local M = class("RewardSendControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Reward.RewardSend.Guide"
    audio:SendEvtUI("UI_Popup_N2")
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
    elseif msg == "tab_btn" then
        self.m_model.selectType_index = data
        local params = self.m_model:switchHeroList(data.value.race)
        self.m_view:refreshUI(params)
    elseif msg == "check_send_btn" then
        self:clickSlot(data)
    elseif msg == "select_hero" then
        self:clickHero(data)
    elseif msg == "select_team_hero" then
        self:clickHero(data)
    elseif msg == "send_btn" then    
        self:sendHero()
    elseif msg == "dispatch" then --完成派遣
        self:sendHero()
    elseif  msg == "update_selfHero" then
        self.m_model.self_hero = data.data_hero
    elseif msg == "one_keydispatch" then --一键上阵
        self:getNetYiJian(function (view_data)
            self.m_model:auto_viewData(view_data)
            local select_node = self.m_model:getSendSlot()
            if table.nums(select_node) > 0 then
                for k,v in pairs(self.m_model:getSendSlot()) do
                    self.m_view:updateSendList(v)
                 end
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("bounty_str_0012"), delay_close = 2})
            end
        end)
    elseif msg == "tab_btn" then
        self.m_view:createLoopScroll(data)
    elseif msg == "send_gray" then
        if self.m_model:checkNumCondition() then
           
        end
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("bounty_str_0012"), delay_close = 2})
    end
end

--点击某个英雄
function M:clickHero(hero_id)
    if self.m_model:isInSlot(hero_id) then
        --下阵    

        self.m_model:removeHeroInSendSlot(hero_id)
        
        self.m_view:updateSendList(hero_id)
    else
        --上阵
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
            self:updateMsg("resresh", {quest_id =  self.m_model.m_task_id, cell_data = data, index = self.m_model.index , isSort = false },"Reward")
            self:updateMsg("check_guide", nil,"Reward")
            -- local start_pos = Vector3(data.start_pos[0], 0, data.start_pos[1])
            -- SceneManager.curScene:sendQuestTask(self.m_model.m_task_id, data.start_ts, start_pos);
            self:updateMsg(99999)
        end
        if quest_type == 1 then
            local self_hero = {}
            self_hero = self.m_model:getSendSlot()
            self.m_model:getNetData("bounty_do_quest", {quest_id = quest_id, quest_type = quest_type, self_hero = self_hero}, callfunc,false,nil, GlobalConfig.POST)
        elseif quest_type == 2 then 
            local self_hero = {}
            local team_hero = {}
            local _heros = self.m_model:getSendSlot() 
            local last_num = table.nums(self.m_model.m_task.race_condition)
            for k,v in pairs(_heros) do
                if k ~= last_num then
                    table.insert(self_hero, _heros[k])
                end
            end
            local user = self.m_model:getMercenaryUser(_heros[last_num])
            team_hero[tostring(user.uid)] = _heros[last_num]
            local params = {
                quest_id = quest_id,
                quest_type = quest_type,
                self_hero = self_hero,
                team_hero = team_hero,
            }
            self.m_model:getNetData("bounty_do_quest", params, callfunc,false,nil, GlobalConfig.POST)
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

function M:getNetYiJian(callfunc)
    local function callback(data)
        if data then
            callfunc(data.view_data)       
        else
            GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0004"), delay_close = 2})           
        end
    end
    self.m_model:getNetData("auto_view", {quest_id = self.m_model.m_task_id, type = self.m_model.m_type }, callback, 0, true)
end

return M;
