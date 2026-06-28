local M = class("GifBagOnTimeNode", LikeOO.OOUIbase)
--在线奖励
M.m_uiName = "GiftBag/GifBagOnTimeNode"

function M:onEnter()
    self.cell_obj = nil
    self.show_time = false
end

function M:switchInit(url)
    local function callFunc(data)
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
    self:createLoopScroll()
    self.m_tim = self.m_control:setTimer(1, handler(self, self.UpdateTimer))
    self:UpdateTimer()
end

--[[
    创建礼包列表
]]
function M:createLoopScroll()
    self.m_gift_tab = {}
    local data = self.m_model:get_online_tab()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self.m_gift_tab[index] = cell_obj
                if cell_obj == self.cell_obj then
                    self.show_time = false
                end
                self:updateTimItem(index, cell_obj, cell_data)
                if self.m_model.m_online_reward_data.online_reward.config == cell_data.id then
                    self.cell_obj = cell_obj
                    self.show_time = true
                    self:UpdateTimer()
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "tim_btn" then
                elseif click_name == "get_btn" then
                    self:updateMsg("get_btn", index)
                end
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateTimItem(index, obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    local data = cell_data.cfg
    if LuaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "title_text", data.name)
        LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "time_text", data.time .. "分钟")
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tim_btn", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_btn", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "received_text", false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_btn", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_bg", true)
        local itemPrefabe = LuaBehaviour:FindGameObject("itemPrefabe")
        local gray = LuaBehaviour:FindImage("gray")
        local tim_btn = LuaBehaviour:FindImage("tim_btn")
        if self.m_model.m_online_reward_data.online_reward.config == -1 or self.m_model.m_online_reward_data.online_reward.config > cell_data.id then
            tim_btn.material = gray.material
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "received_text", "已领取")
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "received_text", true)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_btn", false)
            LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_bg", true)
        else
            tim_btn.material = nil
        end
        UIUtil.destroyAllChild(itemPrefabe.transform)
        GameUtil:createRewards(itemPrefabe.transform, data.reward, true, true, nil)
    end
end

function M:UpdateTimer()
    if self.cell_obj and self.show_time == true then
        local LuaBehaviour = UIUtil.findLuaBehaviour(self.cell_obj)
        local cur_cfg = self.m_model:getCurOnlineCfg()
        if LuaBehaviour then
            if cur_cfg <= 0 then
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "get_btn_text", "领取")
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tim_btn", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_btn", true)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "received_text", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_btn", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_bg", false)
                self.m_control:removeTimer(self.m_tim)
            else
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "tim_btn", true)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "get_btn", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "received_text", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_btn", false)
                LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lock_bg", false)
                LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "tim_btn_text", GameUtil:formatTimeBySecond(cur_cfg))
            end
        end
    end
end

function M:destroy()
    if self.m_tim then
        self.m_control:removeTimer(self.m_tim)
    end
    M.super.destroy(self)
end

return M
