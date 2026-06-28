---@class BulletManager_View @子弹视图管理器
local M = class("BulletManager_View")

--初始化
function M:init(player)
    self.player = player
    self.bulletList = {}
    --监听子弹数据创建完成
    self.player:addEventListener_Local(Battle.EventType.MV_BulletModelCreateFinish, {self, self.BulletModelCreateFinish})
    self.player:addEventListener_Local(Battle.EventType.MV_BulletManagerClear, {self, self.BulletManagerClear})
end

--子弹的数据创建完成了
function M:BulletModelCreateFinish(eventName, data)
    local bullet_model = data;
    local bullet_type = bullet_model:get_type();
    local effect_data = bullet_model:get_effectData();
    local bullet_view = require("BattleView.Blt."..bullet_type.."_View").new()
    SceneManager.MV_EventMgr:register(bullet_view, bullet_model);
    bullet_view:init(self.player, effect_data, bullet_model);
    --以Model为key 把视图存起来
    self.bulletList[bullet_model] = bullet_view;
end


function M:BulletManagerClear(eventName, data)
    self:destroy();
end


--清除所有子弹视图
function M:destroy()
    for m,v in pairs(self.bulletList) do
        if v ~= nil then
            v:destroy();
        end
    end
    self.bulletList = {}
end

--移除子弹
function M:removeBullet( model )
    self.bulletList[model] = nil;
end


return M