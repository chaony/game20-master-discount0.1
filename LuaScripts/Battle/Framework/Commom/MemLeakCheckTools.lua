-- MemLeakCheckTools

local M = {}

local allWeakObjMap = {}
setmetatable(allWeakObjMap, {__mode = "k"})

local findedObjMap = nil

function M.findObject(obj, findDest)
    if findDest == nil then
        return false
    end
    if findedObjMap[findDest] ~= nil then
        return false
    end
    findedObjMap[findDest] = true

    local destType = type(findDest)
    if destType == "table" then
        if findDest == _G.CMemoryDebug then
            return false
        end
        for key, value in pairs(findDest) do
            if key == obj or value == obj then
                Logger.log("<color=yellow>Finded Object</color>" .. tostring(key) .. "-" .. tostring(value) .. "-" .. tostring(obj))
                return true
            end
            if M.findObject(obj, key) == true then
                Logger.log("<color=yellow>table key</color>")
                return true
            end
            if M.findObject(obj, value) == true then
                Logger.log("<color=yellow>key:["..tostring(key).."]</color>")
                return true
            end
        end
    elseif destType == "function" then
        local uvIndex = 1
        while true do
            local name, value = debug.getupvalue(findDest, uvIndex)
            if name == nil then
                break
            end
            if M.findObject(obj, value) == true then
                Logger.log("<color=yellow>upvalue name:["..tostring(name).."]</color>")
                return true
            end
            uvIndex = uvIndex + 1
        end
    end
    return false
end


function M.findObjectInGlobal(obj)
    findedObjMap = {}
    setmetatable(findedObjMap, {__mode = "k"})
    M.findObject(obj, _G)
end


function M.appendWeakObjMap(obj, id)
    if allWeakObjMap[obj] == nil then
        allWeakObjMap[obj] = os.time() .. id
        local num = table.nums(allWeakObjMap)
        Logger.log(tostring(obj), "<color=yellow> add weak obj ===> </color>" .. tostring(id) .. " len = " .. num .. " mem = " .. tostring(collectgarbage("count")/1024))
    else
        Logger.log(tostring(obj), "<color=yellow> t is exist ===></color>")
    end
end


function M.printWeakObjMap(print_search)
    local des_num = 0
    for k,v in pairs(allWeakObjMap) do
        --if k.isDestoryMe then
            des_num = des_num + 1
            Logger.log("------------------------------------------------------------------" .. des_num .. " ; v = " .. v .. " ; " .. tostring(k))
            if print_search then
                M.findObjectInGlobal(k)
            end
        --end
    end
    local num = table.nums(allWeakObjMap)
    Logger.log(tostring(num), "<color=yellow> allWeakObjMap len ===></color>")
end

return M