local M = class("GifEatExchangeNode", LikeOO.OOUIbase)
--神飨兑换
M.m_uiName = "GiftBag/GifEatExchangeNode"

function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self.end_ts = 0
    self.id = 0
    self:setTextByLanKey("jump_text","qianwang_guaji_text")
    self.m_version = 1
    self:showUI(false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
        if callback then
            callback(data)
        end
        if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI(id)
    self.active_id = id
    self:refreshUI()
end

function M:refreshUI()
    if self.m_model.m_eat_exchange_data == nil or next(self.m_model.m_eat_exchange_data) == nil or self.active_id == nil then
        return
    end
    self:showUI(true)
    local active_tab = ConfigManager:getCfgByName("active")
    for k,v in pairs(self.m_model.m_eat_exchange_data.actives) do
        if v.open_status > 0 and v.id == self.active_id then
            self.end_ts = v.end_ts
            self.id = v.id
        end
    end
    local active_cfg = active_tab[self.id]
    if active_cfg == nil then
        return
    end
    if self.m_model.m_eat_exchange_data.exchange and self.m_model.m_eat_exchange_data.exchange.version then
        self.m_version = self.m_model.m_eat_exchange_data.exchange.version
    else
        self.m_version = active_cfg.version
    end

    local vsn_dot = UserDataManager.red_dot["eat_exchange"] or {}
    if vsn_dot and vsn_dot.eat_vsn then
        for k,v in pairs(vsn_dot.eat_vsn) do
            if v == self.m_version then
                table.remove( vsn_dot.eat_vsn, k)
                break
            end
        end
        if next(vsn_dot.eat_vsn) == nil then
            UserDataManager:removeRedDotByKey("eat_exchange")
            if self.m_control.m_view.createLoopScroll then
                self.m_control.m_view:createLoopScroll()
            end
        end
    end

    self.pop_name = Language:getTextByKey(active_cfg.name)
    self.exchange_cfg = self.m_model:get_eat_exchange_cfg(self.m_version)
    self:setTextByLanKey("title_text", active_cfg.name_2)
    self:updateTime()
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    local data = self.m_model:get_eat_exchange_limit_cfg(self.m_version)
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if UserDataManager:getServerTime() > self.end_ts then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0558"), delay_close = 2})
                    return
                end
                local need_can_nums ={} --道具可兑换的次数列表
                local satisfy_bl = false --满足要求
                for k,v in pairs(cell_data.need_reward) do
                    local need_data = RewardUtil:getProcessRewardData(v)
                    table.insert(need_can_nums, math.floor(need_data.user_num/need_data.data_num))
                    if need_data.data_num > need_data.user_num then--道具不足 
                        satisfy_bl = true --不满足要求
                    end
                end
                local out_data = RewardUtil:getProcessRewardData(cell_data.out_reward[1]) --奖励
                local data = self.m_model:getEatExchangeData(self.m_version, cell_data.id)
                local num = cell_data.times - data
                local can_num = 0 --道具可兑换的次数
                if cell_data.times > 0 and num <= 0 then
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0761"), delay_close = 2})
                    return
                end
                if satisfy_bl == true then--道具不足
                    GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("compass_str_002"), delay_close = 2})
                    return
                end
                table.sort(need_can_nums, function(a, b) return a < b end)
                local can_num = math.min(need_can_nums[1] or 1, num)
                if cell_data.times > 1 then
                    local params = {
                        item_msg = out_data.name;
                        m_max_buyNum = can_num;
                        clickBuy = function (m_times)
                            self:updateMsg("eat_exchange",{id = cell_data.id,times = m_times ,version = self.m_version})
                        end
                    }
                    self:openView("Pops.CommonExchangePop", params)
                else
                    self:updateMsg("eat_exchange",{id = cell_data.id,times = 1 ,version = self.m_version})
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data, true)
    end
end

function M:updateRewardItem(obj, cfg)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local left_node = LuaBehaviour:FindGameObject("left_node") 
        local right_node = LuaBehaviour:FindGameObject("right_node")
        local reward_btn = LuaBehaviour:FindImage("reward_btn")
        local data = self.m_model:getEatExchangeData(self.m_version, cfg.id)
        local can_change = true
        local num = cfg.times - data
        self:createRewards(left_node.transform, cfg.need_reward, true)
        self:createRewards(right_node.transform, cfg.out_reward, false)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
        if cfg.times == 0 then
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("gf_str_0105"))
        else
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "limit_times", Language:getTextByKey("union_str_0014")..num)
        end
        for k,v in ipairs(cfg.need_reward) do
            local need_data = RewardUtil:getProcessRewardData(v)
            if need_data.data_num > need_data.user_num then--道具不足
                can_change = false
            else
                if cfg.times > 0 and num <= 0 then
                    can_change = false
                end
            end
        end
        if can_change == false then
            reward_btn.material = self.m_gray_img.material
        else
            reward_btn.material = nil
        end
        if cfg.times > 0 and num <= 0 then
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", true)
        else
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "maxk_img", false)
        end
    end
end

function M:createRewards(reward_node, rewards, show_bl)
    UIUtil.destroyAllChild(reward_node)
    for k, v in pairs(rewards) do
        local item = GameUtil:createItemElement(v,true, true)
        item.transform:SetParent(reward_node, false)
        local LuaBehaviour = UIUtil.findLuaBehaviour(item)
        local data = RewardUtil:getProcessRewardData(v)
        local num_text = LuaBehaviour:FindText("count_text")
        if show_bl == true then
            if data.data_num > data.user_num then
                num_text.text = "<color=#F33535>".. data.user_num.."</color>/<color=#FFFFFF>"..data.data_num.."</color>"
            else
                num_text.text = "<color=#FFFFFF>".. data.user_num.."/"..data.data_num.."</color>"
            end
        end
    end
end


function M:updateTime()
	if self.end_ts and self.end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.end_ts - UserDataManager:getServerTime())
		self:setTextByLanKey("down_time", "activities_str_0012", time_show)
	end
    self:updateActiveEndTs()
end

--用于当前界面活动结束刷新
function M:updateActiveEndTs()
    if self.end_ts and self.end_ts > 0 then
        if UserDataManager:getServerTime() > self.end_ts then
            self.end_ts = 0
        end
    end
end

function M:onButtonClick(obj, name)
    if name == "hint_btn" then
        local params = {}
        params.title = self.pop_name
        params.content = Language:getTextByKey(self.exchange_cfg.des)
        self.m_control:openView("Pops.CommonHelpPop", params)
    elseif name == "jump_btn" then
        self:updateMsg("go_to", {30})
    elseif name == "reward_btn" then
        self:openView("GiftBag.GiftBagScrollShopPop",{showType = 2})
    else
        self:updateMsg(name)
    end
end

function M:showUI(bl)
    self:setObjectVisible("down_time", bl)
	self:setObjectVisible("title_text", bl)
	self:setObjectVisible("jump_btn", false)
    self:setObjectVisible("hint_btn", bl)
end

function M:destroy()
    M.super.destroy(self)
end

return M
