---@class VerifyBattleData
---@field params BattleCheckParams @参数信息
local VerifyBattleData = class("VerifyBattleData")


---@class BattleCheckParams
---@field input_file string @输入文件名 不可缺省
---@field input_path string @输入文件目录 不可缺省
---@field output_path string @文件输出目录 不可缺省
---@field output_tag string @数据输出标签，如果有标签，会将数据写在子目录
---@field start_index number @数据起始index 默认为0
---@field target_index number @数据结束index 默认为-1]


---@param params BattleCheckParams
function VerifyBattleData:ctor(_, params)
    params.start_index = params.start_index or 0
    params.target_index = params.target_index or -1
    self.params = params
    self.targetIndex = params.target_index
    local data_path = string.format("%s/%s", params.input_path, params.input_file)
    self.lines = io.lines(data_path)
    self.index = params.start_index
    self.dataList = {}
    
    self:preloadData()
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()
    math.random()
end

function VerifyBattleData:preloadData()
    if self.targetIndex > 0 then
        for i = 1, self.targetIndex do
            local line = self.lines()
            if line then
                table.insert(self.dataList, line)
            else
                break
            end
        end
    else
        while true do
            local line = self.lines()
            if line then
                table.insert(self.dataList, line)
            else
                break
            end
        end
        self.targetIndex = #self.dataList
    end
end

function VerifyBattleData:getNext()
    if not self:haveNext() then
        return nil
    end
    
    self.index = self.index + 1
    local data = self.dataList[self.index]
    return self:convert2BattleData(data, self.index)
end

function VerifyBattleData:getNextTable()
    local data = self:getNext()
    if data then
        return Json.decode(data)
    end
    return nil
end

function VerifyBattleData:getCurrent()
    if self.index == 0 then
        self.index = 1
    end
    local data = self.dataList[self.index]
    return self:convert2BattleData(data, self.index)
end

function VerifyBattleData:haveNext()
    return self.index + 1 <= #self.dataList and self.index <= self.targetIndex
end

function VerifyBattleData:getRandomOne()
    local index = math.random(1, #self.dataList)
    return self:convert2BattleData(self.dataList[index], index)
end

function VerifyBattleData:convert2BattleData(sdata, index)
    local data = Json.decode(sdata)
    local battleData = data
    if battleData.battle_data then
        battleData = battleData.battle_data
    end
    battleData.__verify_data = data.verify_data
    battleData.index = index
    battleData.params = self.params
    --data.battle.client_input[1].autofight_operations =  {['0'] = {['autofight'] = true}}
    --data.battle.client_input[1].operations =  {}
    battleData = Json.encode(battleData)
    return battleData, sdata
end

--function VerifyBattleData:checkNext()
--    if not self.dataList[self.index + 1] then
--        local line = self.lines()
--        if line then
--            table.insert(self.dataList, line)
--        end
--    end
--end

return VerifyBattleData