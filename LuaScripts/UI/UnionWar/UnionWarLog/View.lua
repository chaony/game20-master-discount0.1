local M = class("UnionWarLogView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarLog"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn_key = "tog_1", lua_name = "socreNode", text_key = "tog_1_text", show_text = "UnionWar_str_080" , red_point_img = "race_red_point_img"}, -- 积分（结算）
    {btn_key = "tog_2", lua_name = "battleNode", text_key = "tog_2_text", show_text = "UnionWar_str_026" , red_point_img = "reward_red_point_img"}, -- 回放   
    {btn_key = "tog_3", lua_name = "activeNode", text_key = "tog_3_text", show_text = "UnionWar_str_108" , red_point_img = "active_red_point_img"}, -- 活跃度 
}

--格子的大小
local _TEAM_NAME =
{
    [1] = "UnionWar_str_046",
    [2] = "UnionWar_str_047",
    [3] = "UnionWar_str_048",
}

--按钮信息
local _BTN_INFO = 
{
    [1] = "UnionWar_str_044", --我的战报
    [2] = "UnionWar_str_045", --敌方战报
}

function M:onEnter()
    self.m_gray_image = self:findImage("gray_image")
    self:setObjectVisible("scorenode", false)
    self:setObjectVisible("battlenode", false)
    self:setTextByLanKey("my_text","UnionWar_str_044")
    self:setTextByLanKey("common_no_have_text","new_str_0351")
    self:setTextByLanKey("common_title_text","biaoti_text")
    self.m_toggle_btns = {}
    self.max_len = 5;
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.text_key, v.show_text)
        local tog_btn = self:findToggle(v.btn_key)
        self.m_toggle_btns[k] = tog_btn
        if k == 1 then
            tog_btn.gameObject:SetActive(self.m_model.m_show_settlement_tab ~= false)
        end
        UIUtil.addToggleListener(tog_btn, function(is_on) 
            self:switchTabUpdate(is_on, k) 
        end,nil,self.m_uiName)
        if k == self.m_model.m_open_tab_index then
            tog_btn.isOn = true
            self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
        else
            self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
        end
        self:setObjectVisible(v.red_point_img, false)
    end
    self.hero_info = self:findGameObject("hero_info")
    self.good_num_txt = self:findText("good_num_txt")
    self.good1_obj = self:findGameObject("good1")

    self.labelData = {}
    self.guild_tips = ConfigManager:getCfgByName("guild_war_tips");
    
    self:setTextByLanKey("my_text", Language:getTextByKey(_BTN_INFO[1]))
    self:setTextByLanKey("all_text", Language:getTextByKey(_BTN_INFO[2]))
end


function M:refreshUI()
    self:setObjectVisible("CommonTipsNode", true)
    if self.m_model.m_sel_tab_index == 1 then
        self:setTextByLanKey("common_title_text", "UnionWar_str_093")
        self:updateZhanKuangLoopScroll();
        local luabehaviour = UIUtil.findLuaBehaviour(self.hero_info)
        self:updateHeroInfo(luabehaviour, self.m_model.m_last_report.mvp);
        self.good_num_txt.text = self.m_model:getLikeCount()
        if self.m_model.m_last_report.is_like == 1 then
            self.good1_obj:SetActive(false)
        end
    elseif self.m_model.m_sel_tab_index == 2 then
        self:setTextByLanKey("common_title_text", "UnionWar_str_092")
        self:updateBattleLogMyButtonText()
        self:updateLoopScroll()
    elseif self.m_model.m_sel_tab_index == 3 then
        --self:setTextByLanKey("common_title_text", "UnionWar_str_092")
        self:setObjectVisible("CommonTipsNode", false)
        self:updateListScrollActive()
    end
end

--点赞
function M:updateLike( data )
    self.good_num_txt.text = data.like;
    self.good1_obj:SetActive(false)
end


