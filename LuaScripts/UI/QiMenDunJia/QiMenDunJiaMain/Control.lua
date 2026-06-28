local M = class("QiMenDunJiaMainControl",LikeOO.OOControlBase)

function M:onEnter()
    --self:updateRankData()
    
    SceneManager:changeScene(SceneManager.SceneID.QiMenDunJiaScene, self.m_model:getMainData(), false);
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
        audio:SendEvtBGM("Set_State_TianXia")
    elseif msg == "main_refresh_ui" then
        self.m_view:refreshUI()
    elseif msg == "main_refresh_strength" then
        self.m_view:refreshStrength()
    elseif msg == "main_refresh_explore" then
        self.m_view:refreshExploreProgress()
    elseif msg == "main_refresh_all_buff" then
        self.m_model:initAllBuffValue()
        self.m_view:refreshAllBuffValue()
    elseif msg == "main_refresh_red_point" then
        self.m_view:refreshRedPoint()
    elseif msg == "refreshData" then
        local msg = Language:getTextByKey("jubaoShan_str_005",self.m_model:getVip(), self.m_model:getRemainBuyTimes());
        local cost = self.m_model:getCost(data.num)
        self:updateMsg("updateMsgInfo",{ msg = msg, cost = cost },"QiMenDunJia.QiMenDunJiaBuyStrength");
    elseif msg == "chakan_btn" or msg == "rank_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaRank", {version = self.m_model:getVersion()})
    elseif msg == "battle_record_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaBattleRecord", {version = self.m_model:getVersion()})
    elseif msg == "task_btn" then
        self:openView("QiMenDunJia.QiMenDunJiaTask", {main_data = self.m_model:getMainData()})
    elseif msg == "add_strength_btn" then
        self:showBuyStrengthWindow()
    elseif msg == "explain_btn" then
        self:openView("Pops.CommonHelpPop", { title = "tid#QMDJ_dec_01", content = "tid#QMDJ_dec_02" })
    --场景事件响应
    elseif msg == "qmdj_goto" then -- 移动位置
        self:qmdjGoto(data)
    elseif msg == "show_no_move_messag" then -- 提示语
        if data.hintText then
            GameUtil:lookInfoTips(self, {msg = data.hintText, delay_close = 2})
        end
    elseif msg == "show_monster_messag" then -- 战斗详情
        local lock_hids = self.m_model:getLockHids()
        local lock_one = self.m_model:getLockOne()
        if lock_one <= 0 then
            if self.m_model:getStrength() > 0 then
                self.m_model:updateCustomMassifID(data.gridId)
                self:openView("QiMenDunJia.QiMenDunJiaBattleDetail", {main_data = self.m_model:getMainData(), cell_id = data.gridId, lock_hids = lock_hids, lock_one = lock_one})
            elseif self.m_model:getRemainBuyTimes() > 0 then
                self:showBuyStrengthWindow()
            else
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qi_men_dun_jia_str_031"), delay_close = 2})
            end
        else 
            self:openView("QiMenDunJia.QiMenDunJiaLockHero", {main_data = self.m_model:getMainData()})
        end
    elseif msg == "show_lock_hero_messag" then -- 战斗结束，需要弹锁英雄的界面时
        local lock_one = self.m_model:getLockOne()
        if lock_one > 0 then
            self:openView("QiMenDunJia.QiMenDunJiaLockHero", {main_data = self.m_model:getMainData()})
        end
    elseif msg == "show_ForceStatue_messag" then   --  力量雕像
        self:openView("QiMenDunJia.QiMenDunJiaBattleStatue", {main_data = self.m_model:getMainData(), cell_id = data.gridId})
    elseif msg == "show_SwordDesk_messag" then   --  铸剑台
        self:requestForOpenSwordForge(data.gridId)
    elseif msg == "show_Shop_messag" then   --  商店，激活商店，获得奇门遁甲的商品
        local function netCallback(response)
            if response then
                self:openView("Shop", {shop_type = 2})
            end
        end
        local params = {ver = self.m_model:getVersion(), cell_id = data.gridId}
        self.m_model:getNetData("gve_detail", params, netCallback)
    elseif msg == "show_League_messag" then   --  帮会
        self:requestUnion()
    elseif msg == "notExist_monster_messag" then
        -- 怪物已被击杀提示
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("qmdj_text_0001"), delay_close = 2})
    elseif msg == "qmdj_load_finish" then
        -- 奇门遁甲场景加载完成（倒计时，定时刷新）
        self:sendQmdjTimerRefresh()
    elseif msg == "change_scene" then
        if data and data.result == 1 then
            local battle_ret_data = data.battle_ret_data
            if battle_ret_data then
                self.m_model:netData(battle_ret_data)
            end
            --self.m_model:updateLockOne(data.result)
            self.m_view:refreshUI()
            self:updateMsg("show_lock_hero_messag") --战斗胜利时，需要选择打扫战场的英雄
        end
        SceneManager:changeScene(SceneManager.SceneID.QiMenDunJiaScene, self.m_model:getMainData(), false);
        if data then
            local status_code = data.status
            if status_code and tostring(status_code) == "58009" then
                self:setOnceTimer(1,function()
                    self:qmdjGridRefreshReq()
                end)
            end
        end
    elseif msg == "btn_playerPos" then
        if (SceneManager.curScene ~= nil) then
            SceneManager.curScene:recoverViewByPlayerPos()
        end
    elseif msg == "show_playerImg_messag" then
        self.m_view:switchPlayerImgType(data.isShow)
    elseif msg == "qmdj_activate_pilar" then
        -- 激活八卦阵
        self:activatePillerEvent(data)
    end
