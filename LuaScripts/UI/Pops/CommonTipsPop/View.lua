--==================================
-- file:  View.lua
-- brief:  通用tips 可以根据需求自己定义 后续可以添加
-- author:  LiuMiao
-- date:  2022/8/19
--==================================
--local TYPE_PARAMAS = {
--    left_name = "new_str_0007", --取消
--    right_name = "new_str_0006", --确认
--    title_text = "new_str_0005", --温馨提示
--    is_hint = false, --是否显示今日提示
--    hint_text = "new_str_0910", -- 今日不在提示
--    tips_text = "",
--    left_callback = nil,
--    right_callback = nil,
--    close_callback = nil,
--}

local M = class("CommonTipsPopView",LikeOO.OOPopBase)
-- 花花连连看二级确认框
M.m_uiName = "Pops/CommonTipsPop"  -- prefab name
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    self:bindUI()
    self:refreshUI()
end

function M:refreshUI()
    self:setTextByLanKey("tips_text", self.m_model.m_tips_text)
    self:setObjectVisible("hint_text", self.m_model.is_hint)
    self:setObjectVisible("btn_duiGouBtn", self.m_model.is_hint)
    if self.m_model.is_hint then
        self:setObjectVisible("img_duiGou", self.m_model.m_noPopHint)
    end
end

function M:bindUI()
    self:setTextByLanKey("common_title_text", self.m_model.m_title_text)
    self:setTextByLanKey("hint_text", self.m_model.m_hint_text)
    self:setTextByLanKey("text_cancel", self.m_model.m_left_name)
    self:setTextByLanKey("text_ok", self.m_model.m_right_name)
end

function M:destroy()
    M.super.destroy(self)
end

return M
