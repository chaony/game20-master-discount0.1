---@class DeliciousFeastMainView: OOPopBase
---@field m_model DeliciousFeastMainModel
local M = class("DeliciousFeastMainView", LikeOO.OOPopBase)

M.m_uiName = "Activities/DeliciousFeast/DeliciousFeastMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { open_id = 322, red_point_img = "red_point1", btn_text = "btn_text1", btn_name = "feast_text_0001", }, -- 食神祝福 任务
    { open_id = 323, red_point_img = "red_point2", btn_text = "btn_text2", btn_name = "feast_text_0002", }, -- 美味尝鲜 制作
    { open_id = 324, red_point_img = "red_point3", btn_text = "btn_text3", btn_name = "feast_text_0003", }, -- 美味集市 礼包
    { open_id = 325, red_point_img = "red_point4", btn_text = "btn_text4", btn_name = "feast_text_0004", }, -- 美味兑换
    { open_id = 326, red_point_img = "red_point5", btn_text = "btn_text5", btn_name = "feast_text_0005", }, -- 厨神争霸 排行榜
}

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self.setVisible = false
    local isOfficial = self.m_model:checkIsOfficial()
    self:setObjectVisible("bg2", not isOfficial)
    local bg_name = self:findImage("bg1")
    local curBgName = isOfficial and "meituan_bg" or "a_hd_hhds_zjm_bg"
    GameUtil:updateResourcesImg(bg_name, "Texture/deliciousFeast/" .. curBgName)
    for k, v in pairs(TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, v.btn_name)
    end
    self:setObjectVisible("meituanH5_btn", isOfficial)
    self:setTextByLanKey("close_title_text", "feast_text_0011")
    self:setTextByLanKey("btn_text_meituan", "feast_text_0018")
    self:refreshRedPoint()
end

function M:refreshRedPoint()
    for k, v in pairs(TAB_BTN_NODE) do
        local red_flag = false
        if v.open_id == 324 then
            red_flag = RedPointUtil:getCommonGiftRedByOpenId(v.open_id, true)
        elseif v.open_id == 322 then
            red_flag = self.m_model:getTaskRedPoint()
        elseif v.open_id == 323 then
            red_flag = self.m_model:getCookRedPoint()
        end
        self:setObjectVisible(v.red_point_img, red_flag)
    end
end

function M:SetRedPoint(visible)
    --结束设置红点为false
    if self.setVisible then
        return
    end
    for k, v in pairs(TAB_BTN_NODE) do
        local red_flag = visible
        self:setObjectVisible(v.red_point_img, visible)
    end
    self.setVisible = true
end

function M:updateActivityTimer()
    local data = self.m_model:getActivityData()
    if data then
        local leftTime = data.end_ts - UserDataManager:getServerTime()
        if leftTime >= 0 and data.open_status == 1 then
            local text = GameUtil:formatTimeBySecond(leftTime)
            text = Language:getTextByKey("new_str_0919") .. text
            self:setTextByLanKey("text_timer", text)
        elseif data.open_status == 2 then
            self:setTextByLanKey("text_timer", "new_str_0558")
            self:SetRedPoint(false)
            if leftTime <= 0 then
                self:updateMsg("time_over")
            end
        else
            self:setTextByLanKey("text_timer", "new_str_0558")
            self:SetRedPoint(false)
        end
    end

end

function M:destroy()
    M.super.destroy(self)
end

return M