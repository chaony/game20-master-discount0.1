--免疫buff
---@class BufWorkImmunity : BufWork_Model @
---@field super BufWork_Model @BufWork_Model
local M = class("BufWorkImmunity", BufWork_Model)

function M:initFinish()
    --local tag = self.playerBuf:checkParam("tag", "")
    --self.playerBuf.player.bufMgr:removeBufByTag(tag, true)
    self.takeTime = self.playerBuf:checkParam("time", -1)
    self.curTakeTime = 0
end

-- 生效次数
function M:takeEffect(killer)
    self.curTakeTime = self.curTakeTime + GlobalTools.base1
    if self.takeTime > 0 and self.curTakeTime >= self.takeTime then
        self.playerBuf.mgr:removeBuf(self.playerBuf)
    end
    if killer ~= nil then
        EventDispatcher:dipatchEvent("BufWorkImmunityTakeEffect",{ data = killer, playerBuf = self.playerBuf } )
    end
end

---@param buff PlayerBuf_Model
function M:checkBuf(buff, source)
    for k, v in ipairs(buff.tag) do
        local tags = self.playerBuf:checkParam("tag", "")
        if type(tags) == "table" then
            for tags_k, tags_v in ipairs(tags) do
                if v == tags_v then
                    self:takeEffect(source)
                    return true;
                end
            end
        else
            if v == self.playerBuf:checkParam("tag", "") then
                self:takeEffect(source)
                return true
            end
        end
    end
    return false
end


function M:checkHit()
    local tags = self.playerBuf:checkParam("tag", "")
    if type(tags) == "table" then
        for tags_k, tags_v in ipairs(tags) do
            if tags_v == "hit" then
                self:takeEffect()
                return true;
            end
        end
    else
        if self.playerBuf:checkParam("tag", "") == "hit" then
            self:takeEffect()
            return true
        end
    end
    --if "hit" == self.playerBuf:checkParam("tag", "") then
    --    return true
    --end
    return false
end


function M:checkTag(tag, player)
    local tags = self.playerBuf:checkParam("tag", "")
    if type(tags) == "table" then
        for tags_k, tags_v in ipairs(tags) do
            if tags_v == tag then
                self:takeEffect(player)
                return true;
            end
        end
    else
        if self.playerBuf:checkParam("tag", "") == tag then
            self:takeEffect(player)
            return true
        end
    end
    --if tag == self.playerBuf:checkParam("tag", "") then
    --    return true
    --end
    return false
end

return M