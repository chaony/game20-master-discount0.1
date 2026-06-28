--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-10 16:11:41
]]

--怒气管理器
---@class AngerData @
local M = class("AngerData")

M.curAnger = 0

M.maxAnger = 200

M.angerMaxHandler = nil
--怒气玩家
M.player = nil
--初始化
function M:init(player)
    self.maxAnger = 1000
    self.player = player
end

--增加怒气(增量)
function M:addAnger( anger, showLable )
    if anger > 0 and self.curAnger < self.maxAnger then
        self:setAnger(self.curAnger + anger)
        --怒气数字
        if showLable == true then
            self.playerBuf.player:createHpNumberLabel("+", anger, 4)
        end
    elseif anger < 0 and self.curAnger > 0 then
        self:setAnger(self.curAnger + anger)
        --怒气数字
        if showLable == true then
            self.playerBuf.player:createHpNumberLabel("", tostring(anger), 4)
        end
    end
end

--怒气是否满了
function M:isMax()
    if self.curAnger >= self.maxAnger then
        return true
    end
    return false
end

--设置当前怒气
function M:setAnger(anger)
    self.curAnger = anger
    --当前怒气大于最大怒气
    if self.curAnger >= self.maxAnger then
        --发送怒气满了的事件
        EventDispatcher:dipatchEvent("AngerMax",{ data = self.player,type = 2 })
        self.curAnger = self.maxAnger
    elseif self.curAnger <= 0 then
        self.curAnger = 0
    end
    
    local value = self.curAnger/self.maxAnger
    -- if self.player ~= nil and self.player.hpBar ~= nil then
    --     self.player.hpBar:SetAnger(value);
    -- end
    EventDispatcher:dipatchEvent("AngerUpdate",{ data = self.player,angerValue = value, type = 3 })
    if SceneManager.curScene.tongjiData then
        SceneManager.curScene.tongjiData:setPlayerRage(self.player:get_playerInstanceId(), self.curAnger, self.player.camp)
    end
end

--清空怒气
function M:clearAnger()
    self:setAnger(0)
end

return M