---@class HalfAnniversaryMainView: OOPopBase
---@field m_model HalfAnniversaryMainModel
local M = class("HalfAnniversaryMainView", LikeOO.OOPopBase)

M.m_uiName = "HalfAnniversary/HalfAnniversaryMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { open_id = 333, red_point_img = "red_point1", btn_text = "btn_text1", btn_name = "half_year_text_0001", btn_img = "Image1" }, --组队
    { open_id = 334, red_point_img = "red_point2", btn_text = "btn_text2", btn_name = "half_year_text_0002", btn_img = "Image2" }, -- 签到
    { open_id = 328, red_point_img = "red_point3", btn_text = "btn_text3", btn_name = "half_year_text_0003", btn_img = "Image3" }, -- 全服任务
    { open_id = 331, red_point_img = "red_point4", btn_text = "btn_text4", btn_name = "half_year_text_0004", btn_img = "Image4" }, -- 抽奖
    { open_id = 329, red_point_img = "red_point5", btn_text = "btn_text5", btn_name = "half_year_text_0005", btn_img = "Image5" }, -- 礼包
    { open_id = 327, red_point_img = "red_point6", btn_text = "btn_text6", btn_name = "half_year_text_0006", btn_img = "Image6" }, -- 神兽来袭
    { open_id = 330, red_point_img = "red_point7", btn_text = "btn_text7", btn_name = "half_year_text_0022", btn_img = "Image7" }, -- 神兽秘境
}

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    self:refreshUI()
end

function M:bindUI()
    for k, v in pairs(TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, v.btn_name)
    end
    self:setTextByLanKey("close_title_text", UserDataManager.m_activity_name)
    --self:setTextByLanKey("close_title_text", "half_year_text_0007")
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    local normal_img = self:findImage("Image1")
    self.m_normal_material = normal_img.material
end

function M:refreshUI()
    self:bindUI()
    self:refreshActivityEntrances()
end

function M:dayRefresh()
    self.m_control:setOnceTimer(2, self:refreshActivityEntrances())
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