end

-- 激活八卦阵
function M:activatePillerEvent(data)
    local function netCallback(response)
        if response then
            if SceneManager.curScene ~= nil then
                SceneManager.curScene:activatePillerEvent(self.m_model.m_data.cells, data.cell_id);
            end
        else
            self:qmdjGridRefreshReq()
        end
    end
    local params = {cell_id = data.cell_id, ver = self.m_model.m_data.ver}
    self.m_model:getNetData("enable_pillars", params, netCallback, 1, true)
end

-- 场景定时刷新
function M:sendQmdjTimerRefresh()
    -- 短时刷新，刷新当前玩家半径内格子
    local function shortTimerEvent()
        self:setOnceTimer(10, function()
            self:qmdjGridRefreshReq(function()
                shortTimerEvent()
            end)
        end)
    end
    shortTimerEvent()

    -- 长时刷新，刷新所有怪物格子
    local function longTimerEvent()
        self:setOnceTimer(60, function()
            if (SceneManager.curScene ~= nil) and (SceneManager.curScene.sceneId == Battle.BattleGlobalConfig.SCENE_ID.QiMenDunJiaScene) then
                local grids = SceneManager.curScene:getGridsByMonsterType()
                if table.nums(grids) > 0 then
                    local function netCallback(response)
                        if (SceneManager.curScene ~= nil) and (SceneManager.curScene.refreshGridsInfo ~= nil) then
                            SceneManager.curScene:refreshGridsInfo(self.m_model.m_data.cells)
                            longTimerEvent()
                        end
                    end
                    local params = {cell_ids = grids, ver = self.m_model.m_data.ver}
                    self.m_model:getNetData("gve_get_new_cells", params, netCallback, 0)
                end
            end
        end)
    end
    longTimerEvent()
end

-- 前往格子 cell_id: 格子id
function M:qmdjGoto(data)
    local function netCallback(response)
        self.m_view:refreshUI()
        if SceneManager.curScene ~= nil then
            SceneManager.curScene:serverMoveEndEvent(self.m_model.m_data);
        end
    end
    local params = {path = data.path,cell_id = data.cell_id, ver = self.m_model.m_data.ver}
    self.m_model:getNetData("gve_goto", params, netCallback, 1)
