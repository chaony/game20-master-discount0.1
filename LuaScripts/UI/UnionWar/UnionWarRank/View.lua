local M = class("UnionWarRankView",LikeOO.OOPopBase)

M.m_uiName = "UnionWar/UnionWarRank"
M.m_size_type = 2

local __TAB_BTN_NODE = {
    {btn_key = "tog_1", lua_name = "RankListNode", text_key = "tog_1_text", show_text = "UnionWar_str_011" , red_point_img = "race_red_point_img"}, -- 本赛季
    {btn_key = "tog_2", lua_name = "RankListNode", text_key = "tog_2_text", show_text = "UnionWar_str_012" , red_point_img = "reward_red_point_img"}, -- 上赛季
    --{btn_key = "tog_3", lua_name = "RewardNode", text_key = "tog_3_text", show_text = "UnionWar_str_013" , red_point_img = "reward_red_point_img"}, -- 奖励
}

function M:onEnter()
    self.m_toggle_btns = {}
    for k,v in pairs(__TAB_BTN_NODE) do
        self:setTextByLanKey(v.text_key, v.show_text)
        local tog_btn = self:findToggle(v.btn_key)
        self.m_toggle_btns[k] = tog_btn
        UIUtil.addToggleListener(tog_btn, function(is_on) self:switchTabUpdate(is_on, k) end,nil,self.m_uiName)
        if k == self.m_model.m_open_tab_index then
            tog_btn.isOn = true
            self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_25)
        else
            self:setTextColor(v.text_key, GlobalConfig.COMMON_COLLOR.COMMON_24)
        end
        self:setObjectVisible(v.red_point_img, false)
    end

    self:setTextByLanKey("rank_label_text", "new_str_0374")
    self:setTextByLanKey("player_label_text", "UnionWar_str_014")
    self:setTextByLanKey("score_label_text", "UnionWar_str_085")
    self:setTextByLanKey("own_score_title_text", "new_str_0380")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
    self:setTextByLanKey("player_label_text2", "new_str_0372")
    self:setTextByLanKey("reward_label_text", "new_str_0373")
    self:setTextByLanKey("lv_label_text", "UnionWar_str_015")

    self.m_own_info_node = self:findGameObject("own_info_node")
    self.m_own_info_prefab = GameUtil:createPrefab("Rank/RankListItem",self.m_own_info_node.transform)
    local btn = UIUtil.findButton(self.m_own_info_prefab.transform)
    btn.enabled = false
    self:setTextByLanKey("common_title_text", "new_str_0114")
    self:setTextByLanKey("own_rank_title_text", "new_str_0077")
    self:setTextByLanKey("reward_btn_text", "new_str_0110")
    self.m_reward_red_point_img = self:findGameObject("tog_2_red_point_img")
    self:refreshUI()       
end

function M:refreshUI()
    local data = self.m_model:getOwnRankData()
    self:updateItemInfo(self.m_own_info_prefab, data,data.rank)
    if self.m_model.m_open_tab_index == 3 then
        self:updateRewardLoopScroll()
    else
        self:updateLoopScroll()
    end
    --self:refreshRedPoint()
    self:setOwnInfo()
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
    self:setObjectVisible("RankListNode", index == 1 or index == 2)
    self:setObjectVisible("RewardNode", index == 3)
    self:refreshUI()
end

function M:updateRewardLoopScroll()
    local data = self.m_model:getQuestsData()
    if data == nil then
        return
    end
    if self.m_reward_loop_view == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateRewardCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "look_btn" then
                    self:updateMsg("look_top_player", {index = index})
                elseif click_name == "receive_btn" then
                    self:updateMsg("receive_awards", {index = index})
                elseif click_name == "head_node" then
                    self:updateMsg("look_player", {index = index})
                end
            end
        }
        self.m_reward_loop_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_loop_view:reloadData(data, true)
    end
end

--奖励Scroll内cell的回调
function M:updateRewardCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    UIUtil.setTextByLanKey(transform, "first_title_text", "new_str_0078")
    UIUtil.setTextByLanKey(transform, "first_none_node/none_text", "new_str_0079")
    UIUtil.setTextByLanKey(transform, "name_text", data.cfg.name, data.cfg.target_value)
    UIUtil.setTextByLanKey(transform, "name_text_icon", data.cfg.name, data.cfg.target_value)
    local user = data.data.user or {}
    local value = data.data.value or 0 -- 是否完成 0 未完成 1 已完成
    local recv = data.data.recv or 0  -- 是否领奖 0 未领奖 1 已领奖
    local first_flag = _G.next(user)
    UIUtil.setObjectVisible(transform, not first_flag, "first_none_node")
    UIUtil.setObjectVisible(transform, first_flag, "first_player_node")
    if first_flag then
        local time = data.data.time or 0
        local tm = TimeUtil.gmTime(time)
        local time_str = string.format("%d-%02d-%02d %02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_name_text", "new_str_0654", tostring(user.name), time_str)
    end
    --local finish_text = UIUtil.setTextByLanKey(transform, "finish_text", "new_str_0080")
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, false, false, {show_flag = true, scale = 1})
    local finish = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", false)
    --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", false)
    local can_click = false
    local show_reward = true
    if value == 0 then
        --未完成
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "unfinished_img", true)
        can_click = true
    else
        if recv == 0 then
            --可领取
            can_click = false
        else
            --已完成
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", true)
            can_click = true
            show_reward = false
        end
    end
    local finish_eff = luaBehaviour:FindGameObject("UI_RankReward_LingQu_01")
    -- 奖励
    local drop = data.cfg.drop or {}
    local reward_node = UIUtil.findRectTransform(transform, "reward_node")
    UIUtil.destroyAllChild(reward_node)
    if show_reward == true then
        GameUtil:createRewards(reward_node, drop, true, can_click, function ()
            if value ~= 0 and recv == 0 then
                self:lockTouch()
                finish:SetActive(true)
                finish_eff:SetActive(true)
                finish.transform.localScale = Vector3(2,2,2)
                local sequence = Tweening.DOTween.Sequence()
                sequence:Append(finish.transform:DOScale(1, 0.25):SetEase(Tweening.Ease.Linear))
                sequence:OnComplete(function ()
                    finish_eff:SetActive(false)
                    self.m_control:setOnceTimer(0.15, function ()
                        self:updateMsg("receive_awards", {index = index})
                        self:unlockTouch()
                    end)
                end)
                sequence:SetAutoKill(true)
            end
        end)
        if value ~= 0 and recv == 0 then
            GameUtil:creatCommonItemEffect(reward_node, 7, 0.95)
        end
    end
