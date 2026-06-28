local M = class("YinTowerRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "YinTower/YinTowerRewardPop"
M.m_size_type = 2

function M:onEnter()
    --提高vip等级可提高额外扫荡次数
    self:setTextByLanKey("tips","new_str_0769")
    --剩余次数:<Color=#FFECAE>%d</Color>次
    self:setTextByLanKey("remain_time_text","new_str_0758",self.m_model:getFreeTime())

    self:setTextByLanKey("mopping_btn_text","new_str_0573")
    
    --置灰的图
    self.gruy_img = self:findImage("gruy_img");
    self.mopping_btn = self:findImage("mopping_btn")
    --
    self:setObjectVisible("tips", false);
    --刷新UI
    self:refreshUI();
end


--[[
	创建列表
]]
function M:updateRewardLoopScroll()
    local data = self.m_model:getAllGifts()
    if self.m_reward_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("reward_loopscroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = loopscroll,
            pos_center = true,
            update_cell = function(index, cell_object, cell_data)
                local isFristReward = self.m_model:isFristReward(cell_data)
                cell_data.isFristReward = isFristReward;
                GameUtil:updateItemElement(cell_object, cell_data, true, true)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_reward_loop_scroll_view:reloadData(data)
    end
end


--刷新UI 
function M:refreshUI()
    self:updateBoxStatus()
    self:updateRewardLoopScroll();
    --five_element_sweep = "/api?method=five_element.sweep", --五行阵扫荡
    --获取免费领取次数
    --免费次数
    local free_times = self.m_model:getFreeTime();
    --还有免费次数
    if free_times > 0 then
        self:setTextByLanKey("remain_time_text","new_str_0758",free_times)
        self:setObjectVisible("cost", false);
        self.mopping_btn.material = nil;
    else
        --额外购买次数
        local buy_time = self.m_model:getBuyTime();
        if buy_time > 0 then
            self.mopping_btn.material = nil;
            self:setObjectVisible("cost", true);
            self:setObjectVisible("remain_time_text", false);
            --获取消耗数据
            local cost_data = self.m_model:getCostData( self.m_model.m_open_times + 1 );
            --获取消耗货币种类
            local data = RewardUtil:getProcessRewardData( cost_data )
            local img = self:findGameObject("costicon");
            UIUtil.setImg(img,data.icon_name,data.atlas_name)
            self:setText("cost_num_text", data.data_num);
        else
            self:setObjectVisible("cost", false);
            self.mopping_btn.material = self.gruy_img.material;
            self:setObjectVisible("remain_time_text", true);
            --今日次数已用尽
            self:setTextByLanKey("remain_time_text","new_str_0773")
            self:setObjectVisible("tips", true);
        end
    end
end

function M:updateBoxStatus()
    local reward_status = 2
    local gift_btn = self:findGameObject("gift_btn")
    local box_trans = gift_btn.transform
    UIUtil.destroyAllChild(box_trans)
    local width = self.m_box_node_rt.rect.width
    local task_box = GameUtil:createPrefab("Task/TaskBox", box_trans)
    local transform = task_box.transform
    local box_effect = UIUtil.findRectTransform(transform, "UI_Task_BaoXiang_001")
    if reward_status == 0 then
        self:setImg("a_gj_guajijiangli_1", "main_ui", "gift_btn")
    elseif reward_status == 2 then
        self:setImg("a_gj_guajijiangli_1", "main_ui", "gift_btn")
    elseif reward_status == -1 then
        self:setImg("a_gj_guajijiangli_3", "main_ui", "gift_btn")
    end
    box_effect.gameObject:SetActive(false)
    if reward_status == 2 then
        self.m_control:setOnceTimer(0.1, function()
            if not IsNull(task_box) then
                luaBehaviour:RunAnim("UI_TaskBox_BaoXiang_001", nil , 1)
            end
        end)
        box_effect.gameObject:SetActive(true)
    end
end


function M:destroy()
    M.super.destroy(self)
end

return M