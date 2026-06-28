local M = class("LuckyCharmView", LikeOO.OOPopBase)

M.m_size_type = 2
M.m_uiName = "Summer/LuckyCharm"

function M:onEnter()
    self:refreshUI()
    self:setTextByLanKey("over_text", "new_str_0793")
end

--刷新
function M:refreshUI()
    --更新列表
    self:updateLoopScroll()
    ----刷新时间
    self:updateTime()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getListData()
    --self:setObjectVisible("common_tips_node", #data == 0)
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("buy_btn", {id = index, cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local transform = cell_object.transform

    local charge_btn = UIUtil.findButton(transform, "charge_btn")
    local price = cell_data.cfg.price
    local charge_btn_show = false
    local get_btn_show = false
    --限购次数
    --local buy_num = data.time_limit - data.buy_num
    local limit_num = 1
    local times = cell_data.cfg.times_limit or 0
    if cell_data.status == 0 then --可购买
        limit_num = times - cell_data.buy_num --限购次数
        charge_btn_show = true
        get_btn_show = false
        price =  GameUtil:getMoneyTypeNum(price)
    elseif cell_data.status == -1 then --已购买完
        limit_num = 0
        charge_btn_show = false
        get_btn_show = true
        price = "gf_str_0048"

    -- local rwdRoot = UIUtil.findGameObject(luaBehaviour,"")
    -- local rwdRoot = luaBehaviour:FindGameObject("reward_node")
    -- local chdCount = rwdRoot.transform.childCount
    -- for i = 1, chdCount do
    --     -- transform
    --     -- local itemroot = rwdRoot.transform.GetChild(i - 1)
    --     -- local itemRootLuaObj = UIUtil.findLuaBehaviour(itemroot)

    -- end
    end
    local time_limit = Language:getTextByKey("summer_text_limitTime", limit_num)
    UIUtil.setTextByLanKey(transform, "PurchaseTimes_text", time_limit)

    --价格
    UIUtil.setTextByLanKey(transform, "charge_text", price)

    --奖励
    local reward = cell_data.cfg.reward or {}
    --local reward_node = UIUtil.findRectTransform(transform,"reward_node")
    local reward_node = luaBehaviour:FindGameObject("reward_node")
    GameUtil:createRewards(reward_node.transform, reward, true, true, nil, 1)

    if cell_data.status == -1 then --已购买完
        local chdCount = reward_node.transform.childCount
        for i = 0, chdCount - 1 do
            local itemroot = reward_node.transform:GetChild(i)
            local name = itemroot.name
            if name == "ItemNode(Clone)" then
                local item_lua = UIUtil.findLuaBehaviour(itemroot)
                LuaBehaviourUtil.setObjectVisible(item_lua, "duigoudi_img", true)
            end
        end
    end

    charge_btn.gameObject:SetActive(charge_btn_show)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "get_btn", get_btn_show)
end

--更新时间
function M:updateTime()
    local cur_tim = UserDataManager:getServerTime() --服务器时间
    local remain_tim = self.m_model.m_active_time.end_ts - cur_tim --剩余时间
    local remain_day, remain_hour, remain_min, remain_sec = GameUtil:getTimeLayoutBySecond(remain_tim) --换算剩余时间
    local time_text = 1
    if remain_day <= 0 and remain_hour <= 0 and remain_min <= 0 then --小于一分钟
        time_text = Language:getTextByKey("new_str_0842", remain_sec)
    elseif remain_day <= 0 and remain_hour <= 0 then --小于一小时
        time_text = Language:getTextByKey("new_str_0417", remain_min)
    elseif remain_day <= 0 then --小于一天
        time_text = Language:getTextByKey("new_str_0791", remain_hour)
    else
        time_text = Language:getTextByKey("gf_str_0016", remain_day )
    end
    self:setTextByLanKey("time_text", time_text) --重置剩余时间
end

function M:destroy()
    M.super.destroy(self)
end

return M
