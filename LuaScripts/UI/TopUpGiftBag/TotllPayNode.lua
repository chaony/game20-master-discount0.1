local M = class("TotllPayNode", LikeOO.OOUIbase)
--连续充值
M.m_uiName = "OperateActivity/TotllPayNode"

function M:onEnter()
    local re_data = self.m_model:checkActiveCfgByOpenId(79)
    local s_tim, e_tim = re_data.start_time, re_data.end_time
    local tim_1 = string.gsub(s_tim, "-", "/")
    local tim_2 = string.gsub(e_tim, "-", "/")
    local strs_1 = string.sub(tim_1, 1, 5) .. "<size=30>" .. string.sub(tim_1, 6, 10) .. "</size>" .. string.sub(tim_1, 11, #tim_1)
    local strs_2 = string.sub(tim_2, 1, 5) .. "<size=30>" .. string.sub(tim_2, 6, 10) .. "</size>" .. string.sub(tim_2, 11, #tim_2)
    local show_tim = strs_1 .. " - " .. strs_2
    self:setSpine()
end

function M:switchInit(url, data, id, callback)
    local function callFunc(data)
        self.m_cont_data = self.m_model.m_continuous_data
        self:refreshUI()
        if callback then
            callback(data)
        end
    end
    self.node_data = data
    self.m_model:initData(url, callFunc)
end

function M:refreshUI()
    local active_data = self.m_model:getActivesById(self.node_data)
    if active_data then
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(active_data.remain_ts)
        if day > 0 then
            self:setTextByLanKey("title_text", "activities_str_0009", tostring(day))
        elseif hour > 0 then
            self:setTextByLanKey("title_text", "activities_str_0010", tostring(hour))
        elseif min >= 0 then
            self:setTextByLanKey("title_text", "activities_str_0011", tostring(min))
        end
    end
    self:createLoopScroll()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.before_pos = Vector2.zero
    local data = self.m_model:get_gontinuous_cfg()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRewardItem(cell_obj, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name) -- 点击回调
                if self.m_model:canReceiveContinuous(index) == 1 then
                    self:updateMsg("receive_continuous", index)
                else
                    local box_obj = UIUtil.findTrans(cell_object.transform, "node")
                    local rech_data = self.m_model:getContinuousItems(index)
                    local show_check_mark = self.m_model:canReceiveContinuous(index) == 2
                    self:lookTips(1, rech_data, box_obj, false, nil)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:onValueChanged(pos)
    if math.floor(self.before_pos.x * 100) ~= math.floor(pos.x * 100) then
        self.before_pos.x = pos.x
        self.before_pos.y = pos.y
        self:updateCells()
    end
end

function M:updateCells()
    local rect = self.m_scroll_view.m_scroll_rect.viewport.rect
    local cellSize = self.m_scroll_view.m_loop_scroll_view.cellSize
    local offset_pos = self.m_scroll_view:getContentOffset()
    local center_pos_x = -offset_pos.x + rect.width * 0.5
    local init_cells = self.m_scroll_view:getInitCells()
    for i, v in pairs(init_cells) do
        local view_cell = v:GetComponent("ScrollViewCell")
        local luaBehaviour = v:GetComponent("LuaBehaviour")
        local node = luaBehaviour:FindGameObject("node")
        -- local pos = v.transform.parent:InverseTransformPoint(node.transform.position)
        -- local target_pos = self:getPos(i)
        -- local diff_x =  pos.x - target_pos.x
        -- local d_pos = Vector3.New(0, node.y, 0)
        -- local y_num = 0
        -- if diff_x > 0 then
        --     if diff_x <= 130 then
        --         local per = diff_x/130
        --         local next_diff = self:getHeigthDiff(i)
        --         x_num = target_pos.x +(next_diff*per)
        --     end
        -- end
        --node.transform.localPosition = Vector3.New(50, 100, 0)
    end
end

function M:getHeigthDiff(index)
    local target_1 = self:findGameObject("pos_" .. index)
    local target_2 = self:findGameObject("pos_" .. index + 1)
    if IsNull(target_2) then
        return 0
    end
    local pos_1 = self.content_node.transform.parent:InverseTransformPoint(target_1.transform.position)
    local pos_2 = self.content_node.transform.parent:InverseTransformPoint(target_2.transform.position)
    return pos_2.y - pos_1.y
end

function M:updateRewardItem(obj, index)
    local data = self.m_model:getRechargeById(index)
    if not IsNull(obj) then
        local luaBehaviour = UIUtil.findLuaBehaviour(obj)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_icon_2", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_icon_1", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_icon_0", false)
        if data and next(data) ~= nil then
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_icon_" .. data.status, true)
            if data.status == 0 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", "gf_str_0028", index)
            elseif data.status == 1 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", "new_str_0655")
            elseif data.status == 2 then
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", "new_str_0080")
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "reward_icon_0", true)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "day_text", "gf_str_0028", index)
        end
        if index == self.m_model.m_continuous_data.day then
            local data = self.m_model:getRechargeById(index)
            local rech_data = self.m_model:getContinuousItems(1)
            if next(data) == nil or data.status == 0 then
                local show_num = ""
                if data and data.status == 0 then
                    local charge_tab = ConfigManager:getCfgByName("price_show")
                    local money_type = ConfigManager:getCommonValueById(331)
                    local price_data = charge_tab[rech_data.price]
                    local unit = "¥"
                    for k, v in pairs(GlobalConfig.TYPE_MONEY) do
                        if money_type == v.name then
                            unit = v.sign_name
                        end
                    end
                    local num = (price_data[money_type] - data.price)
                    if num <= 0 then
                        num = 0
                    end
                    show_num = num .. unit
                else
                    show_num = GameUtil:getMoneyTypeNum(rech_data.price)
                end
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "charge_text", "gf_str_0054", show_num)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "charge_tips", true)
            else
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "charge_tips", false)
            end
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "charge_tips", false) 
        end
    end
