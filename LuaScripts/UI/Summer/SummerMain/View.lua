local M = class("SummerMainView", LikeOO.OOPopBase)

M.m_uiName = "Summer/SummerMain"
M.m_iphoneXAdapter = true

local ACTIVE_SUMMER_TAB = {
    {
        open_id = 122,
        name_key = "Admiration_Name",
        name_text = "",
        time_key = "Admiration_time",
        time_text = "",
        open = true
    }, --慕名而来
    {
        open_id = 123,
        name_key = "LouYueCaiYun_Name",
        name_text = "",
        time_key = "LouYueCaiYun_time",
        time_text = "",
        open = true
    }, --木鸢锦鲤
    {
        open_id = 124,
        name_key = "LuckyCharm_Name",
        name_text = "",
        time_key = "LuckyCharm_time",
        time_text = "",
        open = true
    }, --镂月裁云
    {
        open_id = 125,
        name_key = "TreasureBox_Name",
        name_text = "",
        time_key = "TreasureBox_time",
        time_text = "",
        open = true
    }, --机关宝盒
    {
        open_id = 126,
        name_key = "MaterialAcquisition_Name",
        name_text = "",
        time_key = "MaterialAcquisition_time",
        time_text = "",
        open = true
    }, --材料获取
    {
        open_id = 127,
        name_key = "LimitedTimeLogin_Name",
        name_text = "",
        time_key = "LimitedTimeLogin_time",
        time_text = "",
        open = true
    } --限时登录
}

function M:onEnter()
    if self.m_model.is_end then
        self:updateMsg(99999)

        return
    end
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 1})
    self.m_attr_node:setBGVisible(false)
    self:setTextByLanKey("close_title_text", "tid#OpenConditionName_121")
    self.m_active_recharge = self.m_model:getActive()
    self.Tab_Node = ACTIVE_SUMMER_TAB
    self:activeSet()
    self:setSpine()


    self:updateRP()
end

function M:updateRP()
    self.m_model:refreshRPData(
        function(rpData)

            self:setObjectVisible("rp_login7", rpData and rpData.login7)
            self:setObjectVisible("rp_openBox", rpData and rpData.openBox)
            self:setObjectVisible("rp_getMaterial", rpData and rpData.getMaterial)
        end
    )
end
--设置每个活动活动时间文字显示
function M:activeSet()
    self.m_control.m_titleName = {}
    for k, v in ipairs(self.Tab_Node) do
        local active_id = v.open_id
        v.name_text = self.m_model.m_active_condition[active_id]["name"]
        self.m_control.m_titleName[active_id] = v.name_text
        self:setTextByLanKey(v.name_key, v.name_text)
        local active_time = string.split(self.m_active_recharge[active_id].time_text, "~~")
        local star_ts = self.m_active_recharge[active_id].start_ts
        local end_ts = self.m_active_recharge[active_id].end_ts
        local remain_ts = self.m_active_recharge[active_id].remain_ts
        local star_data = TimeUtil.gmTime(star_ts)
        local end_data = TimeUtil.gmTime(end_ts)
        local time_text =
        Language:getTextByKey("anecdote_birthday_2", star_data.month, star_data.day) ..
        "—" .. Language:getTextByKey("anecdote_birthday_2", end_data.month, end_data.day)
        self:setTextByLanKey(v.time_key, time_text)
        if remain_ts < 0 then
            self:setTextByLanKey(v.time_key, "new_str_0558")
        end
        -- local startTime = string.split(string.split(active_time[1], " ")[1], "-")
        -- if startTime[2] ~= "" and startTime[2] ~= nil then
        --     local endTime = string.split(string.split(active_time[2], " ")[1], "-")
        --     local start_Month = string.format("%u", startTime[2])
        --     local start_Day = string.format("%u", startTime[3])
        --     local end_Month = string.format("%u", endTime[2])
        --     local end_Day = string.format("%u", endTime[3])
        --     v.time_text =
        --         Language:getTextByKey("anecdote_birthday_2", start_Month, start_Day) ..
        --         "—" .. Language:getTextByKey("anecdote_birthday_2", end_Month, end_Day)
        --     self:setTextByLanKey(v.time_key, v.time_text)
        -- end
    end
end

--英雄spine显示
function M:setSpine()
    local spine_name = self.m_model.m_hero_cfg.hero_spine or "hero_0506_SkeletonData"
    local play_img = self:findGameObject("hero_spine")
    GameUtil:updateSpineLoadSet(play_img, "RoleSpine/" .. spine_name, "idle", 0, true)

    --spine位置设置
    --local spine_pos,spine_scale = self.m_model:getSpinePos(self.m_model.m_hero_cfg)
    --local pos = play_img.transform.localPosition
    --pos.x = spine_pos[1] or 0
    --pos.y = spine_pos[2] or 0
    --play_img.transform.localPosition = pos
    --play_img.transform.localScale = Vector3(spine_scale,spine_scale,1)
end


--获取活动tab信息
function M:getTab(open_id)
    for k, v in pairs(self.Tab_Node) do
        if v.open_id == open_id then
            return v
        end
    end
end

function M:destroy()
    self:updateMsg("refresh_red_point", nil, "parent")

    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    M.super.destroy(self)
end

return M
