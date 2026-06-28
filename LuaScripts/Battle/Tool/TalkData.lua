--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-28 18:43:09
]]

---@class TalkData @
local M = class("TalkData")

function M:getDataByHeroID( heroID, type )
    local datas = Battle.List.new()
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        if v["type"] == type and v["hero_detail_id"] == heroID then
            datas:add(v)
        end
    end
    return datas
end


function M:getDataByType( type )
    local datas = Battle.List.new()
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        if v["type"] == type then
            datas:add(v)
        end
    end
    return datas
end

function M:getRandomCV(heroId)
    local cv_datas = {}
    local no_cv_datas = {}
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        if v["type"] == 3 and v["hero_detail_id"] == heroId then
            if v['se_id']~= '' then
                table.insert(cv_datas,v)
            else
                table.insert(no_cv_datas,v)
            end
        end
    end
    if #cv_datas > 0 then
        return  cv_datas[math.random(#cv_datas)]
    else
        if #no_cv_datas == 0  then
            return nil
        else
            return no_cv_datas[math.random(#no_cv_datas)]
        end
    end
end


return M