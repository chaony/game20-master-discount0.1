--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

--数值混淆
XXX = {}

--改值
function XXX:changeValue( value )
    return value * 100 + 854
end

--反改值
function XXX:reChangeValue( value )
    return (value - 854) / 100
end

return XXX