--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:33:20
]]

--技能帧
---@class SkillFrame @
local M = class("SkillFrame")

--表现预制体
M.obj = nil
--是否完成
M.finish = false
--玩家
M.player = nil
--数据
M.data = nil
--触发时间
M.triggerTime = nil
--目标类型
M.target = nil
--详细目标类型
M.specificTarget = nil
--伤害百分比
M.attackDmg = nil
--持续时间
M.continueTime = nil
--特效作用类型
M.behave = nil
--是否是增益技能
M.tuneup = false
--[[
    @desc: 初始化技能 
    author:{author}
    time:2020-01-10 10:22:43
    --@skillData: 
    @return:
]]
function M:init(player,data)
    self.player = player
    self.finish = false;
    self.obj = data["prefab"]
    self.triggerTime = data["triggerTime"]
    self.target = data["target"]
    self.specificTarget = data["specificTarget"]
    self.attackDmg = data["attackDmg"]
    self.continueTime = data["continueTime"]
    self.behave = data["behave"]
    self.tuneup = data["toneup"]
end

function M:update(dt,unsdt)
    
end
--选择攻击目标模式
function  M:selectTargetMode()
    if self.specificTarget == "distanceRecently" then     --距离最近
    
    elseif self.specificTarget == "distanceFarthest" then --距离最远
    
    elseif self.specificTarget == "bloodLeast" then       --血量最少
    
    elseif self.specificTarget == "bloodMax" then         --血量最多
    
    elseif self.specificTarget == "oppositeTarget" then   --对位目标
    
    elseif self.specificTarget == "forceMax" then         --战力最高
    
    elseif self.specificTarget == "forceLeast" then       --战力最低

    elseif self.specificTarget == "frontrow" then         --前排

    elseif self.specificTarget == "backrow" then          --后排

    elseif self.specificTarget == "possessor" then        --所有人
    
    end

end

function M:destroy()
    self.finish = true
    if self.obj ~= nil then
        ResourceUtil:ReturnItem(self.obj)
    end
end

return M