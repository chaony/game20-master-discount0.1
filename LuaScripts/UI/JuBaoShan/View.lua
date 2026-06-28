local M = class("JuBaoShanView",LikeOO.OOPopBase)

M.m_uiName = "JuBaoShan/JuBaoShan"
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("text_autoDispatch", "jubaoShan_str_027")
    self:setTextByLanKey("text_seriesSeries", "jubaoShan_str_028")
    self:setTextByLanKey("text_maskHint", "jubaoShan_str_029")
    self:setTextByLanKey("lookfor_reward_txt", "jubaoShan_str_035")
    self:setTextByLanKey("text_seriesThrow", "jubaoShan_str_028")
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 19})
    self.gameObject3D = self:findGameObject("GameObject3D")
    self.shazi = self:findGameObject("ShaZi")
    self.shaziAnim = self.shazi:GetComponent(typeof(CS.UnityEngine.Animator))
    self.shaziAnim.speed = 2
    self.roll_num_show = self:findImage("roll_num_show");
    self:setObjectVisible("roll_num_show", false)
    self.use_time_txt = self:findText("use_time_txt");
    self.need_time_reward_txt = self:findText("need_time_reward_txt");
    self.roll_remain_time_txt = self:findText("roll_remain_time_txt");
    self.item_num_txt = self:findText("item_num_txt");
    self.roll_item_icon = self:findGameObject("roll_item_icon")
    self:setObjectVisible("CommonItemEffect", false)
    self:setTextByLanKey("close_title_text",Language:getTextByKey("jubaoShan_str_004"))
    self:setTextByLanKey("roll_shop_txt", Language:getTextByKey("jubaoShan_str_014"))
    self:setTextByLanKey("roll_zuobi_txt", Language:getTextByKey("jubaoShan_str_015"))
    self:setTextByLanKey("roll_remain_txt", Language:getTextByKey("roll_remain_tex"))
    self:setTextByLanKey("roll_random_txt", Language:getTextByKey("roll_random_txt"))
    self:setTextByLanKey("gift_bag_btn_text", "new_str_0732")
    self.gameObject3D.transform:SetParent(self.m_rootView.transform, false)
    self.gameObject3D.transform.localPosition = Vector3(0,0,0)
    --
    self.roll_end_time_txt = self:findText("roll_end_time_txt");
    self.cd_time = self.m_model.m_time;
    if self.cd_time > 0 then
        GameUtil:remainingTimeUpdate(self.m_control, "jubaoshan_time_update", self.roll_end_time_txt, self.cd_time, "jubaoshan_time_end", 1,"tid#credit_dicel_origin_3")
    else
        self.roll_end_time_txt.text = "";
    end
	self:refreshUI()
    self:setAutoNodeState()
end

function M:setAutoNodeState()
    local curVipLevel = UserDataManager.user_data:getUserStatusDataByKey("vip") or 0
    local vipXlsxData = ConfigManager:getCfgByName("vip")
    if not vipXlsxData[curVipLevel] then
        self:setObjectVisible("autoNode", false)
        return
    end
    self:setObjectVisible("autoNode", vipXlsxData[curVipLevel].translate_auto == 1)
end

function M:refreshAutoDispatch()
    self:setObjectVisible("img_autoDispatch", self.m_model.m_autoDispatch)
end

function M:refreshSeriesThrow()
    local isSeriesThrow = self.m_model.m_seriesThrow
    self:setObjectVisible("img_seriesThrow", isSeriesThrow)
    self:setObjectVisible("maskNode", isSeriesThrow)
    if isSeriesThrow then
        -- 开始自动寻路
        
    end
end

function M:showZuoBiView()
    self:setObjectVisible("zuobi_roll_num_show_root", true)
end

function M:hideZuoBiView()
    self:setObjectVisible("zuobi_roll_num_show_root", false)
end

function M:refreshUI()
    self:updateChapterTask();
    if self.m_model:HasCanUseReward() then
        self:setObjectVisible("CommonItemEffect", true)
    else
        self:setObjectVisible("CommonItemEffect", false)
    end
    
    if self.m_model.m_gift_open == 1 then
        self:setObjectVisible("gift_bag_btn", true)
    else
        self:setObjectVisible("gift_bag_btn", false)
    end
    
    self.item_num_txt.text = self.m_model.zuobiItemData.num;
    --剩余次数
    self.roll_remain_time_txt.text = self.m_model.m_data.times;
    --已经使用过的骰子次数
    local questItem = self.m_model.m_data.quests[tostring(104)]
    local quest_data = UserDataManager:getChapterQuestSpecialData(104, self.m_model.m_data.map_id)
    local nearItem = quest_data[1]
    --Logger.logError(self.m_model.m_data.quests, " self.m_model.m_data.quests ")
    --Logger.logError(quest_data, " quest_data ~~~~ ~~~~ ")
    --Logger.logError(questItem, " questItem ~~~~ ")
    --Logger.logError(nearItem, " nearItem ~~~~ ")
    if nearItem ~= nil then
        if questItem ~= nil then
            if nearItem.target_value <= questItem.value then
                self.need_time_reward_txt.text = Language:getTextByKey("new_str_0655")
            else
                local remain_time = nearItem.target_value - questItem.value
                self.need_time_reward_txt.text = Language:getTextByKey("jubaoShan_str_016", remain_time)
            end
        else
            local remain_time = nearItem.target_value - 0;
            self.need_time_reward_txt.text = Language:getTextByKey("jubaoShan_str_016", remain_time)
        end
        if nearItem.status == -1 then
            self.need_time_reward_txt.text = Language:getTextByKey("gf_str_0097")
        end
    end
    
    local drop = self.m_model:getCurQuest().drop
    local data = RewardUtil:getProcessRewardData(drop[1])

    if self.m_model.minTriggerTimeCell ~= nil then
        self:setObjectVisible("roll_item_icon", true)
        --展示奖励
        local reward = self.m_model.m_cell_lv_gift[tostring(self.m_model.minTriggerTimeCell.id)][tostring(self.m_model.minTriggerTimeCell.lv)]
        local data = RewardUtil:getProcessRewardData(reward)
        GameUtil:updateItemElementByData(self.roll_item_icon, data)
        local trigger_time = self.m_model.minTriggerTimeCell.trigger_time or 0
        if self.m_model.minTriggerTimeCell.trigger_time == nil then
            self.use_time_txt.text = Language:getTextByKey("jubaoShan_str_011");
        else
            local content = Language:getTextByKey("jubaoShan_str_007",trigger_time,data.name)
            self.use_time_txt.text = content;
        end
    else
        self:setObjectVisible("roll_item_icon", false)
        self.use_time_txt.text = Language:getTextByKey("jubaoShan_str_011");
    end

    if SceneManager:getCurSceneModel().allCellPools ~= nil then
        --是否有空的位置
        local hasEmpty = self:hasBuildEmpty()
        self:setObjectVisible("rollInfo_red_point", hasEmpty)
    end

    --快速导航
    self:setObjectVisible("guide_btn", true)
