local M = class("HuntTreasuresGuildMyTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasuresGuild/HuntTreasuresGuildTeamPop"
M.m_size_type = 2
function M:onEnter()
    self.m_model:updateRewardStatus()
    self.m_cell_tab = {}
    self:setTextByLanKey("title_tips_text", "hunt_treasure_guild_str_001")
    self:setTextByLanKey("wanguo_text", "hunt_treasure_guild_str_002")
    self:setTextByLanKey("zhanbao_text", "hunt_treasure_guild_str_003")
    self:setTextByLanKey("bangdan_text", "hunt_treasure_guild_str_004")
    
    UserDataManager:removeRedDotByKey("active_mining_team")
    UserDataManager:removeRedDotByKey("active_mining_blog")
    self.m_model.m_first_enter = false
    self.m_scroll_view_tab = {}
    self:setTextByLanKey("time_text", "")
    self:refreshUI()
end

function M:refreshUI()
    self:updateTeamInfo()
    self:updateLeftInfo()
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    local log_flag = UserDataManager:getRedDotByKey("active_mining_blog") --有新战报
    self:setObjectVisible("log_red_point_img", log_flag == 1)
end

-- 刷新排行第一名
function M:updateLeftInfo()
    local left_user = self.m_model:getTopUserInfo()
    if _G.next(left_user) then
        ----加载spine动画
        local hero = self:findGameObject("rank_spine_1")
        local cfg = ConfigManager:getPlayerPictureCfg(left_user.avatar);
        local spine_name = cfg.hero_spine;
        GameUtil:updateSpineLoadSet(hero, "RoleSpine/" .. spine_name, "idle", 0, true)
        local head_title_img = self:findGameObject("head_title_img")
        local title_id = left_user.title
        if title_id and title_id ~= 0 then
            head_title_img:SetActive(true)
            GameUtil:setTitleImage(title_id,head_title_img)
        else
            head_title_img:SetActive(false)
        end
        
        local server_name = ""
        if tonumber(left_user.server) == 0 then
            server_name = UserDataManager.server_data:getServerName()
        else
            server_name = UserDataManager.server_data:getServerNameById(left_user.server)
        end
        server_name = "[" .. server_name .. "] "
        self:setTextByLanKey("left_text1", tostring(server_name)..tostring(left_user.name))
        self:setTextByLanKey("left_text2", Language:getTextByKey("hunt_treasure_guild_str_007",tostring(left_user.guild_name)))
        self:setObjectVisible("player_mask", true)
        self:setObjectVisible("none_obj", false)
    else
        self:setObjectVisible("left_node1", false)
        self:setObjectVisible("left_node2", false)
        self:setObjectVisible("player_mask", false)
        self:setObjectVisible("none_obj", true)
    end
end

local __open_id = {182, 183}
function M:updateTeamInfo()
    for index = 1, 2 do
        local cell_object = self:findGameObject("cell_" .. index)
        local transform = cell_object.transform
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        local start_time = self.m_model:getRewardReceiveTime(index)
        local occ_time = UserDataManager:getServerTime() - start_time
        if not (self.m_cell_tab[index]) then
            self.m_cell_tab[index] = luaBehaviour
        end
        local edit_status = self.m_model.m_edit_status
        LuaBehaviourUtil.setText(luaBehaviour, "occ_time_text", "")
        LuaBehaviourUtil.setText(luaBehaviour, "occ_time_value_text", "")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "upper_num_str_000" .. index)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "formation_edit_btn_text", "new_str_0289")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "recall_btn_text",  "hunt_treasure_str_006")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "go_to_btn2_text",  "new_str_0970")
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(__open_id[index])
        local oid = self.m_model:getMineOid(index)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_mine_text", oid == 0 or occ_time <= 60)
        local drop_reward = self.m_model:getDropReward(index)
        local have_reweard = drop_reward and next(drop_reward)
        if not(open_flag) then
            LuaBehaviourUtil.setText(luaBehaviour, "no_mine_text",  tips_str)
        elseif have_reweard then
            LuaBehaviourUtil.setText(luaBehaviour, "no_mine_text",  "")
        elseif oid == 0 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_mine_text",  "hunt_treasure_str_044")
        elseif occ_time < 60 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "no_mine_text",  "hunt_treasure_str_045")
        else
            LuaBehaviourUtil.setText(luaBehaviour, "no_mine_text",  "")
        end
        self:setBtnClick(luaBehaviour, "reward_btn", {index = index} )
        self:setBtnClick(luaBehaviour, "go_to_btn", {oid = oid} )
        self:setBtnClick(luaBehaviour, "go_to_btn2", {index = index} )
        self:setBtnClick(luaBehaviour, "recall_btn", {index = index} )
        
        local race_id_tab = self.m_model:getRegionCfgValueById(index, "race")
        LuaBehaviourUtil.setImg(luaBehaviour, "area_img", GlobalConfig.ACTIVE_MINING_RACE_ICON[race_id_tab[1]].name, ResourceUtil:getLanAtlas())
        luaBehaviour:FindImage("area_img"):SetNativeSize()
    
        local mine_name = self.m_model:getMineName(index)
        luaBehaviour:FindText("cell_title_text").text = Language:getTextByKey(mine_name)
       
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "recall_btn",  start_time > 0 and not(self.m_model.m_reward_status[index]))
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "go_to_btn2",  oid == 0 and not(have_reweard))
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_bg_img", self.m_model.m_reward_status[index])
       
        local scroll_view = luaBehaviour:FindGameObject("loopscroll")
        self:updateLoopScroll(scroll_view, index, occ_time)
    end
