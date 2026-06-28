local M = class("HuntTreasuresGuildLogPopView",LikeOO.OOPopBase)

M.m_uiName = "HuntTreasuresGuild/HuntTreasuresGuildLogPop"
M.m_size_type = 2

function M:onEnter()
    self.m_scroll_tab = {}
    self:refreshUI()
    UIUtil:registerDragEvent(self.m_ui_obj, handler(self,self.fingerSliding))
    self:setTextByLanKey("common_title_text", "hunt_treasure_str_024")
    UserDataManager:removeRedDotByKey("active_mining_blog")
end

function M:destroy()
    M.super.destroy(self)
end

function M:refreshUI()
    self:updateLoopScroll()
    self:refreshRedPoint()
    --common_tips_node
    self:setObjectVisible("common_tips_node", #self.m_model.m_battle_log == 0)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model.m_battle_log
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index})
            end,
            ui_name = self.m_uiName
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateItemInfo(obj, data, id)
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    
    local HeadNode = luaBehaviour:FindGameObject("HeadNode")
    GameUtil:setUserAvatar(HeadNode, data.user, nil, nil, {show_flag = true, scale = 1})
    local attack_name, def_name = ""
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "lost_text", "hunt_treasure_str_033")
    local is_win = 0
    if data.attack == 1 then
        attack_name =  Language:getTextByKey("hunt_treasure_str_025")
        def_name =  data.user.name
        is_win = data.win
    else
        attack_name = data.user.name 
        def_name = Language:getTextByKey("hunt_treasure_str_025")
        is_win = data.win == 1 and 0 or 1
    end
    local mine_name = self.m_model:getMineName(id)
    mine_name = Language:getTextByKey(mine_name)
    local desc_id = "hunt_treasure_str_021"
    if data.win == 0 then
        desc_id = "hunt_treasure_str_022"
    end
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text",is_win == 0 and "hunt_treasure_str_022" or "hunt_treasure_str_021",
            attack_name, def_name, mine_name)
    local tim = GameUtil:formatTimeBySecond2(UserDataManager:getServerTime() - data.ts)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "log_time_text", "hunt_treasure_str_026", tim)
    
    local rob_loopscroll = luaBehaviour:FindGameObject("rob_loopscroll")
    self:updateRobLoopScroll(rob_loopscroll, data.gift)
    local have_gift_num = #(data.gift)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lost_text", have_gift_num > 0)
end

function M:updateRobLoopScroll(rob_loopscroll, data)
    self.m_cell_tab = {}
    local data = data or {}
    local new_index = nil
    if self.m_scroll_tab[rob_loopscroll] == nil then
        local rob_loopscroll = rob_loopscroll
        local params = {
            show_data = data,
            loop_scroll_object = rob_loopscroll,
            update_cell = function(index, cell_object, cell_data)
                local data = cell_data
                local reward_data = RewardUtil:getProcessRewardData(data)
                local ui_element = GameUtil:updateItemElementByData(cell_object, reward_data, true, true)
                ui_element.red_point_img:SetActive(false)
                local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end,
            ui_name = self.m_uiName
        }
        self.m_scroll_tab[rob_loopscroll] = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_tab[rob_loopscroll]:reloadData(data)
    end
end

function M:refreshRedPoint()
end

function M:fingerSliding(locat)
    if locat then
        self:updateMsg("sliding_right")
    else
        self:updateMsg("sliding_left")
    end
end

return M