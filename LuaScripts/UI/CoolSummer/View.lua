---@class CoolSummerMainView: OOPopBase
---@field m_model CoolSummerMainModel
local M = class("CoolSummerMainView", LikeOO.OOPopBase)

M.m_uiName = "CoolSummer/CoolSummerMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { open_id = 367, red_point_img = "red_point1", btn_text = "btn_text1", btn_name = "", btn_img = "Image1" ,red_open_id = 334}, --清凉消暑
    { open_id = 368, red_point_img = "red_point2", btn_text = "btn_text2", btn_name = "", btn_img = "Image2" ,red_open_id = 368}, -- 守卫清凉
    { open_id = 369, red_point_img = "red_point3", btn_text = "btn_text3", btn_name = "", btn_img = "Image3" ,red_open_id = 330}, -- 夏日夺宝
    { open_id = 370, red_point_img = "red_point4", btn_text = "btn_text4", btn_name = "", btn_img = "Image4" ,red_open_id = 329}, -- 凄凉小集
}

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    self:refreshUI()
    self:setImg()
end

function M:setImg()
    local image_name = self:findImage("bg1")
    GameUtil:updateResourcesImg( image_name, "Texture/CoolSummer/" .. "a_map_juqing_bg_155")
end

function M:bindUI()
    local active_tab = self.m_model:getActiveTab(TAB_BTN_NODE)
    for k, v in pairs(active_tab) do
        self:setTextByLanKey(v.btn_text, v.btn_name)
        local Red = RedPointUtil:hasRedPointById(v.open_id, nil)
        self:setObjectVisible(v.red_point_img,Red)
    end
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
end

function M:refreshUI()
    self:bindUI()
    self:refreshActivityEntrances()
    self:updateActivityTimer()
end

function M:dayRefresh()
    self.m_control:setOnceTimer(2, self:refreshActivityEntrances())
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    local down_time = end_ts - UserDataManager:getServerTime()
    if down_time >= 0 then
        local text = ""
        local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(down_time)
        format = format or 0
        if day > 0 then
            text = string.format(Language:getTextByKey("new_str_0415"), day)
        else
            if hour > 0 then
                text = string.format("%02d:%02d:%02d", hour, min, sec)
            else
                if format == 1 then
                    if min > 0 then
                        text = string.format("%02d:%02d", min, sec)
                    else
                        text = string.format("%d", sec)
                    end
                else
                    text = string.format("%02d:%02d", min, sec)
                end
            end
        end
        self:setTextByLanKey("time_text","new_str_1028", text)
    else
        self:updateMsg(99999)
    end
end


--刷新入口及红点
function M:refreshActivityEntrances()
    local states = self.m_model:checkActivityStates()
    for k, v in pairs(TAB_BTN_NODE) do
        local isOpen = states[v.open_id]
        local btn_img = self:findImage(v.btn_img)
        if isOpen then
            btn_img.material = nil
            self:setObjectVisible(v.red_point_img, false)
            local red_flag = RedPointUtil:hasRedPointById(v.open_id)
            self:setObjectVisible(v.red_point_img, red_flag)
        else
            btn_img.material = self.m_gray_material
            self:setObjectVisible(v.red_point_img, false)
        end
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    M.super.destroy(self)
end

return M