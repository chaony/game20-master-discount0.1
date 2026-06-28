---@class BulletManager_Model @子弹管理
---@field player PlayerModel
---@field bulletList Battle_List<Bullet_Model>
local M = class("BulletManager_Model")

--子弹数组
M.bulletList = nil

--最大子弹数
M.maxNum = 1000

--我的管理者
M.player = nil

M.lineTemp = nil

--初始化
function M:init(player)
    self.maxNum = 1000
    self.player = player
    self.bulletList = Battle.List.new()
end

--创建子弹
---@param data Battle_CreateBullet_Data
function M:createBullet( data )
    --如果没有找到子弹的类型
    if Battle.ClassPathUtil:Exists("Battle.Blt."..data.bulletType.."_Model") == false then
        data.bulletType = "Bullet"
    end
    --加载子弹脚本
    ---@type Bullet_Model
    local bullet = require("Battle.Blt."..data.bulletType.."_Model").new()
    --位置
    bullet:set_bullet_target( data.position:Clone() )
    --技能
    bullet.sourceSkill = data.skill
    --初始化
    bullet:init(data)
    
    --延迟 1秒 执行设计操作,模拟加载子弹事件，这个需要后面再设置
    bullet:shoot();
    self:addBullet(bullet)
end


--加入一个子弹
function M:addBullet(bullet)
    self.bulletList:add(bullet)
    --超过最大数量之后，再次加入的会随机删除已经存在的 
    if self.bulletList.Count > self.maxNum then
        local bullet = self.bulletList:get(0)
        if bullet ~= nil then
            bullet:destroy()
        end
    end
end

--移除子弹
function M:removeBullet(bullet)
    self.bulletList:remove(bullet)
end

--清除所有子弹
function M:clear()
    for i=self.bulletList.Count, 1, -1 do
        self.bulletList:get(i-1):destroy()
    end
    self.bulletList:clear()
    self.player:dispatchEvent_Local(Battle.EventType.MV_BulletManagerClear)
end

--[[
    @desc: 更新函数 
    author:{author}
    time:2019-12-31 17:34:02
    @return:
]]
function M:update(dt)
    if self.bulletList.Count > 0 then
        for i=self.bulletList.Count,1,-1 do
            local bullet = self.bulletList:get(i-1)
            if bullet ~= nil and bullet:isDead() == false then
                self.bulletList:get(i-1):update(dt)
            else
                self:removeBullet(bullet)
            end
        end
    end
end

function M:update_unsdt(unsdt)
    if self.player.animator.mode == 2 then
        if self.bulletList.Count > 0 then
            for i=self.bulletList.Count,1,-1 do
                local bullet = self.bulletList:get(i-1)
                if bullet ~= nil and bullet:isDead() == false then
                    self.bulletList:get(i-1):update(unsdt)
                else
                    self:removeBullet(bullet)
                end
            end
        end
    end
end


return M