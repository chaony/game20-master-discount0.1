local M = class("UnionWarView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMainEnterce"
M.m_size_type = 2

function M:onEnter()
    self:initText()
    self:setObjectVisible("new_btn", self.m_model.m_is_open_high)
    self:setObjectVisible("new_btn_img", self.m_model.m_is_open_high)
    self:refreshUI()
end

function M:initText()
    -----------------公会战----begin-----------
    self:setTextByLanKey("common_title_text", "tid#GuildWar_2")
    self:setTextByLanKey("team_name_1", "UnionWar_str_082")
    self:setTextByLanKey("team_name_2", "UnionWar_str_083")
    self:setTextByLanKey("team_name_3", "UnionWar_str_084")
    self:setTextByLanKey("win_num_title_text", "new_str_0298")
    self:setTextByLanKey("record_num_title_text", "UnionWar_str_096")
    self:setTextByLanKey("this_record_num_title_text", "UnionWar_str_097")
    self:setTextByLanKey("set_reward_text", "UnionWar_str_097")
    self.season_text = self:findText("season_text")
    self.round_text = self:findText("round_text")
    self.score_number_text = self:findText("score_number_text")
    self.win_num_text = self:findText("win_num_text")
    self.rank_btn_text = self:findText("rank_btn_text")
    self.war_time = self:findText("war_time")
    self.war_time_text = self:findText("war_time_text")
    self.log_btn_text = self:findText("log_btn_text")
    self.team_btn_text = self:findText("team_btn_text")
    self.explain_btn_text = self:findText("explain_btn_text")
    self.gotobattle_btn_text = self:findText("gotobattle_btn_text")
    self.hui = self:findImage("hui")
    self.gotobattle_img = self:findImage("gotobattle_btn");
    self.gotobattle_btn = self:findButton("gotobattle_btn");
    self.team_head_bg_mask_1 = self:findGameObject("team_head_bg_mask_1");
    self.team_head_bg_mask_2 = self:findGameObject("team_head_bg_mask_2");
    self.team_head_bg_mask_3 = self:findGameObject("team_head_bg_mask_3");
    self.team_add_1 = self:findGameObject("team_add_1");
    self.team_add_2 = self:findGameObject("team_add_2");
    self.team_add_3 = self:findGameObject("team_add_3");
    self.team_add_red_dot_1 = self:findGameObject("team_add_red_dot_1");
    self.team_add_red_dot_2 = self:findGameObject("team_add_red_dot_2");
    self.team_add_red_dot_3 = self:findGameObject("team_add_red_dot_3");
    -----------------公会战----end----------------
    
    -----------------巅峰公会战----begin-----------
    for i = 1, 5 do
        self:setTextByLanKey("new_team_name_" .. i, "guild_high_war_text_0024", i)
    end
    self:setTextByLanKey("new_record_num_title_text", "UnionWar_str_096")
    self:setTextByLanKey("new_exploit_title_text", "guild_high_war_text_0025")
    self:setTextByLanKey("new_last_title_text", "guild_high_war_text_0026")
    self:setTextByLanKey("new_rank_btn_text", "new_str_0235")
    self:setTextByLanKey("new_log_btn_text", "UnionWar_str_006")
    self:setTextByLanKey("new_help_btn_text", "UnionWar_str_099")
    self:setTextByLanKey("new_gotobattle_btn_text", "guild_high_war_text_0027")
    self.new_score_number_text = self:findText("new_score_number_text")
    self.new_rank_btn_text = self:findText("new_rank_btn_text")
    self.new_war_time = self:findText("new_war_time")
    self.new_war_time_text = self:findText("new_war_time_text")
    self.new_log_btn_text = self:findText("new_log_btn_text")
    self.new_team_btn_text = self:findText("new_team_btn_text")
    self.new_gotobattle_btn_text = self:findText("new_gotobattle_btn_text")
    self.gotobattle_img = self:findImage("new_gotobattle_btn");
    self.gotobattle_btn = self:findButton("new_gotobattle_btn");
    self.new_team_head_bg_mask_1 = self:findGameObject("new_team_head_bg_mask_1");
    self.new_team_head_bg_mask_2 = self:findGameObject("new_team_head_bg_mask_2");
    self.new_team_head_bg_mask_3 = self:findGameObject("new_team_head_bg_mask_3");
    self.new_team_head_bg_mask_4 = self:findGameObject("new_team_head_bg_mask_4");
    self.new_team_head_bg_mask_5 = self:findGameObject("new_team_head_bg_mask_5");
    self.new_team_add_1 = self:findGameObject("new_team_add_1");
    self.new_team_add_2 = self:findGameObject("new_team_add_2");
    self.new_team_add_3 = self:findGameObject("new_team_add_3");
    self.new_team_add_4 = self:findGameObject("new_team_add_4");
    self.new_team_add_5 = self:findGameObject("new_team_add_5");
    self.new_team_add_red_dot_1 = self:findGameObject("new_team_add_red_dot_1");
    self.new_team_add_red_dot_2 = self:findGameObject("new_team_add_red_dot_2");
    self.new_team_add_red_dot_3 = self:findGameObject("new_team_add_red_dot_3");
    self.new_team_add_red_dot_4 = self:findGameObject("new_team_add_red_dot_4");
    self.new_team_add_red_dot_5 = self:findGameObject("new_team_add_red_dot_5");
    self:setTextByLanKey("new_ob_title_text", "guild_high_war_text_0046")
    self:setTextByLanKey("new_rank_label_text", "flower_text_0062")
    self:setTextByLanKey("new_rank_label_text", "flower_text_0062")
    self:setTextByLanKey("new_guild_label_text", "guild_high_war_text_0020")
    self:setTextByLanKey("new_city_label_text", "guild_high_war_text_0028")
    self:setTextByLanKey("new_result_label_text", "UnionWar_str_085")
    self:setTextByLanKey("new_gotobattle_btn_text", "guild_high_war_text_0047")
    --new_ob_round_name_text
   
    -----------------巅峰公会战----end------------
end

function M:refreshText()
    if self.m_model.m_cur_index == 1 then
        local data = self.m_model:getUnionWarInfo()
        self.season_text.text = string.format(Language:getTextByKey("UnionWar_str_002"), data.season_id)
        self.round_text.text = GlobalTools:ToCharacterHan(data.round)
        self.score_number_text.text = string.format(Language:getTextByKey("UnionWar_str_002"), data.score)
        self:setTextByLanKey("this_score_number_text",data.round_score)
        self.win_num_text.text = string.format(Language:getTextByKey("UnionWar_str_004"), data.win)
        self.rank_btn_text.text = Language:getTextByKey("UnionWar_str_007")
        self.log_btn_text.text = Language:getTextByKey("UnionWar_str_006")
        self.team_btn_text.text = Language:getTextByKey("UnionWar_str_005")
        self.explain_btn_text.text = Language:getTextByKey("UnionWar_str_060")
        self:setTextByLanKey("reward_btn_text", "UnionWar_str_099")
        local round_text = Language:getTextByKey("UnionWar_str_086",data.round,data.max_round)
        self:setTextByLanKey("round_name_text", round_text)
        self:setTextByLanKey("team_title", "new_str_0275")
    else
        local data = self.m_model:getGuildHighWarData()
        if data == {} then 
            Logger.logError("----------------------UnionWarView not get guideHighwar------------------------")
            return 
        end
        self.new_score_number_text.text = string.format(Language:getTextByKey("UnionWar_str_002"), data.score)
        local max_round = self.m_model:getTotalStage()
        local round_text = Language:getTextByKey("UnionWar_str_086",data.round_id,max_round)
        self:setTextByLanKey("new_exploit_number_text", data.self_score)
        self:setTextByLanKey("new_last_num_text", data.round_score)
        self:setTextByLanKey("new_round_name_text", round_text)
        self:setTextByLanKey("new_team_title", "new_str_0275")
        self:setTextByLanKey("new_ob_round_name_text", round_text)
    end
end

function M:updateBtnPosition()
    local o_trans = self:findGameObject("old_btn").transform
    local n_trans = self:findGameObject("new_btn").transform
    local img_bg = self:findImage("img_bg")
    local img_bg_trans = img_bg.transform --a_dfbhz_zjm_bg
    local new_btn_img_trans = self:findGameObject("new_btn_img").transform
    if self.m_model.m_is_high_ob then
        GameUtil:updateResourcesImg(img_bg.gameObject, "Texture/guildHighWar/a_dfbhz_gz_bg")
    else
        GameUtil:updateResourcesImg(img_bg.gameObject, "Texture/guildHighWar/a_dfbhz_zjm_bg")
    end
    self:setObjectVisible("new_btn_img", self.m_model.m_is_open_high and self.m_model.m_cur_index == 1)
    if self.m_model.m_is_open_high then
        if self.m_model.m_cur_index == 1 then
            UIUtil.setLocalPosition(o_trans,-424, -8.7,0)
            UIUtil.setLocalPosition(n_trans,546, -8.7,0)
            UIUtil.setLocalPosition(img_bg_trans,13, -5.9,0)
            UIUtil.setLocalPosition(new_btn_img_trans,539, 3.5,0)
        else
            UIUtil.setLocalPosition(o_trans,-424, -8.7,0)
            UIUtil.setLocalPosition(n_trans,-255, -8.7,0)
            UIUtil.setLocalPosition(img_bg_trans,115, -5.9,0)
            UIUtil.setLocalPosition(new_btn_img_trans,-258, -5.9,0)
        end
    else
        UIUtil.setLocalPosition(o_trans,-388, -8.7,0)
        UIUtil.setLocalPosition(img_bg_trans,13, -5.9,0)
    end
end

function M:refreshUI()
    local data = self.m_model:getUnionWarInfo()
    self:refreshText()
    if self.m_model.m_cur_index == 1 then
        self:refreshTeamSetRewardInfo()
        self:refreshTeamInfo()
    elseif self.m_model.m_cur_index == 2 then
        self:refreshNewTeamInfo()
    end
    self:refreshUnionWarInfo(data)
    self:refreshRedPoint()
    UserDataManager:removeRedDotByKey("guild_war_round_report")
    self:changePanel()
    
    --巅峰帮会战拦截
    local activeData = UserDataManager:getActivesDataByOpenId(295) or {}
    if not activeData then
        self:setObjectVisible("new_btn_img",false)
        self:setObjectVisible("new_btn",false)
    end
end

function M:changePanel()
    self:setObjectVisible("Panel_Old", self.m_model.m_cur_index == 1)
    self:setObjectVisible("Panel_New", self.m_model.m_cur_index == 2)
    self:setObjectVisible("New_Panel_img", self.m_model.m_cur_index == 2 and not self.m_model.m_is_high_ob)
    self:setObjectVisible("New_Panel_text", self.m_model.m_cur_index == 2 and not self.m_model.m_is_high_ob)
    self:setObjectVisible("Ob_Panel_img", self.m_model.m_cur_index == 2 and self.m_model.m_is_high_ob)
    self:setObjectVisible("Ob_Panel_text", self.m_model.m_cur_index == 2 and self.m_model.m_is_high_ob)
    if self.m_model.m_cur_index == 2 and self.m_model.m_is_high_ob then
        self:updateLoopScroll()
    end
    self:updateBtnPosition()
end

function M:refreshRedPoint()
    local go_to_red_bl = RedPointUtil:hasRedPointById(13301)
    self:setObjectVisible("gotobattle_btn_red_point", go_to_red_bl == true)
    self:setObjectVisible("new_btn_red_point", self.m_model.show_letter == 1)
    self:setObjectVisible("new_gotobattle_btn_red_point",self.m_model:getCurrentRedPoint())
end

function M:refreshTimeUI( str )
    -- 赛季阶段，0:未开始，1：报名-准备阶段，2：匹配阶段，3: 战斗阶段，4：结算阶段，5：休赛阶段，下个赛季未开始
    local time_str = str
    local war_str = Language:getTextByKey("UnionWar_str_055")
    local union_war_type = self.m_model.m_data.type
    if union_war_type == 0 then
        war_str = Language:getTextByKey("UnionWar_str_055"); --距离帮会战开启还有
    elseif union_war_type == 1 then
        war_str = Language:getTextByKey("UnionWar_str_056"); --距离报名结束还有
    elseif union_war_type == 2 then
        war_str = Language:getTextByKey("UnionWar_str_057"); --距离匹配结束还有
    elseif union_war_type == 3 then
        war_str = Language:getTextByKey("UnionWar_str_058"); --距离战斗结束还有
    elseif union_war_type == 4 then
        war_str = Language:getTextByKey("UnionWar_str_059"); --距离结算结束还有
    elseif union_war_type == 5 then
        war_str = Language:getTextByKey("UnionWar_str_055"); --距离帮会战开启还有
    end
    self.war_time.text = war_str
    self.war_time_text.text = time_str
    if union_war_type == 0 then
        self.gotobattle_btn.interactable = false;
        self.gotobattle_img.material = self.hui.material
        self:setObjectVisible("new_gotobattle_btn_red_point",false)
    elseif union_war_type == 5 then
        self.gotobattle_btn.interactable = true;
        self.gotobattle_img.material = self.hui.material
        self:setObjectVisible("new_gotobattle_btn_red_point",false)
    else
        self.gotobattle_btn.interactable = true;
        self.gotobattle_img.material = nil
    end
    self.m_union_war_type = union_war_type
end


function M:refreshUnionWarInfo( m_data )
    if m_data.type > 2 and m_data.type < 5 then --可以前往战场
        --data.is_sign 
        self.gotobattle_btn_text.text = Language:getTextByKey("UnionWar_str_009")
    elseif m_data.type == 2 then -- 匹配中
        self:setTextByLanKey("gotobattle_btn_text", "UnionWar_str_094")
    elseif m_data.type == 1 then --可以报名
        if m_data.is_sign then
            --已经报名
            --self.gotobattle_btn.interactable = false;
            --self.gotobattle_img.material = self.hui.material
            self.gotobattle_btn_text.text = Language:getTextByKey("UnionWar_str_050")
        else
            --还没有报名
            --self.gotobattle_btn.interactable = true;
            --self.gotobattle_img.material = nil
            self.gotobattle_btn_text.text = Language:getTextByKey("UnionWar_str_049")
        end
    elseif m_data.type == 0 or m_data.type == 5 then --不可以报名
        --灰色
        self.gotobattle_btn.interactable = false;
        self.gotobattle_img.material = self.hui.material
        self.gotobattle_btn_text.text = Language:getTextByKey("UnionWar_str_049")
    end
end

--刷新编队信息
function M:refreshTeamInfo()
    local teams = UserDataManager:getGvgTeamsByKey("def_teams")
    for i = 1, 3 do
        local team = teams[tostring(i)] or {}
        local show_hero_id = nil
        if team.team ~= nil then
            for k, v in ipairs(team.team) do
                if v ~= "" then
                    local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                    if hero_data == nil then
                        hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataByDataAndId(self.m_model.m_data.def_heros, v)
                    end
                    if hero_cfg then
                        show_hero_id = v
                        local icon = hero_cfg.icon
                        self:setImg(icon,"hero_head_ui","team_head_"..i)
                        break
                    end
                end
            end
        end
        self["team_head_bg_mask_" .. i]:SetActive(show_hero_id ~= nil)
        self["team_add_" .. i]:SetActive(show_hero_id == nil)
        self["team_add_red_dot_" .. i]:SetActive(self.m_model:getTeamSetStatus(i) == false)
    end
end

function M:refreshNewTeamInfo()
    local teams = UserDataManager:getGuildHighWarTeamsByKey()
    for i = 1, GameUtil:getGuildHighWarTeamNums() do
        local team = teams[i] or {}
        local show_hero_id = nil
        for k, v in ipairs(team) do
            if v ~= "" then
                local hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataById(v)
                if hero_data == nil then
                    hero_data, hero_cfg = UserDataManager.hero_data:getHeroDataByDataAndId(self.m_model.m_data.def_heros, v)
                end
                if hero_cfg then
                    show_hero_id = v
                    local icon = hero_cfg.icon
                    self:setImg(icon,"hero_head_ui","new_team_head_"..i)
                    break
                end
            end
        end
        self["new_team_head_bg_mask_" .. i]:SetActive(show_hero_id ~= nil)
        self["new_team_add_" .. i]:SetActive(show_hero_id == nil)
        self["new_team_add_red_dot_" .. i]:SetActive(self.m_model:getNewTeamSetStatus(i) == true)
    end
end

--刷新编队设置奖励信息
function M:refreshTeamSetRewardInfo()
    local reward_status = self.m_model:getTeamSetRewardStatus()
    self:setObjectVisible("team_set_reward_img", false)
    if reward_status and reward_status == true then
        if ConfigManager:getCfgByName("common")[596] then
            self:setObjectVisible("team_set_reward_img", true)
            local reward_data = {}
            reward_data = ConfigManager:getCfgByName("common")[596].value
            local item_data = RewardUtil:getProcessRewardData(reward_data)
            GameUtil:updateItemElementByData(self:findGameObject("team_set_reward_cell"), item_data, true, false)
        end
    end
end


--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
    self:setObjectVisible("common_tips_node", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "race_img" then
                    self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
                else
                    self:updateMsg("item_click", {id = index})
                end
            end,
            pull_refresh = function() -- 下拉刷新
                self.last_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank")
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
        if self.m_control.m_mail_load == true then
            self:pullRefreshListOffset()
        end
    end
end

function M:pullRefreshListOffset()
    self.now_offsety = self.m_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    --local position = self.m_list_scroll:getVerticalNormalizedPosition()
    local position = (self.last_offsety - self.now_offsety) / self.m_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_control.m_mail_load = false
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateRankIcon(id, transform, rank, luaBehaviour)
    if id then
        local top_three_flag = id < 4
        UIUtil.setObjectVisible(transform, top_three_flag, "top_three_rank_img")
        UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
        local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[id]
        if top_three_item then
            LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
        end
        for i = 1,3 do
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "Ui_Rank_Bang_00"..i, i==id)
        end
        UIUtil.setText(transform, tostring(rank), "rank_text")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
    else
        UIUtil.setObjectVisible(transform, false, "top_three_rank_img")
        UIUtil.setObjectVisible(transform, true, "rank_text")
        if rank < 1 then
            UIUtil.setTextByLanKey(transform, "none_rank_text", "new_str_0076")
            UIUtil.setTextByLanKey(transform, "rank_text", "")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
        else
            UIUtil.setTextByLanKey(transform, "none_rank_text", "")
            UIUtil.setText(transform, tostring(rank), "rank_text")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
        end
    end
end

function M:updateItemInfo(obj, data, id)
    local user = data.user or {}
    local rank = data.rank or 0
    local score = data.score or 0
    local citys = data.citys or {}
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    self:updateRankIcon(id, transform, rank, luaBehaviour)
    --LuaBehaviourUtil.setImg(luaBehaviour,"race_icon", race.race_icon, ResourceUtil:getLanAtlas())
    --UIUtil.setText(transform, tostring(score), "race_score_text")
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", true)
    local name_text = nil
    if user.name == nil or user.name == "" then
        name_text = UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
        name_text = UIUtil.setText(transform, tostring(user.name), "name_text")
    end
    UIUtil.setText(transform, tostring(citys["3"] or 0), "city_text1")
    UIUtil.setText(transform, tostring(citys["2"] or 0), "city_text2")
    UIUtil.setText(transform, tostring(citys["1"] or 0), "city_text3")
    UIUtil.setText(transform, tostring(score), "score_text")

    local gender = user.flag or 0
    local flag_cfg = ConfigManager:getCfgByName("guild_flag")[gender]
    if flag_cfg then
        local union_icon_img = luaBehaviour:FindImage("gender_img")
        GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
    end
    UIUtil.setObjectVisible(transform, gender > 0 and flag_cfg, "gender_img")

end

function M:destroy()
    UserDataManager:removeRedDotByKey("guild_war_round_report") 
    M.super.destroy(self)
end

return M





