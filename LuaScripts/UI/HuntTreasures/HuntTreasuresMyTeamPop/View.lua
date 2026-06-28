local M = class("HuntTreasuresMyTeamPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasures/HuntTreasuresMyTeamPop"
M.m_size_type = 2
function M:onEnter()
    self.m_model:updateRewardStatus()
    self.m_cell_tab = {}
    UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
    self:setText("common_title_text", Language:getTextByKey("hunt_treasure_str_010"))
    self:setText("formation_btn_text", Language:getTextByKey("hunt_treasure_str_009"))
    self:setText("sign_btn_text", Language:getTextByKey("hunt_treasure_str_039"))
    self:setTextByLanKey("battle_log_btn_text", "hunt_treasure_str_024")
    self:setTextByLanKey("my_area_btn_text", "hunt_treasure_str_010")
    UserDataManager:removeRedDotByKey("mining_team")
    UserDataManager:removeRedDotByKey("mining_reward")
    self.m_active_point_slider = self:findSlider("active_point_slider")
    self.m_box_node = self:findGameObject("box_node")
    self.m_box_node_rt = UIUtil.findRectTransform(self.m_box_node)
    self.m_model.m_first_enter = false
    self.m_scroll_view_tab = {}
    self:refreshUI()
    self.m_cur_cd = 0
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    self:updateTeamInfo()
    self:refreshProgressBar()
end

local __open_id = {182, 183, 184, 185}
function M:updateTeamInfo()
    for index = 1, 4 do
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
        LuaBehaviourUtil.setImg(luaBehaviour, "area_img", GlobalConfig.MINING_RACE_ICON[race_id_tab[1]].name, ResourceUtil:getLanAtlas())
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
    for i = 1, 4 do
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

function M:refreshProgressBar()
    self:setTextByLanKey("score_title_text", "new_str_0653") 
    self:setTextByLanKey("score_text", tostring(math.floor(self.m_model.m_occupy_time / 60 / 60) )) 
    self.m_active_point_slider.value = self.m_model:getBarProgress()
    local show_data, show_reward = self.m_model:getBoxShowData()
    local max_score = show_data[#show_data]
    local box_trans = self.m_box_node.transform
    UIUtil.destroyAllChild(box_trans)
    local width = self.m_box_node_rt.rect.width
    for i=1,#show_data do
        local data = {}--show_reward[i]
        data.status = self.m_model:getBoxStatusByIndex(i)
        local cfg_score = show_data[i]
        local task_box = GameUtil:createPrefab("Task/TaskBox", box_trans)
        local transform = task_box.transform
        local luaBehaviour = UIUtil.findLuaBehaviour(transform)
        UIUtil.setLocalPosition(task_box, width*cfg_score/max_score - width*0.5, 0)
        local function btns(trans,params)
            if data.status == 2 then -- 可领取
                self:updateMsg("box_reward", {click_transform = trans, data = cfg_score})
            else
                self:updateMsg("box_click", {click_transform = trans, data = show_reward[i]})
            end
        end
        UIUtil.setButtonClick(transform, btns, i)
        local score_text = UIUtil.setText(transform, Language:getTextByKey("new_str_0416", cfg_score), "score_text")
        local finish_text = UIUtil.setTextByLanKey(transform,"finish_text", "new_str_0080")
        score_text.color = data.status == 0 and GlobalConfig.COMMON_COLLOR.COMMON_25 or GlobalConfig.COMMON_COLLOR.COMMON_24
        local box_effect = UIUtil.findRectTransform(transform, "UI_Task_BaoXiang_001")
        UIUtil.setObjectVisible(transform, false, "score_text_bg")
        local box_img = nil
        if data.status == 0 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == 2 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_weikai", "main_ui", "box_img")
        elseif data.status == -1 then
            box_img = UIUtil.setImg(transform, "a_rw_xiangzi_kai", "main_ui", "box_img")
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "line_img", i ~= box_num)
        box_effect.gameObject:SetActive(false)
        if data.status == 2 then
            self.m_control:setOnceTimer(0.1, function()
                if not IsNull(task_box) then
                    luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
                end
            end)
            box_effect.gameObject:SetActive(true)
        end
    end
end

return M