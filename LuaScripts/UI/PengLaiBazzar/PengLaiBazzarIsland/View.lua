---@class PengLaiBazzarIslandView: OOPopBase
---@field m_model PengLaiBazzarIslandModel
local M = class("PengLaiBazzarIslandView", LikeOO.OOPopBase)

M.m_uiName = "PengLaiBazzar/PengLaiIsland"
M.m_size_type = 1
M.m_iphoneXAdapter = true

local TAB_BTN_NODE = {
    { open_id = 349, red_point_img = "red_point1", btn_text = "btn_text1", btn_name = "half_year_text_0001", btn_img = "Image1" }, -- 蓬莱集市
}

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 39})
    self:refreshUI()
end

function M:bindUI()
    for k, v in pairs(TAB_BTN_NODE) do
        self:setTextByLanKey(v.btn_text, v.btn_name)
    end
    self:setTextByLanKey("close_title_text", "pengLai_text_002")
    self:setTextByLanKey("btn_text3", "pengLai_text_003")
    self:setTextByLanKey("btn_text7", "pengLai_text_004")
    self:setTextByLanKey("btn_text2", "pet_arena_text_0001")
    self:setTextByLanKey("btn_text4", "pengLai_text_026")
    self:setTextByLanKey("btn_text5", "awake_system_text_001")
    
    local gray_img = self:findImage("gray_img")
    self.m_gray_material = gray_img.material
    local normal_img = self:findImage("Image1")
    self.m_normal_material = normal_img.material
end

function M:refreshUI()
    self:bindUI()
    self:refreshEntrances()
end

function M:dayRefresh()
    self.m_control:setOnceTimer(2, self:refreshEntrances())
end

function M:refreshEntrances()
    -- 刷新入口及红点
    
    -- 奇兽斋入口
    local isShowRed = RedPointUtil:petEntryHasRedPoint()
    self:setObjectVisible("red_point7", isShowRed)
    
    -- 蓬莱集市入口
    local bazaarRed = RedPointUtil:hasRedPointById(349, nil)
    self:setObjectVisible("red_point3", bazaarRed)
    
    local isShowArenaRed = UserDataManager:getRedDotByKey("pet_pvp") > 0
    self:setObjectVisible("red_point2", isShowArenaRed)
    -- 威望个红点
    local isWei1 = RedPointUtil:hasRedPointById(383, nil)
    local isWei2 = PrestigeUtil:hasNewBlock()
    self:setObjectVisible("red_point4", isWei1 or isWei2)
    
    local awaken_red = UserDataManager:getRedDotByKey("awaken")
    self:setObjectVisible("red_point5", awaken_red > 0)

    local open_flag = BtnOpenUtil:isBtnOpen(417)
    local awaken_img =self:findImage("open_btn5_img")
    awaken_img.material = open_flag and self.m_normal_material or self.m_gray_material
end

function M:destroy()
    if self.m_attr_node then
        self.m_attr_node:destroy()
        self.m_attr_node = nil
    end
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, { self, self.dayRefresh })
    M.super.destroy(self)
end

return M