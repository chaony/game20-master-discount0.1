--悬赏列表
local M = class("JuBaoShanHeroSelectPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.JuBaoShan.JuBaoShanHeroSelectPop.Guide"
    audio:SendEvtUI("UI_Popup_N2")
end

function M:startGuide()
    --格子类型，这里只会传 2:钱庄，4:建筑
    local have_guide = nil
    if self.m_model.m_cell_type == 2 then
        have_guide = UserDataManager.guide_data:setAnyTeamGuide(53) -- 钱庄引导派遣
    elseif self.m_model.m_cell_type == 4 then
        have_guide = UserDataManager.guide_data:setAnyTeamGuide(52) -- 建筑引导派遣
    end
    if have_guide then
        if self.m_guide then
            self.m_guide:start()
        end
    end
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
        if self.m_view.slotLockInfo[data].lock == false then
            local hero_id = self.m_model:getHeroSlotByIndex(data);
            if hero_id ~= nil then
                self:clickHero(hero_id)
            end
        else
            local lv = self.m_model.evo_condition[data][1]
            GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("jubaoShan_str_022",lv), delay_close = 2})
        end
    elseif msg == "info_btn" then
        self:openHelpPop();
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
        self:getNetYiJian(function (server_data)
            if server_data.team == nil and _G.next(server_data.team) == nil then
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("bounty_str_0012"), delay_close = 2})
            else
                self.m_model:auto_viewData(server_data)
                local select_node = self.m_model:getSendSlot()
                if #select_node > 0 then
                    self.m_view:updateSendList();
                    self.m_view:refreshReward();
                else
                    GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("bounty_str_0012"), delay_close = 2})
                end
            end
        end)
    elseif msg == "tab_btn" then
        self.m_view:createLoopScroll(data)
    elseif msg == "send_gray" then
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("bounty_str_0012"), delay_close = 2})
    end
end


function M:openHelpPop()
    if self.m_model.m_cell_type == 2 then
        local params = {
            title = self.m_model.cell_config.name,
            content = Language:getTextByKey("tid#credit_dicel_money"),
        }
        self:openView("Pops.CommonFiveLineHelpPop", params)
    end
end


--点击某个英雄
function M:clickHero(hero_id)
    if self.m_model:isInSlot(hero_id) then
        if self.m_model:isInBuilding(hero_id) == false then
            --下阵
            self.m_model:removeHeroInSendSlot(hero_id)
            self.m_view:updateSendList()
            self.m_view:refreshReward()
        end
    else
        --上阵
        self.m_view:btnSetActive(false,true)
        -- 0 表示成功了
        local successCode = self.m_model:addHeroInSendSlot(hero_id)
        --1 品质不符合 2 种族不符合
        if successCode == 1 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("jubaoShan_str_002"), delay_close = 2})
        elseif successCode == 2 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("jubaoShan_str_001"), delay_close = 2})
        elseif successCode == 3 then
            GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("jubaoShan_str_023"), delay_close = 2})
        else
            --更新所有槽位
            self.m_view:updateSendList()
            self.m_view:refreshReward()
        end
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

--发送给接口
function M:sendHero()
    -- mode == 2 是撤回 mode ~= 2 是派遣
    if self.m_model:isChangeHeroList() == false then
        local function callfunc(data)
            --Logger.logError(data, " 撤回成功了 ")
            self.m_model.mode = 1;
            local cell_index = self.m_model.cell_data.cell_index;
            local cells = data.cells
            if cells == nil then
                cells = data.global_cells;
            end
            local cell_data = cells[tostring(cell_index)];
            self.m_model:updateCellData(cell_data)
            --清空槽位玩家
            self.m_model:clearSoltPlayers();
            --更新发送列表
            self.m_view:updateSendList();
            --
            self.m_view:refreshReward();
            --更新场景格子数据
            SceneManager:getCurSceneModel():updateCellInfoBySendServerData(data);
            static_rootControl:updateMsg("buildData",nil,"JuBaoShan")
        end
        --撤回
        local params = {
            pos = self.m_model.cell_data.cell_index,
        }
        if self.m_model.m_cell_type == 2 then
            --钱庄
            self.m_model:getNetData("richman_bank_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
        else
            --建筑
            self.m_model:getNetData("richman_building_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
        end
    else
        --派遣
        local function callfunc(data)
            --Logger.logError(data, " 派遣成功了 ")
            SceneManager:getCurSceneModel():updateCellInfoBySendServerData(data);
            static_rootControl:updateMsg("buildData",nil,"JuBaoShan")
            self:updateMsg(99999)
        end
        local params = {
            pos = self.m_model.cell_data.cell_index,
            team = self.m_model.solt_players,
        }
        if self.m_model.m_cell_type == 2 then
            --钱庄
            self.m_model:getNetData("richman_bank_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
        else
            --建筑
            self.m_model:getNetData("richman_building_dispatch", params, callfunc,false,nil, GlobalConfig.POST)
        end
    end
end

--一键派遣
function M:getNetYiJian(callfunc)
    if self.m_model.m_cell_type == 2 then
        local function callback(data)
            if data then
                callfunc(data)
            --else
            --    GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0004"), delay_close = 2})
            end
        end
        self.m_model:getNetData("richman_bank_dispatch_view", {pos = self.m_model.cell_data.cell_index}, callback, nil, true)
    else
        local function callback(data)
            if data then
                callfunc(data)
            --else
            --    GameUtil:lookInfoTips(self,  {msg =  Language:getTextByKey("new_str_0004"), delay_close = 2})
            end
        end
        self.m_model:getNetData("richman_building_dispatch_view", { pos = self.m_model.cell_data.cell_index, team = self.m_model.solt_players, }, callback, nil, true)
    end
end

return M;