end

function M:setBtnClick(cur_luaBehaviour, btn_name, params)
    local btn = cur_luaBehaviour:FindButton(btn_name)
    if btn then
        btn.enabled = true
        local function clickCallback()
            self:updateMsg(btn_name,params )
        end
        UIUtil.setButtonClick(btn.transform,clickCallback)
    end
end

function M:dealRewardData(data, ower_time, produce_add)
    ower_time = math.min(self.m_model.m_max_owner_time * 60 * 60, ower_time)
    ower_time = math.floor(ower_time / 60) 
    local final_rewards_tab = {}
    for i = 1, #data do
        local reward_data = RewardUtil:getProcessRewardData(data[i])
        local final_num = math.round(reward_data.data_num * ower_time * produce_add)
        if final_num >= 1 then
            reward_data.data_num = final_num
            final_rewards_tab[#final_rewards_tab + 1] = reward_data
        end
    end
    return final_rewards_tab
end

--[[
	创建列表
]]
function M:updateLoopScroll(loopscroll, team_id, occ_time)
    self.m_sel_cell_index = nil
    local oid = self.m_model:getMineOid(team_id)
    local final_rewards_tab = self.m_model:getDropReward(team_id) -- self:dealRewardData(data, occ_time, produce_add)
    if next(final_rewards_tab) then
        loopscroll:SetActive(true)
        --local data, produce_add = self.m_model:getCurRegionDrop(team_id, oid)
        if self.m_scroll_view_tab[team_id] == nil then
            local loopscroll = loopscroll
            local params = {
                show_data = final_rewards_tab,
                loop_scroll_object = loopscroll,
                update_cell = function(index, cell_object, cell_data)
                    self:updateScrollViewCell(index, cell_object, cell_data)
                end,
                click_func = function(index, cell_object, cell_data, click_object, click_name)
                    self:updateMsg(click_name, {index = index , cell_data = cell_data})
                end
            }
            self.m_scroll_view_tab[team_id] = LoopScrollViewUtil.new(params)
        else
            self.m_scroll_view_tab[team_id]:reloadData(final_rewards_tab, true)
        end
    else
        if oid > 0 then
            
        end
        loopscroll:SetActive(false)
    end
end

function M:updateTime()
    for i = 1, 2 do
        local obj = self.m_cell_tab[i]
        local start_time = self.m_model:getRewardReceiveTime(i)
        local occ_time = UserDataManager:getServerTime() - start_time
        if occ_time > 0 and start_time > 0 then
            LuaBehaviourUtil.setText(obj, "occ_time_text", Language:getTextByKey("hunt_treasure_str_008"))
            occ_time = math.min(self.m_model.m_max_owner_time, occ_time)
            local tim = GameUtil:formatTimeBySecond(occ_time, 999)
            LuaBehaviourUtil.setText(obj, "occ_time_value_text", tim)
        else
            LuaBehaviourUtil.setText(obj, "occ_time_text", "")
            LuaBehaviourUtil.setText(obj, "occ_time_value_text",  "")
        end
    end
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts)
        text = Language:getTextByKey("new_str_0919") .. text
        self:setTextByLanKey("time_text", text)
    else
        self:setTextByLanKey("time_text", "new_str_0558")
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    if data then
        local reward_data = RewardUtil:getProcessRewardData(data)
        local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
        ui_element.red_point_img:SetActive(false)
        local item_type = 0
        if reward_data and reward_data.item_cfg and reward_data.item_cfg.type then
            item_type = reward_data.item_cfg.type
        end
        if GameUtil:checkDoubleActiveByType(4) == true and item_type == 18 then --好感度道具双倍
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", true)
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour,"double_earn", false)
        end
    else
        --local ui_element = GameUtil:updateItemElementByData(cell_object)
        --ui_element.red_point_img:SetActive(false)
    end
   
