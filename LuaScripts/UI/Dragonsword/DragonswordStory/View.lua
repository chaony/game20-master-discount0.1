local M = class("DragonswordStoryView",LikeOO.OOPopBase)

M.m_size_type = 1
M.m_iphoneXAdapter = true
M.m_uiName = "Dragonsword/DragonswordStory"


function M:onEnter()
    if self.m_model.m_active_data ~= nil and self.m_model.m_active_data.name ~= nil then
        self:setTextByLanKey("close_title_text",self.m_model.m_open_data.name)
    end
	self:refreshUI()
end

--刷新
function M:refreshUI()
    self:updateLevelLoopScroll()
end


--创建关卡列表
function M:updateLevelLoopScroll()
    self.m_level_click_cell_object = nil
    local data = self.m_model:getStorData()
    local all_cell_size = {}
    for i,v in ipairs(data or {}) do
        if i == self.m_model.m_current_open_day then
            all_cell_size[i] = Vector2(224, 572)
        else
            all_cell_size[i] = Vector2(84, 572)
        end
    end
    if self.m_level_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            loop_scroll_object = loopscroll,
            pos_center = true,
            all_cell_size = all_cell_size,
            update_cell = function(index,cell_object,cell_data)
                self:updateLevelScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index,cell_object,cell_data,click_object,click_name)
                if click_name == "receive_btn" then
                    self:updateMsg("receive_btn",{index = index,cell_data = cell_data})
                else
                    self:updateMsg("switch",{index = index,cell_data = cell_data})
                end
            end
        }
        self.m_level_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_level_loop_scroll_view:reloadData(data,true,all_cell_size)
    end
end

--设置关卡数据
function M:updateLevelScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform
    local rectTransform = cell_object.gameObject:GetComponent("RectTransform")
    
    --设置异闻内容展示
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "story_name_text_1", cell_data.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "story_name_text_2", cell_data.name)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "story_content_text", cell_data.story)
    local reward = cell_data.reward or {}
    local reward_node = luaBehaviour:FindGameObject("reward_Content")
    GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)

    --详情展示
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_name_panel", index ~= self.m_model.m_current_open_day)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "story_content_panel", index == self.m_model.m_current_open_day)

    --设置解锁天数
    local lock_text_isshow = false
    if index > self.m_model.m_current_start_day then
        lock_text_isshow = true
        local lock_time = GameUtil:numberToChineseString(index - self.m_model.m_current_start_day) -- 数字转大写
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "unlock_time_text", Language:getTextByKey("dragonsword_text_0003",lock_time))
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"unlock_time_text",lock_text_isshow)
    
    local is_receive_reward = self.m_model:getRewardIsReceive(index) --奖励是否领取
    --已阅读  已领取展示已阅读，未领取不展示已阅读
    local read_img_isshow = false
    if is_receive_reward then
        read_img_isshow = true
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"read_img",read_img_isshow) --已阅读文字显示状态
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"receive_btn",not is_receive_reward) --领取按钮显示状态
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"receive_img_bg",is_receive_reward) --已领取文字展示状态
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"story_red_point",not read_img_isshow and not lock_text_isshow) --红点显示（合起）
    LuaBehaviourUtil.setObjectVisible(luaBehaviour,"unlock_story_red_point",not read_img_isshow and not lock_text_isshow) --红点显示（展开）
end

function M:destroy()
    M.super.destroy(self)
end

return M