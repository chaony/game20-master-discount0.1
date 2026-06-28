local M = class("RacconView",LikeOO.OOPopBase)

M.m_uiName = "Raccon/RacconMain"
M.m_size_type = 1
M.m_iphoneXAdapter = true

M.UI_DATA = {
    {btn_name = "qlxs_btn", btn_text = "qlxs_btn_text", btn_lang_key = "raccon_text_0001", red_point_img = "qlxs_btn_red_point_img", open_id = 340},
    {btn_name = "xkz_btn", btn_text = "xkz_btn_text", btn_lang_key = "raccon_text_0003", red_point_img = "xkz_btn_red_point_img", open_id = 341},
    {btn_name = "hxjkc_btn", btn_text = "hxjkc_btn_text", btn_lang_key = "raccon_text_0002", red_point_img = "hxjkc_btn_red_point_img", open_id = 344},
    {btn_name = "fctj_btn", btn_text = "fctj_btn_text", btn_lang_key = "raccon_text_0021", red_point_img = "fctj_btn_red_point_img", open_id = 342},
    {btn_name = "hlsj_btn", btn_text = "hlsj_btn_text", btn_lang_key = "raccon_text_0007", red_point_img = "hlsj_btn_red_point_img", open_id = 346},
    {btn_name = "hxyyl_btn", btn_text = "hxyyl_btn_text", btn_lang_key = "raccon_text_0004", red_point_img = "hxyyl_btn_red_point_img"},
    {btn_name = "hxlb_btn", btn_text = "hxlb_btn_text", btn_lang_key = "raccon_text_0005", red_point_img = "hxlb_btn_red_point_img", open_id = 345},
}

function M:onEnter()
    EventDispatcher:registerEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
    self.m_gray_image = self:findImage("gray_img")
    self:initUi()
    self:refreshUI()
    local open_condition = ConfigManager:getCfgByName("open_condition")
    local o_item = open_condition[339] or {}
    local bg_img = self:findGameObject("bg_img")
    local bg_path = self.m_model:getMainCfgVByK("background")
    if bg_path then
        GameUtil:updateResourcesImg(bg_img,"Texture/raccon/"..bg_path) --设置背景
    end
    self:setTextByLanKey("close_title_text", o_item.name )
end

function M:initUi()
    for i = 1, #self.UI_DATA do
        local ui_data = self.UI_DATA[i]
        self:setObjectVisible(ui_data.red_point_img, false)
        local name = self.m_model:getOpenCfgNameById(ui_data.open_id)
        self:setTextByLanKey(ui_data.btn_text, name and name or ui_data.btn_lang_key)
    end
end

function M:destroy()
    EventDispatcher:unRegisterEvent(GlobalConfig.EVENT_KEYS.EVERY_DAY_EVENT, {self, self.everyDayRefreshEvent})
    M.super.destroy(self)
end

function M:everyDayRefreshEvent()
    self:updateMsg("refresh_index")
end

function M:refreshUI()
    --self:refreshDailyNode()
    self:refreshRedPoint()
end

function M:updateActivityTimer()
    local end_ts = self.m_model:getEndTs()
    if end_ts >= 0 then
        local text = GameUtil:formatTimeBySecond(end_ts, 999)
        text = Language:getTextByKey("new_str_0919") .. text
        self:setTextByLanKey("time_dwon_text", text)
    else
        --self:updateMsg("refresh_index")
    end
end

function M:refreshRedPoint()
    local raccon_chapter = RedPointUtil:hasRedPointById(341)
    self:setObjectVisible("xkz_btn_red_point_img", raccon_chapter)

    local date_flag = RedPointUtil:hasRedPointById(340, self.m_model.m_version)
    self:setObjectVisible("qlxs_btn_red_point_img",date_flag)

    local yyl_flag = RedPointUtil:hasRedPointById(343)
    self:setObjectVisible("hxyyl_btn_red_point_img",yyl_flag)

    local collect_flag = RedPointUtil:hasRedPointById(344, self.m_model.m_version)
    self:setObjectVisible("hxjkc_btn_red_point_img",collect_flag)

    local draw_flag = RedPointUtil:hasRedPointById(346)
    self:setObjectVisible("hlsj_btn_red_point_img",draw_flag)

    local gift_flag = RedPointUtil:hasRedPointById(345) or RedPointUtil:hasRedPointById(348)
    self:setObjectVisible("hxlb_btn_red_point_img",gift_flag)
end

return M