end

function M:setOwnInfo()
    local data = self.m_model:getOwnRankData()
    local rank = data.rank or 0
    if rank < 1 then
        self:setTextByLanKey("own_rank_text", "new_str_0076")
    else
        self:setTextByLanKey("own_rank_text", "new_str_0381", rank)
    end
    local score = data.score or 0
    if self.m_model.m_id == 1 then--"完成章节"
        self:setTextByLanKey("score_label_text", "new_str_0133")
        self:setTextByLanKey("own_score_title_text", "new_str_0382")
        local chapter_id, stage_id, stage_item = GameUtil:getChapterIdByStageId(score)
        self:setTextByLanKey("own_score_text", tostring(stage_item.map_point_name))
    elseif self.m_model.m_id == 2 then----"爬塔进度"
    self:setTextByLanKey("score_label_text", "new_str_0384")
        self:setTextByLanKey("own_score_title_text", "new_str_0383")
        self:setTextByLanKey("own_score_text", "new_str_0083", score)
    else
        local isShowLevel = self.m_model:isLevelRank()
        local scoreName = isShowLevel and "UnionWar_str_107" or "UnionWar_str_085"
        self:setTextByLanKey("score_label_text", scoreName)
        self:setTextByLanKey("own_score_title_text", "new_str_0380")
        self:setTextByLanKey("own_score_text", tostring(score))
    end
    local user = data.user or {}
    local own_head_node = self:findGameObject("own_head_node")
    GameUtil:setUserAvatar(own_head_node, user,false,false,{show_flag = true, scale = 1})
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
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
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end

    self:setObjectVisible("CommonTipsNode", not (#data > 0))
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateItemInfo(obj, data, id)
    local user = data.user
    local rank = data.rank or 0
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
   
    if id then
        local top_three_flag = id < 4
        UIUtil.setObjectVisible(transform, top_three_flag, "top_three_rank_img")
        UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
        local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[id]
        if top_three_item then
            LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
        end
        UIUtil.setText(transform, tostring(rank), "rank_text")
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", true)
        UIUtil.setObjectVisible(transform, (id == 0), "none_rank_text")
        if id == 0 then
            UIUtil.setObjectVisible(transform, false, "top_three_rank_img")
            UIUtil.setTextByLanKey(transform, "none_rank_text", "new_str_0076")
        else
        end
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

    LuaBehaviourUtil.setImg(luaBehaviour,"race_icon", "a_ui_currency_wuxing_da", "hero_ui")
    UIUtil.setText(transform, tostring(data.score), "race_score_text")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "icon_image", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text_icon", true)
    local isShowLevel = self.m_model:isLevelRank()
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "race_icon", (not isShowLevel))

    -- cell数据
    if user ~= nil then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "name_text", true)
        UIUtil.setText(transform, tostring(user.name), "name_text")
        UIUtil.setText(transform, tostring(user.name), "name_text_icon")
        UIUtil.setTextByLanKey(transform, "level_text", "UnionWar_str_003", user.server_name or "")
        local flag_cfg = ConfigManager:getCfgByName("guild_flag")[user.flag]
        if flag_cfg then
            local union_icon_img = luaBehaviour:FindImage("icon_image")
            GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
        end      
    else
        UIUtil.setText(transform, tostring(data.name), "name_text")
        UIUtil.setText(transform, tostring(data.name), "name_text_icon")
        UIUtil.setTextByLanKey(transform, "level_text", "UnionWar_str_003", data.server_name or "")
        local flag_cfg = ConfigManager:getCfgByName("guild_flag")[data.flag]
        if flag_cfg then
            local union_icon_img = luaBehaviour:FindImage("icon_image")
            GameUtil:updateResourcesImg(union_icon_img, "Texture/union_emblem/" .. flag_cfg.icon)
        end
    end
end

function M:refreshRedPoint()
    local red_point = self.m_model:getRankRedPointById(self.m_model.m_id)
    self.m_reward_red_point_img:SetActive(red_point)
end

function M:destroy()
    M.super.destroy(self)
end

return M