function M:updateHeroInfo( cur_LuaBehaviour, data )
    if cur_LuaBehaviour ~= nil and data ~= nil and data.user ~= nil then
        --玩家名字
        local player_name_txt = cur_LuaBehaviour:FindText("player_name");
        player_name_txt.text = data.user.name;
        --加载spine动画
        local hero = cur_LuaBehaviour:FindGameObject("hero")
        local cfg = ConfigManager:getPlayerPictureCfg(data.user.avatar);
        local spine_name = cfg.hero_spine;
        if spine_name and spine_name ~= "" then
            GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
        end
        
        if data.labels ~= nil then
            local index = 0;
            for i, v in pairs(data.labels) do
                index = index + 1;
                local data = self.guild_tips[v];
                if data ~= nil then
                    table.insert(self.labelData, data);
                    UIUtil.setImg(self.hero_info.transform, data.img, "language_zh_cn", "lan"..index);
                end
            end
            for i = 3, index + 1, -1 do
                self:setObjectVisible("lan"..i, false)
            end
        end
    else
        self:setObjectVisible("hero_info", false);
    end
end

--[[
	战况列表
]]
function M:updateZhanKuangLoopScroll()
    local data = self.m_model.m_last_report.rank_data
    local active_state = #data > 0
    self:setObjectVisible("CommonTipsNode", not active_state)
    self:setObjectVisible("multi_formation_list_node", active_state)
    if self.m_zhankuang_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("zhankuang_loopscroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateZhanKuangScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
            end
        }
        self.m_zhankuang_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_zhankuang_loop_scroll_view:reloadData(data, true)
    end
end


--Scroll内cell的回调
function M:updateZhanKuangScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_union_name", cell_data.left_guild)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_union_name", cell_data.right_guild)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", cell_data.cell_cfg.name)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "left_name_text", "UnionWar_str_040", cell_data.left_t_num)
    --LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "right_name_text", "UnionWar_str_040", cell_data.right_t_num)
    --local lan_atlas = ResourceUtil:getLanAtlas()
    --local my_guild_name = UserDataManager.user_data:getUserStatusDataByKey("guild_name")
    --if my_guild_name == cell_data.left_guild then
    --    local imgName = cell_data.left_win and "a_bh_shengli_zi" or "a_bh_shibai_zi"
    --    LuaBehaviourUtil.setImg(luaBehaviour, "left_result_icon",  imgName, lan_atlas)
    --else
    --    local imgName = cell_data.right_win and "a_bh_shengli_zi" or "a_bh_shibai_zi"
    --    LuaBehaviourUtil.setImg(luaBehaviour, "left_result_icon",  imgName, lan_atlas)
    --end
    
    --新逻辑
    local cfg = ConfigManager:getPlayerPictureCfg(cell_data.user.avatar);
    LuaBehaviourUtil.setImg(luaBehaviour,"tx_img",cfg.icon,"hero_head_ui") --头像
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"lv_text",cell_data.user.level) --等级
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"name_text",cell_data.user.name) --玩家名称
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"activity_text","UnionWar_str_088") --活跃度
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"activity_num_text",cell_data.active_point) --活跃度值
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"getstar_text","UnionWar_str_089") --获得
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"getstar_num_text",cell_data.star) --获得值
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"rank_Img",cell_data.position<3)
    if cell_data.position == 1 then
        LuaBehaviourUtil.setImg(luaBehaviour,"rank_Img","a_bh_icon_bangzhu", "icon_img")
    elseif cell_data.position == 2 then
        LuaBehaviourUtil.setImg(luaBehaviour,"rank_Img","a_bh_icon_zhanglao", "icon_img")
    end
end