end

function M:onButtonClick(obj, name)
    local box_obj = self:findGameObject(name)
    local show_check_mark = false
    if name == "reward_1" then
        if self.m_model:canReceiveContinuous(1) == 1 then
            self:updateMsg("receive_continuous", 1)
        else
            local rech_data = self.m_model:getContinuousItems(1)
            show_check_mark = self.m_model:canReceiveContinuous(1) == 2
            self:lookTips(1, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_2" then
        if self.m_model:canReceiveContinuous(2) == 1 then
            self:updateMsg("receive_continuous", 2)
        else
            local rech_data = self.m_model:getContinuousItems(2)
            show_check_mark = self.m_model:canReceiveContinuous(2) == 2
            self:lookTips(2, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_3" then
        if self.m_model:canReceiveContinuous(3) == 1 then
            self:updateMsg("receive_continuous", 3)
        else
            local rech_data = self.m_model:getContinuousItems(3)
            show_check_mark = self.m_model:canReceiveContinuous(3) == 2
            self:lookTips(3, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_4" then
        if self.m_model:canReceiveContinuous(4) == 1 then
            self:updateMsg("receive_continuous", 4)
        else
            local rech_data = self.m_model:getContinuousItems(4)
            show_check_mark = self.m_model:canReceiveContinuous(4) == 2
            self:lookTips(4, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_5" then
        if self.m_model:canReceiveContinuous(5) == 1 then
            self:updateMsg("receive_continuous", 5)
        else
            local rech_data = self.m_model:getContinuousItems(5)
            show_check_mark = self.m_model:canReceiveContinuous(5) == 2
            self:lookTips(5, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_6" then
        if self.m_model:canReceiveContinuous(6) == 1 then
            self:updateMsg("receive_continuous", 6)
        else
            local rech_data = self.m_model:getContinuousItems(6)
            show_check_mark = self.m_model:canReceiveContinuous(6) == 2
            self:lookTips(6, rech_data, box_obj, false, nil)
        end
    elseif name == "reward_7" then
        if self.m_model:canReceiveContinuous(7) == 1 then
            self:updateMsg("receive_continuous", 7)
        else
            local rech_data = self.m_model:getContinuousItems(7)
            show_check_mark = self.m_model:canReceiveContinuous(7) == 2
            self:lookTips(7, rech_data, box_obj, false, nil)
        end
    else
        M.super.onButtonClick(self, obj, name)
    end
end

function M:lookTips(day, rech_data, box_obj, show_check_mark, cb)
    local params = {
        rewards = rech_data.server_reward,
        click_transform = box_obj,
        show_check_mark = show_check_mark,
        offset_y = 15,
        callback = function()
            if cb then
                cb()
            end
        end
    }
    self:openView("Pops.LookRewardTips", params)
end

function M:updateTime()
end

function M:setSpine()
    local reward_data = RewardUtil:getProcessRewardData({101, 282, 1})
    if reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROS or reward_data.data_type == RewardUtil.REWARD_TYPE_KEYS.HEROSEXT then
        local cfg = UserDataManager.hero_data:getHeroConfigByCid(reward_data.data_id)
        if cfg then
            local icon = cfg.hero_spine
            if self.cacheSpineName == icon then
                return
            else
                self.cacheSpineName = icon
            end
            local play_img = self:findGameObject("hero_spine")
            GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. self.cacheSpineName, "idle", 0, true)
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end


return M
