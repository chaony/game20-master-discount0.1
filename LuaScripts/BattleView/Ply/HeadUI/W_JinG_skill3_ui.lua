--金刚技能3头顶ui
---@class W_JinG_skill3_ui : PlayerHeadUI_View @
---@field super PlayerHeadUI_View @PlayerHeadUI_View
local M = class("W_JinG_skill3_ui", PlayerHeadUI_View)

M.last_anger = 0
--初始化
function M:init(uiName, player, params)
    M.super.init(self, uiName, player, params)
    self.last_anger = 0
    self:refreshUI({anger = 0, force = true})
end

function M:refreshUI(params)
    M.super.refreshUI(self, params)
    if self.obj ~= nil then
        if Mathf.Floor(self.last_anger / 10) ~= Mathf.Floor(params.anger / 10) or params.force == true then
            for i = 1, 5 do
                if params.anger >= i * 20 then
                    LuaBehaviourUtil.setImg(self.luaBehaviour, "anger_"..i, "a_zd_nuqidian_n", "battle_ui")
                elseif params.anger >= i * 20 - 10 then
                    LuaBehaviourUtil.setImg(self.luaBehaviour, "anger_"..i, "a_zd_nuqidian_n_ban", "battle_ui")
                else
                    LuaBehaviourUtil.setImg(self.luaBehaviour, "anger_"..i, "a_zd_nuqidian_d", "battle_ui")
                end
            end
            self.last_anger = params.anger
        end
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M