end
-- 刷新第一名展示
function M:updatePlayerInfo(index)
    index = 1
    local player_data = self.m_model:getPlayerData(index)
    local rank_obj = self:findGameObject("rank_"..index)
    local luaBehaviour = UIUtil.findLuaBehaviour(rank_obj)
    if luaBehaviour then
        if next(player_data) ~= nil then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", true)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", false)
            local rank_spine = luaBehaviour:FindGameObject("rank_spine_"..index)
            self:setSpine(rank_spine, player_data.user.avatar)
            local head_title_img = luaBehaviour:FindGameObject("head_title_img")
            local title_id = player_data.user.title
            if title_id and title_id ~= 0 then
                head_title_img:SetActive(true)
                self:setTitleImage(title_id,head_title_img)
            else
                head_title_img:SetActive(false)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "player_mask", false)
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_obj", true)
        end
    end
end

function M:setSpine(play_img, hero_id)
    local cfg = ConfigManager:getPlayerPictureCfg(tonumber(hero_id))
    local spine =  "hero_0101_SkeletonData"
    if cfg and next(cfg) ~= nil then
        spine = cfg.hero_spine
    else
        local cur_skin_cfg = ConfigManager:getHeroSkinCfg(hero_id)
        if cur_skin_cfg and next(cur_skin_cfg) ~= nil then
            spine = cur_skin_cfg.hero_spine
        end
    end
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" ..spine, "idle", 0, true)
end

-- 设置称号图片
function M:setTitleImage(title_id, titleObj)
    if title_id and title_id ~= 0 then
        titleObj:SetActive(true)
        local name_img = titleObj:GetComponent("Image")
        local cfg = UserDataManager.title_data:getTitleConfigById(title_id)
        UIUtil.destroyAllChild(name_img.gameObject.transform)
        if cfg.title_effect and cfg.title_effect ~= "" then
            ResourceUtil:GetUIEffectItem("Headtitle/" .. cfg.title_effect, name_img.gameObject)
            name_img.enabled = false
        else
            GameUtil:setTextureLoadTitleLanImgText(titleObj, cfg.icon) -- 设置称号图片
            name_img:SetNativeSize()
            name_img.enabled = true
        end
    else
        titleObj:SetActive(false)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M