function M:switchTabUpdate(is_on, update_key)
    local tog_nod = __TAB_BTN_NODE[update_key]
    if is_on then
        self:updateMsg("check_tag", update_key)
        self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
    else
        self:setTextColor(tog_nod.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
    end
end

function M:switchNode(index)
    self:setObjectVisible("scorenode", index == 1)
    self:setObjectVisible("battlenode", index == 2)
    self:setObjectVisible("activenode", index == 3)
    self:refreshUI()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getLogData()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("global_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            pull_refresh = function() -- 下拉刷新
                if self.m_model:canPullRefresh() then
                    self.m_model:getBattleData(function()
                        self:refreshUI();
                    end)
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, false)
    end
    self:setObjectVisible("CommonTipsNode", #data == 0)
    local active_list = #data == 0
    self:setObjectVisible("multi_formation_list_node", not active_list)
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_power_title_text", "friend_str_0041")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_power_title_text", "friend_str_0041")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_mine_text", self.m_model.m_left_guide_info.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_enemy_text", self.m_model.m_right_guide_info.name)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "title_node", index == 1)

    local img_enemyAndself = false
    if self.m_model.showIndex == 1 then
        img_enemyAndself = true
    elseif self.m_model.showIndex == 2 then
        img_enemyAndself = false
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_self",img_enemyAndself)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_enemy",img_enemyAndself)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_enemy_left",not img_enemyAndself)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"img_self_right",not img_enemyAndself)
    --赢了的人
    local win_uid = cell_data.win;

    --设定头像头像图片
    local headnode_self = luaBehaviour:FindGameObject("headnode_self")
    GameUtil:setUserAvatar(headnode_self, cell_data.atk_user,nil,nil,{show_flag = true, scale = 1})
    --我方名字
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_cell_player_name_text", cell_data.atk_user.name)
    --我方队伍名字
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_cell_player_team_num", _TEAM_NAME[cell_data.atk_tid])
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_power_text", GameUtil:formatValueToString(cell_data.atk_combat))
    
    --设定敌人的头像
    local headnode_enemy = luaBehaviour:FindGameObject("headnode_enemy")
    GameUtil:setUserAvatar(headnode_enemy, cell_data.def_user,nil,nil,{show_flag = true, scale = 1})
    --设定敌人的名字
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_cell_player_name_text", cell_data.def_user.name)
    --敌人队伍名字
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "self_cell_player_team_num", _TEAM_NAME[cell_data.def_tid])
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "enemy_power_text", GameUtil:formatValueToString(cell_data.def_combat))
    --攻击方胜利
    if win_uid == cell_data.atk_user.uid then
        LuaBehaviourUtil.setImg(luaBehaviour,"self_result","a_bh_shengli_zi", "language_zh_cn")
        LuaBehaviourUtil.setImg(luaBehaviour,"enemy_result","a_bh_shibai_zi", "language_zh_cn")
        LuaBehaviourUtil.setImg(luaBehaviour,"enemy_result_bg","a_bh_shibaidi", "arena_ui")
        LuaBehaviourUtil.setImg(luaBehaviour,"self_result_bg","a_bh_shenglidi", "arena_ui")
        local enemy_bg = luaBehaviour:FindGameObject("enemy_result_bg");
        local scale = enemy_bg.transform.localScale;
        scale.x = 1;
        enemy_bg.transform.localScale = scale;

        local my_bg = luaBehaviour:FindGameObject("self_result_bg");
        local scale = my_bg.transform.localScale;
        scale.x = 1;
        my_bg.transform.localScale = scale;
    else
        LuaBehaviourUtil.setImg(luaBehaviour,"enemy_result","a_bh_shengli_zi", "language_zh_cn")
        LuaBehaviourUtil.setImg(luaBehaviour,"self_result","a_bh_shibai_zi", "language_zh_cn")
        LuaBehaviourUtil.setImg(luaBehaviour,"enemy_result_bg","a_bh_shenglidi", "arena_ui")
        LuaBehaviourUtil.setImg(luaBehaviour,"self_result_bg","a_bh_shibaidi", "arena_ui")
        local enemy_bg = luaBehaviour:FindGameObject("enemy_result_bg");
        local scale = enemy_bg.transform.localScale;
        scale.x = -1;
        enemy_bg.transform.localScale = scale;
        
        local my_bg = luaBehaviour:FindGameObject("self_result_bg");
        local scale = my_bg.transform.localScale;
        scale.x = -1;
        my_bg.transform.localScale = scale;
    end
    local star = cell_data.star or 0
    for i = 1, 3 do
        local star_img = luaBehaviour:FindImage('star_img_' .. i)
        if i > star then
            star_img.material = self.m_gray_image.material
        else
            star_img.material = nil
        end
    end
