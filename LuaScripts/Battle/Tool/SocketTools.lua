--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-30 10:22:16
]]
socket = require("socket")
local SocketTools = {}
SocketTools.timePool = {}
SocketTools.framePool = {}

function SocketTools:getFunctionTime( func )
    local g_start = socket.gettime()
    if func ~= nil then
        func();
    end
    local g_end = socket.gettime()
    local time = g_end - g_start
    print(" 战斗消耗时间 "..time );
end

--开始时间
function SocketTools:beginTime( name )
    local g_start = socket.gettime()
    if SocketTools.timePool[name] == nil then
        SocketTools.timePool[name] = {}
        SocketTools.timePool[name].start = g_start;
    else
        Logger.logError(" Error : 已经有一个 名字叫 ".. name );
    end
end

--结束时间
function SocketTools:endTime( name )
    local g_end = socket.gettime()
    local g_start = socket.gettime();
    if SocketTools.timePool[name] ~= nil then
        g_start = SocketTools.timePool[name].start;
        SocketTools.timePool[name] = nil;
    end
    local time = g_end - g_start
    Logger.log("[ ".. name.." ] >>>> ".." 消耗时间 "..time );
end

function SocketTools:logFrameBegin( frame )
    local g_start = socket.gettime();
    SocketTools.framePool[frame] = {start = g_start}
end

function SocketTools:logFrameEnd( frame )
    local g_end = socket.gettime()
    SocketTools.framePool[frame].endTime = g_end;
    local time = g_end - SocketTools.framePool[frame].start
    SocketTools.framePool[frame].time = time;
    SocketTools.framePool[frame].frame = frame;
end

function SocketTools:logFrameData()
    Logger.log( SocketTools.framePool," FramePool ");
    local json = Json.encode(SocketTools.framePool)
    local path = "LuaScripts/SyncData/framePool.json";
    Logger.log( json );
    io.writefile(path,json,1);
end

return SocketTools;