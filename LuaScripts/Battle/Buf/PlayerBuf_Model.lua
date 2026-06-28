--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 15:39:48
]]

---@class PlayerBuf_Model : ModelBase @玩家的单个Buf
---@field data Battle_AddBuff_Data
---@field bufWork BufWork_Model
---@field parasiticBuffList PlayerBuf_Model[]
---@field triggerTag table<string, boolean> 触发信息
---@field sourceBuff PlayerBuf_Model 源buff 由buff创建的伴生，结束buff会有这个数据
---@field sourceType string number @ 1:来自技能  0:其他
local M = class("PlayerBuf_Model",Battle.ModelBase)

---@param data Battle_AddBuff_Data
---@param createData Battle_CreateBullet_Data
function M:init(data, createData)
    self:initCreateData(createData)
    self.data = data
    self.desc = data["buffDes"] or ""
    self.type = data["buffType"] or ""
    self.sourceType = createData.sourceType   -- 1:来自技能  0:其他
    --基础攻击力
    self.baseAtk = 0;
    --是否是 Dot Buf
    self.isDotBuf = false
    --buffId
    self.buffId = data.buff_id
    self.buffData = data.bufData
    --延迟时间
    self.delayTime = data["delayTime"]
    --生效时间
    self.workTime = data["workTime"]
    --持续时间
    self.lastTime = data["lastTime"]
    --生效次数 1 
    self.workRound = data["workRound"]
    --最大叠加数量 1
    self.max_times = data["max_times"] or GlobalTools.base1
    --声音名字
    self.audioName = data["audio"]
    --buffIcon
    self.buffIcon = data["buff_icon"]
    --是否显示buffIcon计数
    self.is_bufficon_count = data["is_bufficon_count"] or {}

    self.triggerTag = {}
    self.groupId = data["group_id"]
    self.level = data["level"]
    self.curLevel = self.level
    local extraBuff = data["extra_buff"] or {}
    self.extraBuff = {}
    local extraBuffType = ""
    for k,v in ipairs(extraBuff) do
        if type(v) == "string" then
            if self.extraBuff[v] == nil then
                self.extraBuff[v] = {}
            end
            extraBuffType = v
        else
            table.insert(self.extraBuff[extraBuffType], v)
        end
    end
    self.effect_id = data["effect_id"]
    --self.effect = data["buffEffect"]
    if data["buffParam"] ~= nil then
        self.param = table.copy(data["buffParam"])
        --Logger.logError(" 加入buffId = "..self.id )
        --Logger.logError(self.param," buf 参数 ~~~~ ")
    end
    self.tag = table.copy(data["buffTags"])
    self.tagExtra = table.copy(data["buffExtraTags"] or  {})
  
    self.parasiticBuffList = {}
    --buf状态
    self.mState = 0
    --当前的延迟时间
    self.curDelayTime = 0
    --当前的生效时间
    self.curWorkTime = 0
    --当前的持续时间
    self.curLastTime = 0
    --当前的生效次数
    self.curRound = 0
    --是否生效
    self.isWork = false
    --Buf的数据层创建完成,通知视图层
    self.player:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelCreateFinish, self);
end

--初始化创建数据
---@param createData Battle_CreateBuf_Data
function M:initCreateData( createData )
    self.id = createData.id
    self.sourceSkill = createData.sourceSkill
    self.sourceBuff = createData.sourceBuff
    self.mgr = createData.mgr
    self.player = createData.player;
    self.source = createData.source;
    self.skillMode = createData.skillMode
end

