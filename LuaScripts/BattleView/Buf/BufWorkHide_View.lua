--隐身（从场上消失）
---@class BufWorkHide_View : BufWork_View @
---@field super BufWork_View @BufWork_View
local M = class("BufWorkHide_View", BufWork_View)

function M:init(buf, model)
    M.super.init(self,buf, model)
    if self.playerBuf.player.body ~= nil then
        if not IsNull(self.playerBuf.player.body) then
            self.playerBuf.player.body.gameObject:SetActive(false)
        end
        if not IsNull(self.playerBuf.player.hpBar) then
            self.playerBuf.player.hpBar:Show(false)
        end
    end
end

function M:stop()
    M.super.stop(self)
    local hide = self.playerBuf_model.player.bufMgr:findBufByType("Hide")
    if table.nums(hide) == 1 then
        if not IsNull(self.playerBuf.player.body) then
            self.playerBuf.player.body.gameObject:SetActive(true)
            if not IsNull(self.playerBuf.player.hpBar) then
                self.playerBuf.player.hpBar:Show(true)
            end
        end
    end
end

return M