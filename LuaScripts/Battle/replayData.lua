--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-13 10:59:37
]]
return
{
    --服务器运算或者战斗回放
    ["output"] = 
    {                
        ["rounds"] = 
        {
            [1] = 
            {
                ["round"] = 1,
                ["result"] = 0,
                ["attacker_team"] = 
                {
                    ["team"] = 
                    {
                        [1] = "9-1585008848-oDALG8",
                        [2] = "6-1585008848-uBl5QO",
                        [3] = "",
                        [4] = "",
                        [5] = "",
                    },
                    ["heros"] = 
                    {
                        ["9-1585008848-oDALG8"] =
                        {
                            ["attrs"] = 
                            {
                                ["atk"] = 457.92,
                                ["def"] = 44.52,
                                ["hp"] = 7108.36,
                            },
                            ["clv"] = 0,
                            ["combat"] = 0,
                            ["evo"] = 0,
                            ["lv"] = 1,
                        },
                        ["6-1585008848-uBl5QO"] =
                        {
                            ["attrs"] = 
                            {
                                ["atk"] = 481.24,
                                ["def"] = 44.52,
                                ["hp"] = 6423.6,
                            },
                            ["clv"] = 0,
                            ["combat"] = 0,
                            ["evo"] = 0,
                            ["lv"] = 1,
                        }
                    },
                    --动态值
                    ["dyns"] =
                    {              
                        ["hero_oid"] = 
                        {
                            ["hp_pct"] = 0,
                            ["mp_pct"] = 0,
                            ["param"] =  0,
                        },
                    },
                },
                ["defender_team"] = 
                {
                    ["team"] = 
                    {
                        [1] = "22-1585071143-zLijd8",
                        [2] = "22-1585071143-htBhzZ",
                        [3] = "",
                        [4] = "8-1585071143-hGyicp",
                        [5] = "",
                    },
                    ["heros"] = 
                    {
                        ["22-1585071143-zLijd8"] =
                        {
                            ["attrs"] = 
                            {
                                ["atk"] = 481,
                                ["def"] = 481,
                                ["hp"] = 481,
                            },
                            ["clv"] = 0,
                            ["combat"] = 0,
                            ["evo"] = 0,
                            ["lv"] = 1,
                        },
                        ["22-1585071143-htBhzZ"] =
                        {
                            ["attrs"] = 
                            {
                                ["atk"] = 481,
                                ["def"] = 481,
                                ["hp"] = 481,
                            },
                            ["clv"] = 0,
                            ["combat"] = 0,
                            ["evo"] = 0,
                            ["lv"] = 1,
                        },
                        ["8-1585071143-hGyicp"] =
                        {
                            ["attrs"] = 
                            {
                                ["atk"] = 481,
                                ["def"] = 481,
                                ["hp"] = 481,
                            },
                            ["clv"] = 0,
                            ["combat"] = 0,
                            ["evo"] = 0,
                            ["lv"] = 1,
                        }
                    },
                    ["dyns"] =
                    {                
                        ["hero_oid"] =
                        {
                            ["hp_pct"] = 0,
                            ["mp_pct"] = 0,
                            ["param"] = 0,
                        },
                    },
                },
                --操作
                ["operations"] = 
                {      
                    --第几次循环  
                    ["104"] = 
                    {   
                        ["ops"] = 
                        {

                        },       
                    },
                },
                ["attacker_stats"] = 
                {   --攻击者统计
                    ["hero_oid"] = 
                    {
                        ["hp_pct"] = 0,
                        ["mp_pct"] = 0,
                        ["param"] = 0,
                        ["damage"] = 0,
                        ["kill"] = 0,
                        ["heal"] = 0,
                        ["defend"] = 0,
                    },
                },
                --防守者统计
                ["defender_stats"] = 
                { 
                    ["hero_oid"] = 
                    {
                        ["hp_pct"] = 0,
                        ["mp_pct"] = 0,
                        ["param"] = 0,
                        ["damage"] = 0,
                        ["kill"] = 0,
                        ["heal"] = 0,
                        ["defend"] = 0,
                    },
                }
            }
        }
    }
}