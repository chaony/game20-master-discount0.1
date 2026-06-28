--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-05-07 20:35:08
]]
---@class BattleLogData
---@class battleLogData @
local M = class("battleLogData")

function M:init()
    self.frameGap = GlobalTools.base1;
    self.logData = {};
    self.logData.data = {}
    self.frameTimelogData = {};
    self.openLog = GameVersionConfig.OPEN_BATTLE_LOG
end

--信息
function M:logBattleInfo( frame, player, param )
    if self.openLog == true then
        if frame % self.frameGap == 0 then
            self:write_point( frame, player, param )
        end
    end
end

--写入点
--frame 帧数
function M:write_point( frame, player, param )
    if self.openLog == true then
        self:getAllLog( frame, player, param )
        --self:getEasyLog( frame, player, param )
    end
end


function M:getEasyLog( frame, player, param  )
    self.logData.type = 1;
    --帧数
    local logFrame = GlobalTools:ToFloat( frame );
    --血量
    local logHp = player.data:get_curHp();
    --人物类型
    local logType = player.plyType;
    --人物阵营
    local logCamp = player.camp;
    --位置x
    local logPosX = player.position.x
    --位置y
    local logPosY = player.position.y
    --位置y
    local logPosZ = player.position.z
    --方向x
    local logDirX = player.position.x
    --方向y
    local logDirY = player.position.y
    --方向y
    local logDirZ = player.position.z
    --当前的随机数 index
    local logIndex = tostring( WRandom.common_index )

    local key = logFrame;
    if self.logData.data[key] == nil then
        self.logData.data[key] = "";
    end
    param = param or "--";
    local skillconfig = "nil"
    --技能名字
    if player.curSkillConfig ~= nil then
        skillconfig = player.curSkillConfig.anim_name;
    end
    --AI状态
    local key_state = "none";
    if player.aiEngine.curState ~= nil then
        key_state = player.aiEngine.curState.key;
    end

    local content = logFrame..","
            ..logType.."_"..logCamp..","
            ..logHp..","
            ..logPosX..","..logPosY..","..logPosZ..","
            ..logDirX..","..logDirY..","..logDirZ..","
            ..key_state..","
            ..logIndex..","
            ..skillconfig..","
            ..param..","
    self.logData.data[key] = self.logData.data[key]..content.."\n"
end



function M:getAllLog( frame, player, param  )
    self.logData.type = 0;
    --帧数
    local logFrame = GlobalTools:ToFloat( frame );
    --血量
    local logHp = player.data:get_curHp();
    --人物类型
    local logType = player.plyType;
    --人物阵营
    local logCamp = player.camp;
    --位置x
    local logPosX = player.position.x
    --位置y
    local logPosY = player.position.y
    --位置y
    local logPosZ = player.position.z
    --方向x
    local logDirX = player.position.x
    --方向y
    local logDirY = player.position.y
    --方向y
    local logDirZ = player.position.z
    --当前的随机数 index
    local logIndex = tostring( WRandom.common_index )

    local key = logFrame;
    if self.logData.data[key] == nil then
        self.logData.data[key] = "";
    end
    param = param or "--";
    local skillconfig = "nil"
    --技能名字
    if player.curSkillConfig ~= nil then
        skillconfig = player.curSkillConfig.anim_name;
    end
    --AI状态
    local key_state = "none";
    if player.aiEngine.curState ~= nil then
        key_state = player.aiEngine.curState.key;
    end

    local content = " [F: "..logFrame.."]"
            .." [name:"..logType.."_"..logCamp.."]"
            .." [hp:"..logHp.."]"
            .." [pos:".."("..logPosX..","..logPosY..","..logPosZ..")".."]"
            .." [dir:".."("..logDirX..","..logDirY..","..logDirZ..")".."]"
            .." [state:"..key_state.."]"
            .." [random:"..logIndex.."]"
            .." [skillconfig:"..skillconfig.."]"
            .." [param:"..param.."]"
    self.logData.data[key] = self.logData.data[key]..content.."\n"
end


function M:CompareNine( value )
    local value_str = ""
    if tonumber(value) < 9 then
        value_str = "0"..value
    else
        value_str = ""..value
    end
    return value_str;
end


--完成写入生成文件
function M:finish_write( fileName, log_data )
    if self.openLog == true then
        if self.logData.type == 1 then
            fileName = fileName.."_easy";
        end
        log_data = log_data or self.logData.data
        local jsonContent = ""
        local keys = table.keys(log_data)
        table.sort(keys,function(data1,data2)
            return tonumber(data1)<tonumber(data2);
        end)
        for k,v in ipairs(keys) do
            jsonContent = jsonContent..log_data[v].."\n";
        end
        local path = fileName..".json";
        io.writebattlelog(path,jsonContent);
    end
end

--local socket = require("socket")
local frame_begin_time = 0
local total_time = 0

--写入点
--frame 帧数
function M:frame_begin_write( frame)
    --if GameVersionConfig.OPEN_BATTLE_LOG == true then
    --    if frame == 0 then
    --        frame_begin_time = socket.gettime()
    --    end
    --    local start_time = socket.gettime()
    --    local diff_time = start_time - frame_begin_time
    --    total_time = total_time + diff_time
    --    --if diff_time > 0 then
    --        local key = tostring(frame);
    --        if self.frameTimelogData[key] == nil then
    --            self.frameTimelogData[key] = "";
    --        end
    --        local content = " [F: "..frame.."]" .." [diff_time :"..diff_time.."]"
    --        self.frameTimelogData[key] = self.frameTimelogData[key]..content.."\n"
    --        frame_begin_time = start_time
    --    --end
    --end
end

--完成写入生成文件
function M:finish_frame_write()
    --if GameVersionConfig.OPEN_BATTLE_LOG == true then
    --    local content = " [total_time: "..total_time.."]"
    --    self.frameTimelogData[10000] = content.."\n"
    --    self:finish_write("finish_frame_server", self.frameTimelogData)
    --end
end

return M;