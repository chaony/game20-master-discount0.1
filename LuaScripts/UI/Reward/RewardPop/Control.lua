--悬赏列表
local M = class("RewardPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.Reward.RewardSend.Guide"
end

function M:onHandle(msg, data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
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
    elseif msg == "one_keydispatch" then --一键上阵
        self.m_view:openHeroList()
        self.m_model:quckSend()
        self.m_view:updateSendList()
        
        --self.m_view:showQuickHeroSpine()
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

    
    -- if self.m_view:checkRaceCondition() and self.m_model:checkNumCondition() then
    --     self:btnSetActive(true,false)
    -- else
    --     self:btnSetActive(false,true)
       
    -- end

    if self.m_model:isInSlot(hero_id) then
        --下阵    

        self.m_model:removeHeroInSendSlot(hero_id)
        
        self.m_view:updateSendList(true)
    else
        --上阵
        if self.m_model:isHaveNull() then --空位
            self.m_view:btnSetActive(false,true)
            self.m_model:addHeroInSendSlot(hero_id)    
            -- self.m_view:updateCurHeroSpine(hero_id)
            self.m_view:updateSendList()  
        end
    end 



end

--点击某个槽位
function M:clickSlot(data)
    self.m_model.select_send_index = data
    if self.m_model:isHaveHero(data) then
        self.m_model:removeByIndex(data)
        self.m_view:updateSendList(true)
    else
        self.m_view:openHeroList()
    end
end

function M:sendHero()
    if self.m_model:checkNumCondition() and self.m_view:checkRaceCondition() then
        local quest_id = self.m_model.m_task_id
        local quest_type = self.m_model.m_task.type
        local function callfunc(data)
            self:updateMsg("resresh", {quest_id =  self.m_model.m_task_id,cell_data = data },"WorldMap.WorldMapRewardNew")
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
                master_hero = master_hero,
            }
            self.m_model:getNetData("bounty_do_quest", params, callfunc,false,nil, GlobalConfig.POST)
        end 
    else

    end
end

return M;
