--福威技能1头顶ui
---@class G_FuW_skill1_ui : PlayerHeadUI_View @
---@field super PlayerHeadUI_View @PlayerHeadUI_View
local M = class("G_FuW_skill1_ui", PlayerHeadUI_View)

M.buf_skill = nil
--初始化
function M:init(uiName, player, params)
    M.super.init(self, uiName, player, params)
    self.buf_skill = {}
    if self.luaBehaviour ~= nil then
        for i = 1, 3 do
            table.insert(self.buf_skill, self.luaBehaviour:FindImage("buf_skill1_"..i))
        end
        self.gray = self.luaBehaviour:FindImage("gray")
    end
end

function M:refreshUI(params)
    M.super.refreshUI(self, params)
    if self.obj ~= nil then
        for k,v in ipairs(self.buf_skill) do
            if params.count >= k then
                v.material = nil
            else
                v.material = self.gray.material
            end
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M