end

function M:updateBattleLogMyButtonText()
    if self.m_model.log_type_sub == 0 then--我方战报
        self:setTextByLanKey("my_text","UnionWar_str_109")
    else--我的战报
        self:setTextByLanKey("my_text","UnionWar_str_044")
    end
end

function M:createHeros(team_node, rewards, is_show_num, is_show_detail, callback)
    local rewards = rewards or {}
    for i = 1, 5 do
        local hero_node = UIUtil.findTrans(team_node.transform, "hero_node_" .. i)
        local item_data = rewards[i]
        if item_data and _G.next(item_data) then
            GameUtil:updateItemElementByData(hero_node,item_data,false,false,function ()
                self:updateMsg("goDownBattle", { heroid = item_data.hero_data.oid})
                --self.m_model.m_multi_formation_changed_flag = true
            end)
            local hero_luaBehaviour = UIUtil.findLuaBehaviour(hero_node)
            if hero_luaBehaviour then
                LuaBehaviourUtil.setObjectVisible(hero_luaBehaviour, "lock_image", team_lock == false)
            end
        else
            GameUtil:updateItemElementNoData(hero_node)
        end
    end
end

function M:updateListScrollActive()
    local data = self.m_model:getListDataActive()
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        if v.uid == self.m_model.m_active_target_uid then
            all_cell_size[i] = Vector2(844.4, 190)
        else
            all_cell_size[i] = Vector2(844.4, 119)
        end
    end
    if self.m_active_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            all_cell_size = all_cell_size,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandleActive(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, data = cell_data})
            end,
            ui_name = self.m_uiName
        }
        self.m_active_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_active_list_scroll:reloadData(data,true, all_cell_size)
    end
end