--buf开始运作
function M:start()
    self.curDelayTime = self.delayTime;
    --buf 真正的生效类
    local bufwork_lua = "Battle.Buf.BufWork"..self.type.."_Model";
    --Logger.logError(" buf 生效类 ~~~~ "..bufwork_lua )
    local has = Battle.ClassPathUtil:Exists(bufwork_lua)
    if has == true then
        self.bufWork = require(bufwork_lua).new()
        if self.bufWork ~= nil and self.player ~= nil then
            self.bufWork:init( self, self.type );
        end
        
        self.curWorkTime = self.workTime;
        --控制buf 和 魅惑buf
        --控制技能时长 = buff时长*(1-(坚韧值-坚韧抗性值)/坚韧系数)
        if self.type == "Imprison" or  self.type == "Charm" then
            local rediscontrol = 0
            if self.source ~= nil then
                rediscontrol = self.source.data.rediscontrol:getValue()
            end
            local control_value = self.player.data.discontrol:getValue() - rediscontrol
            if control_value > 0 then
                --self.curLastTime = self.lastTime * (1 - (control_value/self.player.data.discontrol_value));
                local control_rate = GlobalTools:Div(control_value,self.player.data.discontrol_value)
                self.curLastTime = GlobalTools:Mul(self.lastTime, (GlobalTools.base1 - control_rate));
                if self.curLastTime <= 0 then
                    self.curLastTime = 0;
                end
            else
                self.curLastTime = self.lastTime;
            end
        else
            self.curLastTime = self.lastTime;
        end
        
        --发送本地事件，buf 刷新Icon
        self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelRefreshIcon);
        self:reset(true)

        EventDispatcher:dipatchEvent("addBuff",{ buff = self })
        for k,v in ipairs(self.tag) do
            EventDispatcher:dipatchEvent("add_"..v,{ buff = self })
        end
        if self:checkTag("debuff") then
            EventDispatcher:dipatchEvent("debuffCount",{ ply = self.player, operator = "+", value = 1, type = "self", ignoreSkills = {}, breakAnim = true})
        end
        
        if self.delayTime == 0 then
            self:next();
            self:checkExtraBuff("parasitic")
            --buf 播放声音
            self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelPlayAudio);
        end
    else
        Logger.logError("生效的类没有找到哦"..tostring(self.type).." self.buffId "..tostring(self.buffId) )
    end
end

function M:get_id()
    return self.id
end

function M:get_source()
    return self.source
end

--buff的icon
function M:get_buffIcon()
    return self.buffIcon;
end

function M:get_showBuffIconCount()
    return self.is_bufficon_count
end

--buff的音效
function M:get_audioName()
    return self.audioName;
end

function M:get_buff_id()
    return self.buffId
end

function M:get_effect_id()
    return self.effect_id;
end

--刷新buf，重新开始执行
---@param data Battle_AddBuff_Data
function M:reset(isStart, data)
    if isStart then
        self.curRound = 0;
        self:playEffect("startPlay")
    else
        self.curRound = 0;
        if data ~= nil then
            self.desc = data["buffDes"]
            --self.effect = data["buffEffect"]
            self.param = data["buffParam"]
            self.tag = table.copy(data["buffTags"])
            self.extraBuff = table.copy(data["buffExtraTags"] or {})
        end
        if self.type == "Dot" then
            self:checkExtraBuff("parasitic")
        end
    end
    self.bufWork:reset();
    self.mState = 1;
    local effect_id = nil;
    if data ~= nil and data.effect_id ~= nil then
        effect_id = data.effect_id;
    end
    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelReset,{ effect = effect_id })
end

--伴生buff
function M:checkExtraBuff(type)
    if self.extraBuff[type]~= nil then
        for k,v in ipairs(self.extraBuff[type]) do
            local buff = self.mgr:addBufById(v, self.source, self.sourceSkill, self)
            if buff ~= nil and type == "parasitic" then
                table.insert(self.parasiticBuffList, buff)
                --增加伴生buff标志
                buff.isParasitic = true
            end
        end
    end
end

--设定基础攻击力
function M:setBaseAtk(atk)
    self.baseAtk = atk
end

--获取基础攻击力
function M:getBaseAtk()
    return self.baseAtk
end

--获取最大叠加数量
function M:get_max_times()
    return self.max_times;
end

--buf运作中
function M:update(time)
    --如果在大招状态
    local running = self.isDotBuf == false;

    if self.source ~= nil then
        if self.skillMode == 0 and self.source:inBlackTime() then
            running = false
        end
    end
    if running then
        if self.mState == 1 then
            --延迟
            if self.curDelayTime > 0 then
                self.curDelayTime = self.curDelayTime - time
                if self.curDelayTime <= 0 then
                    self:next();
                    self:checkExtraBuff("parasitic")
                    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelPlayAudio);
                end
            else
                if self.bufWork ~= nil then
                    self.bufWork:update(time)
                end
                
                if self.isWork then
                    --持续生效阶段
                    self.curLastTime = self.curLastTime - time
                    if self.curLastTime <= 0 then
                        self:workEnd()
                        if self.curRound >= self.workRound then
                            self.mgr:removeBuf(self)
                        else
                            self.curWorkTime = self.workTime
                        end
                    end
                else
                    --等待阶段
                    self.curWorkTime = self.curWorkTime - time
                    if self.curWorkTime <= 0 then
                        if self.curRound >= self.workRound then
                            self.mgr:removeBuf(self)
                        else
                            self:next()
                            self.curLastTime = self.lastTime
                        end
                    end
                end
    
            end
        end
    end