end


function M:updateChapterTask()
    GameUtil:updateQuestSpecialNode(self, 104, 1, self.m_model.m_data.map_id,1)
end


function M:checkCondition( cell_data )
    --需要的条件
    local m_need = {}
    if cell_data.cell_config ~= nil then
        m_need = cell_data.cell_config.param.need
    end
   
    --品质
    local evo_condition = {}
    --需要的条件
    local slotNum = 0;
    if cell_data.cell_config ~= nil then
        for i, v in pairs(cell_data.cell_config.slot) do
            slotNum = slotNum + 1;
            evo_condition[i] = v;
        end
    end
    
    --当前开启的槽位
    local max_solt_num = 0;
    for i = 1, slotNum do
        local need_lv = evo_condition[i][1]
        if cell_data.lv >= need_lv then
            max_solt_num = i;
        end
    end
    
    for i, v in pairs(m_need) do
        local race_heros = self:getRaceHeros(v);
        if _G.next(race_heros) ~= nil then
            for i = 1, max_solt_num do
                for race_index, race_hero_id in pairs(race_heros) do
                    if self:hasHero(race_hero_id) == false then
                        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(race_hero_id)
                        local hero_evo = hero_data.evo;
                        if hero_evo >= evo_condition[i][2] then
                            return true;
                        end
                    end
                end
            end     
        end
    end
    return false;
end


function M:hasHero( hero_id )
    self.m_allCells = SceneManager:getCurSceneModel().allCellPools;
    for i, v in pairs(self.m_allCells) do
        if v.team ~= nil then
            for team_i, team_hero in pairs(v.team) do
                if team_hero == hero_id then
                    return true;
                end 
            end
        end
    end
    return false;
end


function M:getRaceHeros( race )
    local race_heros = {}
    -- 我的所有英雄
    local heros = table.copy(UserDataManager.hero_data:getHerosId())
    for i, v in pairs(heros) do
        local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
        local hero_race = hero_cfg.race;
        if hero_race == race then
            table.insert(race_heros, v)
        end
    end
    return race_heros;
end



function M:hasBuildEmpty()
    local cells, minCell = self.m_model:buildData();
    local team_number = 0
    for i, v in pairs(cells) do
        local cell_data = v;
        local evo_condition = {}
        --需要的条件
        local slotNum = 0;
        if cell_data.cell_config ~= nil then
            for i, v in pairs(cell_data.cell_config.slot) do
                slotNum = slotNum + 1;
                evo_condition[i] = v;
            end
        end

        local max_solt_num = 0;
        for i = 1, slotNum do
            local need_lv = evo_condition[i][1]
            if cell_data.lv >= need_lv then
                max_solt_num = i;
            end
        end
        
        if cell_data.team ~= nil and _G.next(cell_data.team) ~= nil then
            for i, v in pairs(cell_data.team) do
                team_number = team_number + 1;
            end
            if team_number < max_solt_num then
                --不瞒住条件
                if self:checkCondition(cell_data) then
                    return true
                end
            end
        else
            if self:checkCondition(cell_data) then
                return true
            end
        end
    end
    
    return false;
end


--显示 Roll 点数
function M:showRollNum( num )
    self:setObjectVisible("roll_num_show", true);
    self:setObjectVisible("UI_JuBaoShan_ShaiZi01",true)
    self.shaziAnim:CrossFadeInFixedTime("idle_"..num,0.1)
    -- a_jbs_dice_1
    --LuaBehaviourUtil.setImg(self.m_luaBehaviour,"roll_num_show","a_jbs_dice_"..num, "maze_stage_ui")
end

--隐藏 Roll 点数
function M:hideRoleNum()
    self:setObjectVisible("roll_num_show", false);
    self:setObjectVisible("UI_JuBaoShan_ShaiZi01",false)
end


function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    EventDispatcher:unRegisterEvent("jubaoshan_time_update")
    EventDispatcher:unRegisterEvent("MazeStageViewTime")
    M.super.destroy(self)
end

return M