function M:listHandleActive(obj, id, data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    local name_text = luaBehaviour:FindText("name_text")
    local lv_text = luaBehaviour:FindText("lv_text")
    local time_text = luaBehaviour:FindText("time_text")
    local score_text = luaBehaviour:FindText("score_text")
    local npc_img = luaBehaviour:FindGameObject("npc_img")
    local president_img = luaBehaviour:FindGameObject("president_img")
    local time_bg = luaBehaviour:FindGameObject("time_bg")

    GameUtil:setUserAvatar(HeadNode, data, nil, nil, {show_flag = true, scale = 1})
    if data.name == "" then
        name_text.text = Language:getTextByKey("new_str_0141")
    else
        name_text.text = data.name
    end
    president_img:SetActive(data.position<3)
    if data.position == 1 then
        GameUtil:setLanImgText(president_img.transform, "a_bh_icon_bangzhu", "icon_img")
    elseif data.position == 2 then
        GameUtil:setLanImgText(president_img.transform, "a_bh_icon_zhanglao", "icon_img")
    end
    npc_img:SetActive(self.m_model:getIsNPCActive(data.uid))
    --lv_text.text = Language:getTextByKey("union_str_0004") .. data.level
    score_text.text = data.self_guild_exp

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "star_text", "union_str_1076", tostring(data.star))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "battle_times_text", "union_str_1077", tostring(data.battle_times))
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "hero_num_text", "union_str_1078", tostring(data.hero_num))

    
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0557")
    local time_str = ""
    if data.is_online == 0 then
        time_bg:GetComponent("RectTransform").sizeDelta = Vector2(137, 27)
        local time = UserDataManager:getServerTime() - data.last_active_time
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(time)

        if day > 0 then
            time_str = string.format(Language:getTextByKey("mail_str_0002"),day)
        elseif hour > 0 then
            time_str = string.format(Language:getTextByKey("mail_str_0003"),hour)
        elseif min > 0 then
            time_str = string.format(Language:getTextByKey("mail_str_0004"),min)
        else
            time_str = Language:getTextByKey("mail_str_0005")
        end
        --time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_11
        time_text.color = Color( 83/255, 49/255, 26/255)
    else
        time_bg:GetComponent("RectTransform").sizeDelta = Vector2(60, 27)
        time_str = Language:getTextByKey("mail_str_0006")
        --time_text.color = GlobalConfig.COMMON_COLLOR.COMMON_12
        time_text.color = Color( 0, 178/255, 4/255)
    end
    time_text.text = time_str

    local rect = obj:GetComponent("RectTransform")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_point_btn", self.m_model.m_active_position ~= GlobalConfig.UNION_POS.COMMON)
    if data.uid == self.m_model.m_active_target_uid then
        rect.sizeDelta = Vector2(rect.rect.width, 190)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", true)
        LuaBehaviourUtil.setImg(luaBehaviour, "handle_point_img", "a_ui_currency_shouqi", "common_ui")
        self:updateHandleScrollActive(luaBehaviour:FindGameObject("handle_scroll"))
    else
        rect.sizeDelta = Vector2(rect.rect.width, 119)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "handle_Panel", false)
        LuaBehaviourUtil.setImg(luaBehaviour, "handle_point_img", "a_ui_currency_xiala", "common_ui")
    end
    
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "score_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "score_title_text", false)
end

----------------------------------------------------------------------------------------------------------
--- 成员管理

function M:updateHandleScrollActive(scroll_obj)
    local data = self.m_model.m_active_handle_list
    if self.m_active_handle_scroll ~= nil then
        self.m_active_handle_scroll = nil
    end

    local params = {
        show_data = data,
        one_line_count = 6,
        loop_scroll_object = scroll_obj,
        update_cell = function(index, cell_object, cell_data)
            local transform = cell_object.transform
            local data = cell_data
            self:handleHandleActive(cell_object, index, cell_data)
        end,
        click_func = function(index, cell_object, cell_data, click_object, click_name)
            self:updateMsg(click_name, cell_data)
        end,
        ui_name = self.m_uiName
    }
    self.m_active_handle_scroll = LoopScrollViewUtil.new(params)
end

function M:handleHandleActive(obj, id, data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local handle_btn
    if data == GlobalConfig.UNION_HANDLE_ID.DEMOTE then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1054", Language:getTextByKey("union_str_1056"))
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
    elseif data == GlobalConfig.UNION_HANDLE_ID.CHANGE_ELITE then
        local flag = self.m_model:getIsNPCActive(self.m_model.m_active_target_uid)
        if flag then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1054", Language:getTextByKey("union_str_1057"))
            LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1053")
            LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_3","common_ui")
        end
    elseif data == GlobalConfig.UNION_HANDLE_ID.PROMOTE_ELDER then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1052")
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_3","common_ui")
    elseif data == GlobalConfig.UNION_HANDLE_ID.DELETE then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1055")
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
    elseif data == GlobalConfig.UNION_HANDLE_ID.BLACK then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "new_str_0376")
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
    elseif data == GlobalConfig.UNION_HANDLE_ID.ABDICATE then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1070")
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_1","common_ui")
    elseif data == GlobalConfig.UNION_HANDLE_ID.SEND_MAIL then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "handle_btn_text", "union_str_1074")
        LuaBehaviourUtil.setImg(luaBehaviour,"handle_btn","a_ui_currency_btn_small_2","common_ui")
    end
end





return M