end

--增加持续时间
function M:addLastTime( time )
    self.lastTime = self.lastTime + time
    self.curLastTime = self.lastTime
end

--设置持续时间
function M:setCurLastTime(time)
    self.curLastTime = time
end

--生效一次
function M:next()
    self:work();
    self.curRound = self.curRound + 1
    self.isWork = true
end

--生效
function M:work()
    if self.bufWork ~= nil then
        self.bufWork:work()
        --发送本地事件，buf开始运行
        self:playEffect("workPlay")
    end
end

--生效结束
function M:workEnd()
    self.isWork = false
    if self.bufWork ~= nil then
        self.bufWork:workEnd()
    end
end

function M:triggerBuffImmediately(remove, isBreak)
    isBreak = isBreak or false
    self:work()
    if remove then
        self.mgr:removeBuf(self, isBreak)
    end
end

function M:triggerDelayBuffImmediately(remove, isBreak)
    isBreak = isBreak or false
    local workTimes = self.workRound - self.curRound
    if workTimes > 0 then
        for i = 1, workTimes do
            self:work()
        end
    end
    if remove then
        self.mgr:removeBuf(self, isBreak)
    end
end

function M:addTriggerTag(tag)
    if self.triggerTag[tag] then
        Logger.logError(tag, "添加了重复的tag")        
    end
    self.triggerTag[tag] = true
end

function M:removeTriggerTag(tag)
    if self.triggerTag[tag] then
        Logger.logError(tag, "添加了重复的tag")
    end
    self.triggerTag[tag] = nil
end

function M:haveTriggerTag(tag)
    return self.triggerTag[tag] == true
end

--buf结束运作
function M:stop(isBreak)
    self.mState = -1
    EventDispatcher:dipatchEvent("removeBuff",{ buff = self })

    for k,v in ipairs(self.tag) do
        EventDispatcher:dipatchEvent("remove_"..v,{ buff = self })
    end
    
    if self:checkTag("debuff") then
        EventDispatcher:dipatchEvent("debuffCount",{ ply = self.player, operator = "-", value = 1, type = "self", ignoreSkills = {}})
    end

    if isBreak ~= true then
        --创建结束时触发的buff，清除伴生buff
        self:checkExtraBuff("end")
        if self.parasiticBuffList ~= nil then
            for k,v in ipairs(self.parasiticBuffList) do
                if v ~= nil and v.mState == 1 then
                    v:stop()
                end
            end
        end
    end
    --停止播放声音
    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelStopAudio);
    --删除特效
    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelDeleteEffect);
    --删除特效
    if self.bufWork ~= nil and self.player ~= nil then
        self.bufWork:stop();
        --播放结束特效
        self:playEffect("endPlay")
    end
end


function M:playEffect( key )
    local data = {}
    data.key = key
    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelPlayEffect, data);
end


function M:removeEffect()
    self:dispatchEvent_Local(Battle.EventType.MV_PlayerBufModelDeleteEffect);
end


function M:checkParam(param, default)
    local result = {}
    if self.param ~= nil then
        for k,v in ipairs(self.param) do
            for k1,v1 in ipairs(v) do
                if v1[1] == param then
                    table.insert(result, v1[2])
                end
            end
        end
    end
    if #result == 0 then
        return default
    elseif #result == 1 then
        return result[1]
    else
        return result
    end
end

function M:addParam( key,value )
    if self.param[1] == nil then
        self.param[1] = {}
    end
    for k,v in ipairs(self.param[1]) do
        if v[1] == key then
            v[2] = value
            return
        end
    end
    local data = {key, value}
    table.insert(self.param[1], data)
end

function M:checkTag(tag)
    for k,v in ipairs(self.tag) do
        if v == tag then
            return true
        end
    end
    return false
end

function M:checkExtraTag(tag)
    for k,v in ipairs(self.tag) do
        if v == tag then
            return true
        end
    end
    return false
end

function M:upgrade(param, level)
    self.bufWork:upgrade(param)
    if self.param ~= nil then
        for k,v in pairs(self.param) do
            v[3][2] = param[k][3][2]
        end
    end
    self.curLevel = level
end

return M