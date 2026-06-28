--角色头顶的特殊UI
---@class PlayerHeadUI @
local M = class("PlayerHeadUI")

M.obj = nil

M.player = nil

M.uiName = ""

M.offset = nil

M.luaBehaviour = nil

M.content = nil

--初始化
function M:init(uiName, player, params)
    self.uiName = uiName
    self.player = player
    self.offset = params.offset or Vector2.New(0,0)
    if self.player.hpBar ~= nil and self.player.hpBar.m_obj ~= nil then
        self.obj = ResourceUtil:GetUIItem("Battle/PlayerHeadUI/".. uiName, self.player.hpBar.m_obj, "ui_prefabs");
        self.luaBehaviour = self.obj:GetComponent("LuaBehaviour")
        self.content = self.luaBehaviour:FindRectTransform("content")
        local rect = self.obj:GetComponent("RectTransform")
        rect.anchoredPosition3D = self.offset;
        self.player.hpBar:AddHeadUI(self.obj)
    end
end

--update
function M:update(dt)
    
end

--内容刷新
function M:refreshUI(params)
    
end

function M:destroy()
    if self.obj ~= nil then
        self.player.hpBar:RemoveHeadUI(self.obj)
        self.obj = nil
    end
    self.player = nil
end

return M