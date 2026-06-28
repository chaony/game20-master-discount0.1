local M = class("UnionWarSmallTipView", LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarSmallTip"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("back_btn_text", "new_str_0478")
    self:setTextByLanKey("battle_btn_text", "new_str_0166")
    self:setTextByLanKey("enemy_title_text", "UnionWar_str_091")
    -- self:setTextByLanKey("difficulty_title_di", "UnionWar_str_105") --挑战难度标题
    self:setTextByLanKey("reward_title_text","hunt_treasure_str_036")
    self:setTextByLanKey("difficulty_title_text","UnionWar_str_105")
    self.guild_war_map_cfg_item = self.m_model:getGuildWarMapCfg()
    self:setTextByLanKey("common_title_text", self.guild_war_map_cfg_item.name)
    self:setTextByLanKey("tip_text", self.guild_war_map_cfg_item.text, tostring(self.m_model:getTeamNum()))
    self.reward_node = self:findGameObject("reward_node")
    self:setTextByLanKey("combat_num_text", tostring(self.m_model.m_total_combat))
    local is_own = self.m_model:isOwn()
    self:setObjectVisible("reward_title_text", not is_own)
    self:setObjectVisible("reward_node", not is_own)
    self:setObjectVisible("battle_btn", not is_own)
    self.difficulty_item = self:findGameObject("difficulty_di")
    self.difficulty_change = self:findGameObject("difficulty_change_di")
    local difficulty = self:findGameObject("difficulty")
    self.rect = difficulty:GetComponent("RectTransform")

    --self.btn_difficulty_1 = self:findGameObject("change_gou_1")
    --self.btn_difficulty_2 = self:findGameObject("change_gou_2")
    --self.btn_difficulty_3 = self:findGameObject("change_gou_3")
    --难度星级显示
    for i = 1, 3 do
        local enemy_hf_text,enemy_akf_text = self:getHfAndAkf(i)
        --难度名称
        local difficulty_name = "difficulty_name_"..i
        local difficulty_hf = "enemyHf_name_"..i
        local difficulty_akf = "enemyAfk_name_"..i
        self:setTextByLanKey(difficulty_name,Language:getTextByKey("UnionWar_str_102",i))
        self:setTextByLanKey(difficulty_hf,Language:getTextByKey("UnionWar_str_103",enemy_hf_text).."%")
        self:setTextByLanKey(difficulty_akf,Language:getTextByKey("UnionWar_str_103",enemy_akf_text).."%")
    end
    self:refreshDifficulty()
    self:setDifficulty()
    self:refreshUI()
end

--设置难度选项
function M:setDifficulty()
    self.difficulty_item:SetActive(self.m_model.m_difficulty == 0)
    self.difficulty_change:SetActive(self.m_model.m_difficulty ~= 0)
    local rece_height = self.m_model.m_difficulty == 0 and 65 or 165
    self.rect.sizeDelta = Vector2(self.rect.rect.width, rece_height)
    local handle_point = self.m_model.m_difficulty == 0 and "a_ui_currency_xiala" or "a_ui_currency_shouqi"
    self:setImg(handle_point,"common_ui","btn_pull")
    
end

--刷新难度数据
function M:refreshDifficulty()
   local enemy_hf_text,enemy_akf_text = self:getHfAndAkf(self.m_model.m_difficulty_star)
    self:setTextByLanKey("difficulty_name",Language:getTextByKey("UnionWar_str_102",self.m_model.m_difficulty_star))
    self:setTextByLanKey("enemyHf_name",Language:getTextByKey("UnionWar_str_103",enemy_hf_text).."%")
    self:setTextByLanKey("enemyAfk_name",Language:getTextByKey("UnionWar_str_103",enemy_akf_text).."%")
    for i = 1, 3 do
        local btn_difficulty_name = "change_gou_"..i
        self:setObjectVisible(btn_difficulty_name,self.m_model.m_difficulty_star == i)
        local star_name = "difficulty_star_"..i
        if i > self.m_model.m_difficulty_star then
            self:setImg("a_ui_currency_xing_di","common_ui",star_name)
        else
            self:setImg("a_bh_xing","active_ui",star_name)
        end
    end
    self:refreshReward()
end

--刷新奖励数据
function M:refreshReward()
    local reward_num = self.m_model:getRewardAddition(self.m_model.m_difficulty_star)
    local drop = self.guild_war_map_cfg_item.reward or {}
    local drop_new = table.copy(drop)
    for i, v in pairs(drop_new) do
        v[3] = math.floor(reward_num * 0.01 * drop_new[i][3])
    end
    GameUtil:createRewards(self.reward_node.transform, drop_new, true, true, nil, 1, nil)
end

--获取敌人加成
function M:getHfAndAkf(id)
    local enemybuff = self.m_model:getEnemyAddition(id)
    local enemy_hf = enemybuff[1] - 100
    local enemy_hf_text = enemy_hf >= 0 and "+"..enemy_hf or enemy_hf
    local enemy_akf = enemybuff[2] -100
    local enemy_akf_text = enemy_akf >= 0 and "+"..enemy_akf or enemy_akf
    return enemy_hf_text,enemy_akf_text
end

function M:refreshUI()
    self:updateLoopScroll()

    local function tick(_, dt)
        self:refreshEnterBtnVisable()
    end
    self.m_control:setTimer(5, tick)
    self:updateStartBtn()


    local btn = self:findButton("battle_btn")

    if self.m_model:getFormationIndex() then

        self:setObjectVisible("txt_noTeam", false)
        btn.interactable = true
    else
        --self:setObjectVisible("txt_noTeam", true)
        btn.interactable = true
    end

end

function M:refreshEnterBtnVisable()
    --23:00-0:00不显示驻扎
    local cur_time = UserDataManager:getServerTime() --服务器时间
    local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(cur_time)
    if hour >= 23 then
        self:setObjectVisible("battle_btn", false)
    end
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getShowHeroData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            one_line_count = 5,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                local luaBehaviour = UIUtil.findLuaBehaviour(transform)
                local item_node = luaBehaviour:FindGameObject("item_node")
                CommonUIUtil:updateHeroElementByData(item_node, cell_data, nil, true)
                CommonUIUtil:updateHeroLvByData(item_node, data.hero_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

function M:updateStartBtn()
end

function M:destroy()
    M.super.destroy(self)
end

return M
