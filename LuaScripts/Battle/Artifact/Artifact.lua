---@class Artifact @神器基类
local M = class("Artifact")

M.param = nil

M.artiface_mgr = nil

M.player = nil
--初始化
function M:init(player,data)

    self.player = player
    self.param = data
end


function M:getValue(index)
    local value = self.param[index]
    if value ~= nil then
        return tonumber(value)
    else
        Logger.logError("无此参数", "神器id："..self.__cname .. "；参数编号：" .. index)
        return 0
    end
end

function M:update(dt, unsdt)

end

--开始
function M:gameStart()
    
end

--结束
function M:gameover()
   
end

function M:addSkillBuf()
    
end

function M:destroy()

end

return M