--慈航庇护值ui
---@class W_CiH_skill3_ui : PlayerHeadUI_View @
---@field super PlayerHeadUI_View @PlayerHeadUI_View
local M = class("W_CiH_skill3_ui", PlayerHeadUI_View)

--初始化
function M:init(uiName, player, params)
    M.super.init(self, uiName, player, params)
    self.m_top_rect = self.luaBehaviour:FindRectTransform("Top")
    
    self.max_width = 115
    self:SetValue(1)
end

function M:refreshUI(params)
    M.super.refreshUI(self, params)
    local value = GlobalTools:ToFloat(params.value)
    self:SetValue(value)
end

function M:SetValue(value)
    local top_width = self.max_width * value
    local top_size = self.m_top_rect.sizeDelta;
    top_size.x = top_width
    self.m_top_rect.sizeDelta = top_size
end

function M:destroy()
    M.super.destroy(self)
end

return M