---@class CurveManager_Model @曲线移动管理器
local M = class("CurveManager_Model")

--数据的list
M.curveList = nil

--玩家
M.player = nil

M.index = 0

--初始化
function M:init(player)
    self.player = player
    self.curveList = {}
    self.index = 0
end

--添加到list内
function M:add(curveData)
    if curveData["time"] > 0 then
        self.index = self.index + 1
        local list_curveData = {}
        list_curveData.index = self.index
        local type = curveData["type"]
        if type == nil or type == "" or type == "nil" then
            type = "line"
        end
        list_curveData.curveX = GlobalTools:GetCurve(type,false)
        list_curveData.curveY = GlobalTools:GetCurve(type,true)
        list_curveData.distance = curveData["distance"]
        list_curveData.time = curveData["time"]
        list_curveData.curTime = GlobalTools.base0;
        list_curveData.dir = FixVector3.New(0,0,0)
        list_curveData.dir.x = curveData["dir"].x
        list_curveData.dir.y = GlobalTools.base0--curveData["dir"].y
        list_curveData.dir.z = curveData["dir"].z
        table.insert(self.curveList, list_curveData)
    end
end

--update
function M:update(dt, unsdt)
    if table.nums(self.curveList) <= 0 then
        return
    end
    local pos = self.player.position
    for k,v in ipairs(self.curveList) do
        local lastTime = v.curTime
        v.curTime = GlobalTools:Min(v.curTime + dt, v.time)
        local lastProgress = GlobalTools:Div(lastTime, v.time);
        local progress = GlobalTools:Div(v.curTime, v.time);
        local curve_x = GlobalTools.base1;
        local last_curve_x = GlobalTools.base1;
        if v.curveX ~= nil then
            last_curve_x = v.curveX:Evaluate(lastProgress);
            curve_x = v.curveX:Evaluate(progress);
        end

        local curve_y = GlobalTools.base1;
        local last_curve_y = GlobalTools.base1;
        if v.curveY ~= nil then
            last_curve_y = v.curveY:Evaluate(lastProgress);
            curve_y = v.curveY:Evaluate(progress);
        end

        pos = pos + v.dir * (curve_x - last_curve_x) * v.distance
        pos.y = pos.y + curve_y - last_curve_y;
        if v.curTime >= v.time then
            self.curveList[k] = nil
        end
    end

    if SceneManager.curScene.getAreaPosition ~= nil then
        SceneManager.curScene:getAreaPosition(pos)
    end
    self.player:setPos(pos)
end


function M:destroy()
    self.artifact_list = {}
end

return M