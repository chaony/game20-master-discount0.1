local M = class("HeroGatherPopView", LikeOO.OOPopBase)

M.m_uiName = "Activities/HeroGather/HeroGatherPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:setTextByLanKey("titles_text", "activities_str_0002")
    self:setText("close_title_text", "")
    self:initDownTime()
    self:refreshUI()
end

function M:refreshUI()
    local cfg_data = ConfigManager:getCfgByName("hero_gather")
    for i, v in ipairs(cfg_data) do
        if UserDataManager.elite_hero_nums < v.num then
            self:setTextByLanKey("stage_text", "activities_str_0006", i)
            self:setTextByLanKey("msg_text", v.des1)
            break
        end
    end
    self:updateListScroll()
end

function M:updateListScroll()
    local data = ConfigManager:getCfgByName("hero_gather")
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:listHandle(obj, id, data)
    local cfg = data
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local reward_content = luaBehaviour:FindGameObject("reward_content")
    local slider = luaBehaviour:FindSlider("slider")
    local receive_btn = luaBehaviour:FindButton("receive_btn")
    local slider_value_text = luaBehaviour:FindText("slider_value_text")
    slider_value_text.text = tostring(UserDataManager.elite_hero_nums) .. "/" .. cfg.num

    slider.value = UserDataManager.elite_hero_nums / cfg.num
    local status = self.m_model:getStatus(id)
    receive_btn.interactable = (status == 1)
    if status == 0 then
        UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0057")
    elseif status == 1 then
        UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0056")
    elseif status == 2 then
        UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0080")
    elseif status == 3 then
        UIUtil.setTextByLanKey(receive_btn.gameObject.transform, "Text", "new_str_0063")
    end

    GameUtil:createRewards(reward_content.transform, cfg.reward, true, true, nil, nil, true)
end

function M:initDownTime()
    local receive_ts = self.m_model:canGetTime()
    local server_ts = UserDataManager:getServerTime()
    if receive_ts > server_ts then
        local down_ts = receive_ts - server_ts
        local function tick(_, dt)
            down_ts = down_ts - dt
            if down_ts <= 0 then
                self:refreshUI()
                self.m_control:removeTimer(self.m_dt_timer)
            end
        end
        self.m_dt_timer = self.m_control:setTimer(1, tick)
    end
end

return M
