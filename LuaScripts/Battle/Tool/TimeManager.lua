--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-18 13:45:18
]]
---@class TimeManager
local M = class("TimeManager")
--时间缩放值
M.timeScale = GlobalTools.base1;
-- 0.0016 60帧的更新时间
-- 0.0033 30帧的更新时间
--TimeManager.baseUpdateDelaTime = 0.033;
--TimeManager.baseUpdateDelaTime = 0.066;
M.baseUpdateDelaTime = GlobalTools.base0_1;
M.fightUpdateDelteTime = GlobalTools.base0_1;
M.hangUpUpdateDelteTime = GlobalTools.base0_0_3_3;
-- 定点数 1
M.timeSpeed = GlobalTools.base1;
-- 1倍速 速度
M.defaultTimeSpeed = GlobalTools.base1;
-- 2倍速 速度
M.maxTimeSpeed = GlobalTools.base2;
-- 4倍速 速度
M.maxmaxTimeSpeed = GlobalTools.base4;
-- 停止循环 速度
M.stopTimeSpeed = GlobalTools.base0;

function M:init()
    --双倍
    local data = ConfigManager:getBattleCommonValueById(259,0, true);
    --单倍
    local base_data = ConfigManager:getBattleCommonValueById(277,0, true);
    --4倍
    local max_data = ConfigManager:getBattleCommonValueById(260,0, true);
    --最大双倍速度
    self.maxTimeSpeed = data
    --最大4倍速度
    self.maxmaxTimeSpeed = max_data
    --默认速度
    self.defaultTimeSpeed = base_data
    --数据发送到视图
    self.modelToViewData = {}
    --设定基础的循环 时间间隔
    self:set_baseUpdateDelaTime(self.fightUpdateDelteTime)
    --设定基础时间速度
    self:set_timeSpeed(self.defaultTimeSpeed)
    --设计时间缩放值
    self:set_timeScale(GlobalTools.base1);
    --设定本地速度
    self:set_localSpeed(GlobalTools.base1)
end

--重新设置
function M:reset()
    --设计时间缩放值
    self:set_timeScale(GlobalTools.base1);
    --设定基础时间速度
    self:set_timeSpeed(self.defaultTimeSpeed)
    self:set_timePause(GlobalTools.base1);
end

--暂停
function M:pause()
    --设计时间缩放值
    self:set_timeScale(GlobalTools.base0);
    --把速度也设置成0
    self:set_timePause(GlobalTools.base0)
end

--设定存在本地的速度
function M:set_localSpeed(value)
    self.localTimeSpeed = value;
    self:refreshTimeSpeed();
end

function M:get_localSpeed()
    return self.localTimeSpeed;
end

function M:get_defaultSpeed()
    return self.defaultTimeSpeed
end

function M:get_maxSpeed()
    return self.maxTimeSpeed
end

--刷新时间速度
function M:refreshTimeSpeed()
    self:set_timeSpeed(self.localTimeSpeed)
end

--设定基础的更新时间 SetBaseUpdateDelaTime
function M:set_baseUpdateDelaTime( value )
    self.baseUpdateDelaTime = value;
    self.modelToViewData.baseUpdateDelaTime = value;
    self:setEvent();
end

--获取基础的更新 时间
function M:get_baseUpdateDelaTime()
    return self.baseUpdateDelaTime
end

--设定时间速度 控制2倍速使用的
function M:set_timeSpeed(value)
    self.timeSpeed = value;
    self.modelToViewData.timeSpeed = value;
    self:setEvent();
end

function M:set_timePause(value)
    self.timePause = value;
    self.modelToViewData.timePause = value;
    self:setEvent();
end

--返回当前的速度
function M:get_timeSpeed()
    return self.timeSpeed;
end

--设定时间缩放值 人物大招使用的
function M:set_timeScale(value)
    self.timeScale = value;
    self.modelToViewData.timeScale = value;
    self:setEvent();
end

--返回时间缩放值
function M:get_timeScale()
    return  self.timeScale
end

--发送时间到视图层
function M:setEvent()
    if SceneManager.MV_EventMgr ~= nil then
        SceneManager.MV_EventMgr:dispatchEvent(Battle.EventType.MV_TimeManagerSetTime, self.modelToViewData);
    end
end

--返回时间 循环的帧数 * 基础更新时间 TimeManager.Time(
function M:time()
    return GlobalTools:Mul( SceneManager.curScene:get_runframe(), self:deltaTime() );
end

--差值时间，受 时间缩放值 影响的 DeltaTime
function M:deltaTime()
    return GlobalTools:Mul( self.baseUpdateDelaTime, self.timeScale );
end

--差值时间 不受 时间缩放值 影响
function M:unscaleDeltaTime()
    return self.baseUpdateDelaTime;
end

return M;