end

function M:requestUnion()
    local function callback(response)
        local guild_id = UserDataManager.user_data:getUserStatusDataByKey("guild_id")
        if guild_id and guild_id > 0 then
            self:openView("Union.UnionMain", response)
        else
            self:openView("Union.UnionIndex", response)
        end
    end
    self.m_model:getNetData("guild_index", nil, callback)
end

function M:requestForOpenSwordForge(cell_id)
    local request_key_str = "gve_enable_relic" --默认激活铸剑台
    if self.m_model:hasRelics() then
        request_key_str = "gve_detail"  --已经激活时，请求法宝的最新数据
    end
    local function netCallback(response)
        if response then
            self.m_view:refreshUI()
            self:openView("QiMenDunJia.QiMenDunJiaSwordForge", {main_data = self.m_model:getMainData()})
        end
    end
    local params = {ver = self.m_model:getVersion(), cell_id = cell_id}
    self.m_model:getNetData(request_key_str, params, netCallback)
end
function M:qmdjGridRefreshReq(callBack)
    if (SceneManager.curScene ~= nil) and (SceneManager.curScene.sceneId == Battle.BattleGlobalConfig.SCENE_ID.QiMenDunJiaScene) then 
        local grids = SceneManager.curScene:getRadiusGridsByUI()
        if table.nums(grids) > 0 then
            local function netCallback(response) 
                if (SceneManager.curScene ~= nil) then
                    if SceneManager.curScene.refreshGridsInfo then
                        SceneManager.curScene:refreshGridsInfo(self.m_model.m_data.cells)
                    end
                    if callBack then
                        callBack()
                    end
                end
            end
            local params = {cell_ids = grids, ver = self.m_model.m_data.ver}
            self.m_model:getNetData("gve_get_new_cells", params, netCallback, 0)
        end
    end
end

-- 协议异常处理, 奇门遁甲格子数据异常，请求最新格子数据及刷新
function M:qmdjReqErrorEvent(data)
    local status_code = data.data.status
    if status_code and tostring(status_code) == "58009" then
        self:qmdjGridRefreshReq()
    end
end

function M:showBuyStrengthWindow()
    local remain_times = self.m_model:getRemainBuyTimes()
    local params =
    {
        --内容
        msg = Language:getTextByKey("jubaoShan_str_005",self.m_model:getVip(), remain_times),
        --标题
        title = Language:getTextByKey("qi_men_dun_jia_str_028"),
        --通知的类名
        className = "QiMenDunJia.QiMenDunJiaMain",
        --最大购买次数
        m_max_buyNum = remain_times,
        --消耗类型
        cost_data = self.m_model:getCostType(),
        --消耗
        cost = self.m_model:getCost(1),
        --点击购买
        clickBuy = function( num )
            local function netCallback(response)
                --self.m_model:updateBuyTimes(response.buy_times)
                --self.m_model:updateStrength(response.health)
                self.m_view:refreshUI();
            end
            local params = {}
            params.times = num
            params.ver = self.m_model:getVersion()
            self.m_model:getNetData("gve_buy_health", params, netCallback)
        end
    }
    self:openView("QiMenDunJia.QiMenDunJiaBuyStrength", params)
end

function M:setExteriorOpen(exteriorOpen)
    if (SceneManager.curScene ~= nil) and (SceneManager.curScene.sceneId == Battle.BattleGlobalConfig.SCENE_ID.QiMenDunJiaScene) then
        SceneManager.curScene:setExteriorOpen(exteriorOpen)
        SceneManager:getCurSceneView().cameraController.CanDrag = (not exteriorOpen)
    end
end

--请求主数据更新
function M:requestForMainDataUpdate()
    local function netCallback(response)
        if response then
            self.m_view:refreshUI()
        end
    end
    self.m_model:getNetData("gve_index", nil, netCallback)
end

return M
