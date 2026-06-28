--角色头顶的特殊UI管理器
---@class HeadUIManager_View @
local M = class("HeadUIManager_View")

--所有的UI列表
M.headUIList = nil

--初始化
function M:init(player)
    self.player = player
    self.headUIList = {}
end

--添加到list内
function M:add(uiName, params)
    if uiName ~= "" then
        local headUI = require("BattleView.Ply.HeadUI."..uiName.."_ui").new()
        headUI:init(uiName, self.player, params)
        table.insert(self.headUIList, headUI)
        return headUI
    end
end

--update
function M:update(dt)
    for k,v in pairs(self.headUIList) do
        v:update()
    end
end

function M:remove(uiName)
    local tempList = table.copy(self.headUIList)
    for k,v in pairs(tempList) do
        if v.uiName == uiName then
            v:destroy()
            self.headUIList[k] = nil
        end
    end
end

function M:destroy()
    for k,v in pairs(self.headUIList) do
        v:destroy()
    end
    self.headUIList = {}
    self.player = nil
end

return M