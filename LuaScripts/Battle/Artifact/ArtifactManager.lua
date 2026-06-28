Artifact = require("Battle.Artifact.Artifact")

---@class ArtifactManager @神器管理器
local M = class("ArtifactManager")

--数据的list
M.dataList = nil

--玩家
M.player = nil

--神器的list
M.artifact_list = nil

--开始的标识
M.gamestart = false

M.aritface = nil
--初始化
function M:init(player)
    self.dataList = ConfigManager:getCfgByName("artifact");
    self.player = player
    self.artifact_list = {}
    self.artifact_id = Battle.List.new()
end

--添加到manager内
function M:add(id,aritface_lv)
    --do return end 
    if id ~= nil and aritface_lv ~= nil then
        local data = self.dataList[id]
        if data ~= nil then
            local level = data["level_up"]
            local fileName_base = "Battle.Artifact.Artifact"..id.."_"
            local fileName_lua = fileName_base
            for i = aritface_lv, 0, -1 do
                fileName_lua = fileName_base..i
                if Battle.ClassPathUtil:Exists(fileName_lua) then
                    self.aritface = require(fileName_lua).new()
                    self.artifact_list[id] = self.aritface
                    self.artifact_id:add(id)
                    self.aritface:init(self.player, level[aritface_lv]["param"])
                    self.aritface:gameStart()
                    break
                end
            end
        end
    end
end

--update
function M:update(dt, unsdt)
    if self.gamestart then
        for i = 1, self.artifact_id.Count do
            local id = self.artifact_id:get(i-1)
            local data = self.artifact_list[id]
            if data ~= nil then
                data:update(dt, unsdt)
            end
        end
    end
end

--查找某个ID的
function M:findById(id)
    return self.artifact_list[id]
end

--删除某个id的
function M:removeById(id)
    self.artifact_id:remove(id)
    if self.artifact_list[id] ~= nil then
        self.artifact_list[id]:destroy()
    end
    self.artifact_list[id] = nil
end
--删除
function M:remove(artifact)
    if artifact ~= nil then
        artifact:destroy()
        table.removebyvalue(self.artifact_list, artifact, true)
    end
    self.artifact_id:clear();
    self.artifact_id = nil;
end

--清空
function M:clear()
    self.artifact_list = {}
    self.artifact_id:clear();
end

--开始
function M:gameStart()
    self.gamestart = true
    for i = 1, self.artifact_id.Count do
        local id = self.artifact_id:get(i-1)
        local data = self.artifact_list[id]
        if data ~= nil then
            data:gameStart()
        end
    end
end

--结束
function M:gameover()
    self.gamestart = false
    for i = 1, self.artifact_id.Count do
        local id = self.artifact_id:get(i-1)
        local data = self.artifact_list[id]
        if data ~= nil then
            data:gameover()
        end
    end
end

function M:destroy()
    for i = 1, self.artifact_id.Count do
        local id = self.artifact_id:get(i-1)
        local data = self.artifact_list[id]
        if data ~= nil then
            data:destroy()
        end
    end
    self:clear()
end

return M
