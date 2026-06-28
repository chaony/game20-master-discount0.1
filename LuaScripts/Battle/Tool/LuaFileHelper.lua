--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-14 16:55:12
]]

LuaFileHelper = {}

function LuaFileHelper:hasFile( name )
    if ClassPathConfig[name] ~= nil then
        return true
    end
    return false
end


return LuaFileHelper