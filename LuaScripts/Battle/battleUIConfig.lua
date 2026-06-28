--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-02 13:48:46
]]

--战斗内UI的参数
return{
    --血条
    ["HpBar"] = {


    },
    --弹血的数字
    ["HpLabel"] = 
    {
        --普通攻击
        ["putong"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "spine",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0,
            ["TanTan02"] = 0,
            ["TanTan03"] = 0,
            ["TanTan04"] = 0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.4,
            --移动高度
            ["MoveHeight"] = 80,
            --消失时间
            ["DisappearTime"] = 0.8,
        },
        --暴击伤害
        ["baoji"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "spine",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.07,
            ["TanTan04"] = 0.07,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1.15,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.5,
            --移动高度
            ["MoveHeight"] = 40,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        --治疗
        ["zhiliao"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "spine",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.2,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.5,
            --移动高度
            ["MoveHeight"] = 65,
            --消失时间
            ["DisappearTime"] = 1,
        },
        --防御
        ["fangyu"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "spine",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0,
            ["TanTan02"] = 0,
            ["TanTan03"] = 0,
            ["TanTan04"] = 0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.4,
            --移动高度
            ["MoveHeight"] = 80,
            --消失时间
            ["DisappearTime"] = 0.8,
        },
        --能量
        ["nengliang"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "spine",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.0,
            ["TanTan02"] = 0.0,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.4,
            --移动高度
            ["MoveHeight"] = 65,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        --格挡
        ["gedang"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.5,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 1,
        },
        --闪避
        ["shanbi"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.5,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 1,
        },
        --免疫
        ["mianyi"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = false,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.5,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 1,
        },
        --地方杀人
        ["difang_kill"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 1.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.8,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        --我方杀人
        ["wofang_kill"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 2,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.0,
            ["TanTan04"] = 0.0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0.8,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        --2杀
        ["kill2"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 2.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.25,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0,
            ["TanTan04"] = 0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        --3杀
        ["kill3"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 2.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.25,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0,
            ["TanTan04"] = 0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        ["kill4"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 2.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.25,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0,
            ["TanTan04"] = 0,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.5,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 0.4,
        },
        ["kill5"] = 
        {
            --3个选项 
            --head 头部
            --spine 胸部
            --foot 脚部
            ["ShowPos"] = "head",
            --是否有弹弹的属性
            ["isTanTan"] = true,
            ["TanTanTarget"] = 2.5,
            ["TanTanHeight"] = 0,
            --弹性的4个时间属性
            ["TanTan01"] = 0.1,
            ["TanTan02"] = 0.1,
            ["TanTan03"] = 0.07,
            ["TanTan04"] = 0.07,
            --弹性的Scele值
            ["TanTanOffset01"] = 1.8,
            ["TanTanOffset02"] = 1,
            ["TanTanOffset03"] = 1.15,
            ["TanTanOffset04"] = 1,
            --等待时间
            ["WaitTime"] = 0,
            --移动时间
            ["MoveTime"] = 0,
            --移动高度
            ["MoveHeight"] = 0,
            --消失时间
            ["DisappearTime"] = 1,
        }
    }
}