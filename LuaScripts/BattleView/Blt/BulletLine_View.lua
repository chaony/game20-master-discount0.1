--锁链类子弹（前后两发子弹命中的人会连起来）(子弹必定命中)
---@class BulletLine_View : Bullet_View @
---@field super Bullet_View @Bullet_View
local M = class("BulletLine_View", Battle.Bullet_View)

--初始化子弹
function M:init( player,effectData, model )
    M.super.init(self, player,effectData, model )
    self.lineSource = true;
    --创建子弹线
    self:addEventListener_Local(Battle.EventType.MV_BulletModelCreateLine, {self, self.MV_BulletModelCreateLine})
end

--创建子弹线
function M:MV_BulletModelCreateLine(eventName, data)
    self:createLine()
end


--销毁子弹
function M:destroy()
    M.super.destroy(self)
    if self.line ~= nil then
        self.line:Destroy();
        self.line = nil;
    end
end


function M:createLine()
    if self.obj ~= nil then
        self.obj:SetActive(false)
        self.otherBullet.obj:SetActive(false)
    end
    
    local pool_type = "hero";
    if self.player.camp == -1 then
        pool_type = "enemy";
    end
    --ResourceUtil:LoadRole3dBulletAsync(self.player.plyType, self.linePrefab, nil, pool_type, function(obj)
    --    self.line = obj:GetComponent("LineControl")
    --    self.otherBullet.line = self.line
    --end)
    
    if self.linePrefab ~= nil then
        self.line = self.player.luaViewHelper.m_ui:CreatePlayerLine( self.player.prefabRoot, self.linePrefab )
    end

    --C#组件
    self.lineLuaViewHelper = self.line.m_owner;
    self.lineHelperArr = LuaCSharpArr.New(12)
    local CSharpAccess = self.lineHelperArr:GetCSharpAccess()
    self.lineLuaViewHelper:PinTable(CSharpAccess)
    
end

function M:update(dt,unsdt)
    if self.start then
        if self.bulletState ~= 2 then
            if self.line ~= nil then
                if self.otherBullet.enemy:isLive() ~= true then
                    ResourceUtil:ReturnItem(self.line.gameObject);
                end
                if self.lineSource == true then
                    local pos = self.enemy.position:Clone()
                    self.lineHelperArr[4] = pos.x;
                    self.lineHelperArr[5] = pos.y + GlobalTools.base1;
                    self.lineHelperArr[6] = pos.z;
                    
                    pos = self.otherBullet.enemy.position:Clone()
                    self.lineHelperArr[1] = pos.x;
                    self.lineHelperArr[2] = pos.y + GlobalTools.base1;
                    self.lineHelperArr[3] = pos.z;
                end
            end
        end
    end
end

return M