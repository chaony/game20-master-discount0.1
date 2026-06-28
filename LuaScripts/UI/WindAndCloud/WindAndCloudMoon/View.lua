---@class DeliciousFeastRankView: OOPopBase
local M = class("WindAndCloudMoonView", LikeOO.OOPopBase)

M.m_uiName = "WindAndCloud/WindAndCloudMoon"
M.m_size_type = 1
M.m_iphoneXAdapter = true

function M:onEnter()
    self:updateActivityTimer()
    RedPointUtil:saveLocalRedPointFreshTime("WindAndCloudMoon")
    self.avtive_data = self.m_model:getActiveCfg()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self.is_refresh = 0
    self:setTog()
    self:refreshRightNode()
    self:refreshUI()
end

function M:refreshUI()
    self:bindUI()
    self:refreshLeftNode()
    self:refreshList()
    self:refreshMyInfoNode()
end

--刷新活动时间
function M:updateActivityTimer()
    local surplus_time = 0
    local activityData = self.m_model.m_active_data
    local endTimer = activityData.end_ts
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    if endTimer ~= nil then
        surplus_time = endTimer - cur_tim
    end
    if surplus_time < 0 and self.is_refresh == 0 then
        if self.m_model.active_over and self.m_model.active_over == 1 then
           self:updateMsg(99999)
        else
            self:updateMsg("refresh_data")
            self.is_refresh = 1
        end
    else
        local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(surplus_time) --换算剩余时间
        local show_time = ""
        if remain_day > 0 then
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0013",remain_day,remain_hour,remain_min)
        else
            show_time = Language:getTextByKey("three_heroes_five_gallants_text_0014",remain_hour,remain_min,remain_sec)
        end
        self:setTextByLanKey("title_txt_2", show_time) --重置剩余时间
    end
end

--刷新排行榜list
function M:refreshList()
    local data = self.m_model:showFourListData()
    if self.m_roleScroll_view == nil then
        local loopscroll = self:findGameObject("top_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:refreshItem(cell_obj, cell_data, index)
            end,
            ui_name = self.m_uiName,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            pull_refresh = function() -- 下拉刷新
                --self.last_offsety1 = self.m_loop_scroll_view1.m_scroll_rect.viewport.rect.height - self.m_loop_scroll_view1.m_scroll_rect.content.rect.height
                self:updateMsg("load_rank")
            end,
        }
        self.m_roleScroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_roleScroll_view:reloadData(data, true)
    end
end

--刷新活动数据显示
function M:refreshItem(cell_obj, cell_data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        LuaBehaviourUtil.setText(luaBehaviour, "index_text", cell_data.rank )
        local userInfo = cell_data.user
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", userInfo.name )
        LuaBehaviourUtil.setText(luaBehaviour, "score_text", cell_data.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        GameUtil:setUserAvatar(head_node, userInfo,false,false,false)
    end
end

--设置tog选中颜色
function M:refreshRightNode()
    for i, v in ipairs(self.tog_table) do
        if v.id == self.m_model.current_show_tab_num then --选中
            v.tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_25
            self:setObjectVisible("tog_Checkmark_"..i,true)
        else
            v.tog_text.color = GlobalConfig.COMMON_COLLOR.COMMON_27
            self:setObjectVisible("tog_Checkmark_"..i,false)
        end
    end
end

--设置tog页签显示
function M:setTog()
    self.tog_table = {}
    for i = 1, 3 do
        local num_to_string = GameUtil:numberToChineseString(i) -- 数字转大写
        local tog_text = self:setTextByLanKey("tog_"..i.."_text","wind_clouds_text_0006",num_to_string)
        local btn = self:findButton("tog_"..i)
        UIUtil.setButtonClick(
                btn,
                function()
                    self:updateMsg("check_tag", i + (self.m_model.periods_num - 1)*3)
                end
        )
        table.insert(self.tog_table,{id = i + (self.m_model.periods_num - 1)*3,tog_text = tog_text})
    end
end

--显示我的排名
function M:refreshMyInfoNode()
    local cell_obj = self:findGameObject("myInfoNode")
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_obj)
    if luaBehaviour then
        local myInfoData = self.m_model.myInfoData
        local rankIndex = myInfoData.rank > 0 and myInfoData.rank or Language:getTextByKey("new_str_0076")
        LuaBehaviourUtil.setText(luaBehaviour, "index_text", rankIndex )
        local name = UserDataManager.user_data:getUserStatusDataByKey("name")
        LuaBehaviourUtil.setText(luaBehaviour, "text_name", name )
        LuaBehaviourUtil.setText(luaBehaviour, "score_text", myInfoData.score )
        local head_node = luaBehaviour:FindGameObject("head_node")
        local avatar = UserDataManager.user_data:getUserStatusDataByKey("avatar")
        local frame = UserDataManager.user_data:getUserStatusDataByKey("frame")
        GameUtil:setUserAvatar(head_node, {avatar = avatar, frame = frame}, false)
    end
end

--前三名数据显示
function M:refreshLeftNode()
    local allRoleData = self.m_model.roleRankData
    for index = 1, 3 do
        local itemData = allRoleData[index]
        local roleNode = self:findGameObject("rank_"..index)
        local isExistRole = itemData ~= nil
        roleNode:SetActive(isExistRole)
        if isExistRole then
            local luaBehaviour = UIUtil.findLuaBehaviour(roleNode)
            if luaBehaviour then
                local userInfo = itemData.user
                LuaBehaviourUtil.setText(luaBehaviour, "player_name_txt"..index,  userInfo.name) 
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_name_txt"..index, userInfo.server_name)
                local score_text = Language:getTextByKey("new_str_0222",itemData.score)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_name_txt"..index, score_text)
                --设置头像
                local head_node = luaBehaviour:FindGameObject("head_node"..index)
                GameUtil:setUserAvatar(head_node, {avatar = userInfo.avatar, frame = userInfo.frame}, false)
                --设置奖励
                local rank_info_table = self.m_model:getRewardInfo(index)
                local reward_table = {}
                if rank_info_table then
                    reward_table = rank_info_table.rank_reward
                end
                local reward_node = luaBehaviour:FindGameObject("reward_node")
                GameUtil:createRewards(reward_node.transform, reward_table, true, true)
            end
        end
    end
end

--设置本地化
function M:bindUI()
    self:setTextByLanKey("title_txt_1", "wind_clouds_text_0004")
    self:setTextByLanKey("peak_game_btn_text", "wind_clouds_text_0005")
    self:setTextByLanKey("reward_text", "new_str_0373")
    self:setTextByLanKey("scroll_title_text1", "new_str_0235")
    self:setTextByLanKey("scroll_title_text2", "fylt_str_0027")
    self:setTextByLanKey("scroll_title_text3", "family_dinner_text004")
    self:setTextByLanKey("activ_over_txt", "gf_str_0085")
    self:setObjectVisible("activ_over_txt",false)
end

function M:destroy()
    M.super.destroy(self)
end

return M
