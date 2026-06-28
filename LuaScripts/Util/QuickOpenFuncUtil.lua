 ------------------- QuickOpenFuncUtil

local M = {}

local __funcs = {}

-- 前往主页 1 上阵
__funcs[1] = function(control, data, ext)
	control:updateMsg("switch_main_tab", {index = 1})
end

-- 前往主页 2 门派
__funcs[2] = function(control, data, ext)
    control:updateMsg("switch_main_tab", { index = 2})
end

-- 前往主页 3 狭义
__funcs[3] = function(control, data, ext)
    control:updateMsg("switch_main_tab", { index = 3})
end

-- 前往主页 4 恩怨
__funcs[4] = function(control, data, ext)
    control:updateMsg("switch_main_tab", { index = 4})
end

-- 前往主页 5 英雄列表
__funcs[5] = function(control, data, ext)
    control:openView("HeroBag", {mode = 1})
end

-- 前往主页 6 背包
__funcs[6] = function(control, data, ext)
    control:updateMsg("switch_main_tab", { index = 6})
end

-- 大圣堂 进阶
__funcs[7] = function(control, data, ext)
	control:openView("Advanced", ext)
end

-- 分解
__funcs[8] = function(control, data, ext)
	control:openView("Coach")
end

-- 酒馆
__funcs[9] = function(control, data, ext)
	control:openView("Pub")
end

-- 五行阵
__funcs[10] = function(control, data, ext)
    if SceneManager.curScene.sceneId == SceneManager.SceneID.WuXingZhenScene then
        control:openView("Fivelines")
    else
     --   control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
      --      if open_flag == "open_view" then
                control:openView("Fivelines")
      --      end
      --  end })
    end
end

-- 好友
__funcs[11] = function(control, data, ext)
    control:openView("Friend", ext)
end

-- 普通商品 
__funcs[12] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", {shop_type = 1})
end

-- 公会商店
__funcs[13] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", { shop_type = 2})
end

-- 遣散商店
__funcs[14] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", { shop_type = 3})
end

-- 迷宫商店
__funcs[15] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", { shop_type = 4})
end

-- 个人悬赏
__funcs[16] = function(control, data, ext)
    control:openView("Reward")
end

-- 团队悬赏
__funcs[17] = function(control, data, ext)
    --control:openView("BountyMissions", { cur_type = 2})
end

-- 迷宫
__funcs[18] = function(control, data, ext)
    if data and type(data) == "table" and data[2] then
        control:openView("MazeStage",{data = data[2]})
        return
    end
    local function netDataCallBack(response)
        if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
            if SceneManager.curScene.sceneId == SceneManager.SceneID.MiGongScene then
                control:openView("MazeStage",{data = response})
            else
                --  control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
                --     if open_flag == "open_view" then
                control:openView("MazeStage",{data = response})
                --     end
                --  end })
            end
        else
            --到时候需要判断是否需要打开这个界面
            control:openView("MazeStage.MazeStageChoice",{data = response} );
        end
    end
    control.m_model:getNetData("maze_index", nil, netDataCallBack);
end

-- 奇境探险
__funcs[19] = function(control, data, ext)

end

-- 时光之巅
__funcs[20] = function(control, data, ext)

end

-- 共享水晶
__funcs[21] = function(control, data, ext)
    control:openView("ShareLv")
end

-- 排行榜
__funcs[22] = function(control, data, ext)
    -- control:openView("Rank.RankList")
    control:openView("Rank.RankMain")
end

-- 公会
__funcs[23] = function(control, data, ext)
    control:updateMsg("openUnion")
end

-- 竞技场  英雄擂
__funcs[24] = function(control, data, ext)
    control:openView("Arena.ArenaNormal.ArenaNormal")
end

-- 高阶竞技场
__funcs[25] = function(control, data, ext)
    control:openView("Arena.ArenaHigher.ArenaHigher")
end

-- 巅峰竞技场
__funcs[26] = function(control, data, ext)
    
end

-- 任务
__funcs[27] = function(control, data, ext)
    control:openView("Task")
end

-- 藏经阁
__funcs[28] = function(control, data, ext)
     -- control:openView("Mystic")
    control:openView("SutraDepository", ext)
end

-- 世界boss
__funcs[29] = function(control, data, ext)
    control:openView("Activities.WorldBoss", ext)
    -- control:openView("UnionBoss")
end

-- 挂机奖励
__funcs[30] = function(control, data, ext)
    control:updateMsg("guaji_box")
end


-- 快速挂机
__funcs[31] = function(control, data, ext)
    control:updateMsg("guaji_btn")
end

 -- 天机楼
 __funcs[32] = function(control, data, ext)
     control:openView("Budo")
 end
 

 -- 江湖
 __funcs[33] = function(control, data, ext)
    control:openView("WorldMap.WorldMapMain")
end

 -- 江湖
 __funcs[34] = function(control, data, ext)
     control:openView("Legend")
 end

 -- 工会战
 __funcs[35] = function(control, data, ext)
     -- 23:00-0:00不让进战场
     local cur_time = TimeUtil.gmTime(UserDataManager:getServerTime())  --服务器时间    
     --local day, hour, min, sec = GameUtil:getTimeLayoutBySecond(cur_time)
     if cur_time.hour >= 23 then
         GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("UnionWar_str_041"), delay_close = 2})
         return
     end
     
     local function netDataCallBack(response)
         --if response.finish == 0 and response.cells ~= nil and _G.next(response.cells) ~= nil then
             if SceneManager.curScene.sceneId == SceneManager.SceneID.UnionWarScene then
                 control:openView("UnionWar.UnionWarMain", response)
             else
                 --control:openView("Loading.BattleLoading", {callfunc = function(open_flag)
                 --    if open_flag == "open_view" then
                         control:openView("UnionWar.UnionWarMain", response)
                 --    end
                 --end })
             end
         --end         
     end
     control.m_model:getNetData("gvg_battle_field", nil, netDataCallBack);
 end

 -- 竞技场  种族竞技场
__funcs[36] = function(control, data, ext)
    control:openView("Arena.ArenaRace.ArenaRace")
end
 
 -- 快速打开 竞技场和种族竞技场
 __funcs[37] = function(control, data, ext)
     control:openView("Arena.ArenaSelectMain")
 end

 -- 迷宫-选择页
 __funcs[38] = function(control, data, ext)
     control:openView("MazeStage.MazeStageChoice",{data = data[2]})
 end

 -- 主界面 挑战
 __funcs[39] = function(control, data, ext)
     control:updateMsg("challenge_btn")
 end
 
-- 聚宝山
__funcs[41] = function(control, data, ext)
    --开服的日期
    local open_server_date = UserDataManager.server_data:getServerOpenTime();
    --当前服务器日期
    local cur_server_date = TimeUtil.gmTime(UserDataManager:getServerTime())
    local day = 0
    --如果当前服务器和开服是同一年
    if open_server_date.year == cur_server_date.year then
        day = 3 - cur_server_date.yday - open_server_date.yday;
    end

    if day <= 0 then
        control:openView("JuBaoShan")
    else
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("worldMap_str_009", day), delay_close = 2})
    end
end

 --  聚宝山商店
 __funcs[42] = function(control, data, ext)
     control:closeView("Shop")
     control:openView("Shop", { shop_type = 11})
 end

 -- 不关闭界面的跳转普通商品 
 __funcs[43] = function(control, data, ext)
     control:closeView("Shop")
     control:openView("Shop", {shop_type = 1})
 end
 
 __funcs[71] = function(control, data, ext)
     if ext == nil then
         control:openView("Predestined")
     else
         control:openView("Predestined", {pool_id = ext.pool_id})
     end
 end

 --轮盘
 __funcs[72] = function(control, data, ext)
     control:openView("Compass")
     local red_point_flag = RedPointUtil:isFuncRedPointById(142)
     local open_compass_time = UserDataManager.local_data:getUserDataByKey("open_compass_time", nil)
     if open_compass_time == nil and red_point_flag then
         UserDataManager.local_data:setUserDataByKey("open_compass_time", UserDataManager:getServerTime())
     end
 end

-- 四象浮屠
__funcs[73] = function(control, data, ext)
    GameUtil:lookInfoTips(control, {msg = Language:getTextByKey("new_str_0055"), delay_close = 2})
end

 -- 论剑商城
 __funcs[74] = function(control, data, ext)
    control:closeView("Shop")
     control:openView("Shop", { shop_type = 8})
 end

 -- 盗帅礼包
 __funcs[75] = function(control, data, ext)
     control:openView("Activities.Voyage.VoyageGiftBag")
 end

 --武道场
 __funcs[77] = function(control, data, ext)
     control:openView("Taoist", {is_jump = true})
 end

 --侠客试炼
 __funcs[78] = function(control, data, ext)
     control:openView("Activities.WorldBoss.HeroBossTrainPop", {is_jump = true})
 end

 -- 盗帅商店
 __funcs[79] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", { shop_type = 10})
 end

 --  高阶竞技场、巅峰竞技场商店
 __funcs[80] = function(control, data, ext)
    control:closeView("Shop")
    control:openView("Shop", { shop_type = 6})
 end

  --  珍宝阁
  __funcs[81] = function(control, data, ext)
    control:openView("MagicWeaponSelectMain")
end

 -- 四象阵
 __funcs[83] = function(control, data, ext)
     control:openView("FivelinesNew")
 end

 --皮肤兑换
 __funcs[82] = function(control, data, ext)
     control:openView("Pops.SkinExchangePop")
 end

 --阿闲
 __funcs[84] = function(control, data, ext)
     control:openView("Xian")
 end

 -- 苗疆秘宝
 __funcs[85] = function(control, data, ext)
     control:openView("HuntTreasures")
 end

 -- 天机楼-主页
 __funcs[86] = function(control, data, ext)
     control:openView("Budo.BudoSelectPop")
 end

 --试炼遗迹-主页
 __funcs[87] = function(control, data, ext)
     control:openView("Activities.WorldBoss.HeroBossSelectMain")
 end

 --江湖传奇
 __funcs[88] = function(control, data, ext)
     control:openView("Legend")
 end

 --  上古遗物
 __funcs[89] = function(control, data, ext)
     control:openView("MagicWeapon")
 end

__funcs[999] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext)
end

--绿林集结
__funcs[10001] = function(control, data, ext)
    static_rootControl:updateMsg("jump_giftbag", ext.open_id)
end
--大侠试炼
__funcs[10002] = function(control, data, ext)
    static_rootControl:openView("GiftBag.TrialPanel")
end
--七日登陆
__funcs[10003] = function(control, data, ext)
    static_rootControl:updateMsg("jump_giftbag", ext.open_id)
end
--每日签到
__funcs[10004] = function(control, data, ext)
    static_rootControl:updateMsg("jump_operateActivity", ext.open_id)
end
--在线奖励
__funcs[10005] = function(control, data, ext)
    static_rootControl:openView("GiftBag.OnTimePop")
end
--双倍收益
__funcs[10006] = function(control, data, ext)
    static_rootControl:updateMsg("jump_giftbag", ext.open_id)
end
--首充
__funcs[10007] = function(control, data, ext)
    static_rootControl:openView("GiftBag.FirstCharge")
end
--连续充值
__funcs[10008] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--武林行侠令
__funcs[10009] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--特惠礼包
__funcs[10010] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--新手礼包
__funcs[10011] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--每日礼包
__funcs[10012] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--月卡
__funcs[10013] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--基金
__funcs[10014] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--元宝商店
__funcs[10015] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--推送礼包
__funcs[10016] = function(control, data, ext)
    self:openView("GiftBag.LimitPop")
end
--活动
__funcs[10017] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--江湖行侠令
__funcs[10018] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--每周礼包
__funcs[10019] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--每月礼包
__funcs[10020] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--基金
__funcs[10021] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--基金
__funcs[10022] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end
--新手福利
__funcs[10023] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--锦囊礼包
__funcs[10024] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--限时礼包 ---强行跳司南礼包（蔡雪晨）
__funcs[10025] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--卦签
__funcs[10026] = function(control, data, ext)
    static_rootControl:updateMsg("jump_giftbag", ext.open_id)
end
--锦囊玉轴
__funcs[10027] = function(control, data, ext)
    static_rootControl:openView("GiftBag.GiftScrollPanel")
end
--定制礼包
__funcs[10028] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--烁玉流金
__funcs[10029] = function(control, data, ext)
    control:openView("Summer.SummerMain")
end
--飞龙乘云
__funcs[10030] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--乘龙有礼
__funcs[10031] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--木鸢锦鲤
__funcs[10032] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--天机秘宝
__funcs[10033] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--材料获取
__funcs[10034] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--歌舞升平
__funcs[10035] = function(control, data, ext)
    control:openView("Summer.SummerMain",{open_sub_id = ext.open_id})
end
--侠客成长礼包
__funcs[10036] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup", ext.open_id)
end
--充值
__funcs[10037] = function(control, data, ext)
    static_rootControl:updateMsg("jump_topup")
end

--特权
__funcs[10038] = function(control, data, ext)
    static_rootControl:updateMsg("goto_recharge", ext.open_id)
end

--限时兑换
__funcs[10039] = function(control, data, ext)
    --static_rootControl:updateMsg("goto_recharge", ext.open_id)
end

--侠影传说
__funcs[10046] = function(control, data, ext)
    if UserDataManager:getActivesByOpenId(235) == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
        return
    end
    static_rootControl:openView("MoonShadow.MoonShadowMain")
end

 --魅影传说
 __funcs[10047] = function(control, data, ext)
     if UserDataManager:getActivesByOpenId(270) == false then
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
         return
     end
     local open_active_data = UserDataManager:getOpenActiveData(270)
     static_rootControl:openView("ActiveCurrent.ActiveCurrentMain",{open_active_data = open_active_data, is_token = false})
 end

 --魅影传说挑战
 __funcs[10048] = function(control, data, ext)
     if UserDataManager:getActivesByOpenId(247) == false then
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
         return
     end
     static_rootControl:openView("EvilShadow.EvilShadowBattle")
 end

 --龙泉试炼挑战
 __funcs[10049] = function(control, data, ext)
     if UserDataManager:getActivesByOpenId(255) == false then
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
         return
     end
     local open_active_data = UserDataManager:getOpenActiveData(270)
     static_rootControl:openView("Dragonsword",{open_active_data = open_active_data})
 end
 
 --浣熊摇摇乐
 __funcs[10051] = function(control, data, ext)
    -- local jump = ConfigManager:getCfgByName("jump")
    -- local jump_item = jump[10051]
    -- if UserDataManager:getActivesByOpenId(jump_item.open_condition_id) == false then
    --     GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
    --     return
    -- end
    static_rootControl:openView("Raccon.RacconTinShot", {pop_from_func_id = -1})
end

 --浣熊英雄谱
 __funcs[10052] = function(control, data, ext)
    local jump = ConfigManager:getCfgByName("jump")
    local jump_item = jump[10052]
    if UserDataManager:getActivesByOpenId(jump_item.open_condition_id) == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
        return
    end
    static_rootControl:openView("Raccon.RacconTinShot", {pop_from_func_id = -1})
end

 --浣熊侠客志
 __funcs[10053] = function(control, data, ext)
    local jump = ConfigManager:getCfgByName("jump")
    local jump_item = jump[10053]
    if UserDataManager:getActivesByOpenId(jump_item.open_condition_id) == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
        return
    end
    static_rootControl:openView("Raccon.RacconXkz", {pop_from_func_id = -1})
end

__funcs[10054] = function(control, data, ext)
    local jump = ConfigManager:getCfgByName("jump")
    local jump_item = jump[10054]
    if UserDataManager:getActivesByOpenId(jump_item.open_condition_id) == false then
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
        return
    end
    local open_active_data = UserDataManager:getOpenActiveData(jump_item.open_condition_id)
    static_rootControl:updateMsg("jump_giftbag2", {open_id = open_active_data.open_id,active_id = open_active_data.id })
end

__funcs[10055] = function(control, data, ext)

end

 --奇门遁甲
 __funcs[87] = function(control, data, ext)
     static_rootControl:openView("QiMenDunJia.QiMenDunJiaMain")
 end

 --风云擂台
 __funcs[90] = function(control, data, ext)
     static_rootControl:openView("FulwinArena.FulwinArenaMain")
 end

 --风云擂台
 __funcs[90] = function(control, data, ext)
     static_rootControl:openView("FulwinArena.FulwinArenaMain")
 end
 
 -- 蓬莱岛
 __funcs[91] = function(control, data, ext)
     static_rootControl:openView("PengLaiBazzar.PengLaiBazzarIsland")
 end

 -- 蓬莱集市
 __funcs[92] = function(control, data, ext)
     static_rootControl:openView("PengLaiBazzar.PengLaiBazzarIsland")
 end

 -- 宠物大厅
 __funcs[93] = function(control, data, ext)
     static_rootControl:openView("PetBreeding.PetBreedingMain")
 end

 -- 宠物背包
 __funcs[94] = function(control, data, ext)
     static_rootControl:openView("PetBreeding.PetBag")
 end

 -- 天命
 __funcs[96] = function(control, data, ext)
     static_rootControl:openView("DestinyStar",{id = ext.hero_id})
 end

 -- 神兵谱
 __funcs[97] = function(control, data, ext)
     static_rootControl:openView("EquipAwaken")
 end

 -- 江湖威望
 __funcs[98] = function(control, data, ext)
     static_rootControl:openView("Prestige.PrestigeMain")
 end

 --神隐阁 sp抽卡
 __funcs[99] = function(control, data, ext)
     static_rootControl:openView("Predestined", {pool_id = GlobalConfig.GACHA_SP_ID})
 end

 --侠客岛
 __funcs[100] = function(control, data, ext)
     static_rootControl:openView("Xiakedao")
 end

 --酒楼
 __funcs[101] = function(control, data, ext)
     static_rootControl:openView("Hotel")
 end

 --天府夺刀
 __funcs[102] = function(control, data, ext)
     static_rootControl:openView("Activities.HeroBoss")
 end

 --研习(目前只处理了由每日任务跳转至研习，后边有其他跳转在做兼容处理)
 __funcs[103] = function(control, data, ext)

     static_rootControl:updateMsg("sect_btn")
 end

 --江湖
 __funcs[104] = function(control, data, ext)
     static_rootControl:openView("Main.Outskirts")
 end

 --天下
 __funcs[105] = function(control, data, ext)
     static_rootControl:openView("Main.TotalWorld")
 end



 --巅峰帮会张
 __funcs[295] = function(control, data, ext)
     static_rootControl:openView("GuildHighWar.GuildHighWarNewMainYan")
 end
 
 --------------------- 前端用不走配置 -----------------------------------------------
 --通用活动boss
 __funcs[100001] = function(control, data, ext)
     local open_id = ext.open_id or 327
     local active_data = UserDataManager:getOpenActiveData(open_id)
     if active_data then
         local params = table.copy(active_data)
         params.level_up = ext.level_up
         static_rootControl:openView("Activities.ActiveBoss", params)
     else 
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
     end
 end

 --通用活动抽奖
 __funcs[100002] = function(control, data, ext)
     local open_id = ext.open_id or 314
     local active_data = UserDataManager:getOpenActiveData(open_id)
     if active_data then
         local params = table.copy(active_data)
         params.level_up = ext.level_up
         params.is_token = ext.is_token
         local heroDraw = ConfigManager:getCommonValueById(120,0)
         if heroDraw == 1 then
             static_rootControl:openView("LuckyDraw.HeroDraw", params)
         else
            static_rootControl:openView("LuckyDraw.LuckyDraw", params)
         end
     else
         GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0030"), delay_close = 2})
     end
 end
 
function M:openFunc(data, ext)
	data = data or {}
    if type(data) == "number" then
        data = {data}
    end
    local func_id = data[1]
    if func_id then
        local jump = ConfigManager:getCfgByName("jump")
        local jump_item = jump[func_id]
        if jump_item then
            local open_condition_id = jump_item.open_condition_id or 0
            local open_flag, tips_str = BtnOpenUtil:isBtnOpen(open_condition_id)
            if ext then
                ext.open_id = open_condition_id
            else
                ext = {open_id = open_condition_id}   
            end
            if open_condition_id > 0 and not open_flag then
                GameUtil:lookInfoTips(static_rootControl, { msg = tips_str, delay_close = 2})
                return
            end
        end

	    local func = __funcs[func_id]
	    if func then
            if ext and ext.sound_id then
                audio:SendEvtUI(ext.sound_id)
            end
	        func(static_rootControl, data, ext)
	    else
	        Logger.logWarning("go to func id not found : " .. tostring(func_id))
            --GameUtil:lookInfoTips(static_rootControl, { msg = "go to func id not found : " .. tostring(func_id), delay_close = 2})
	    end
	end
end

function M:getOpenViewName( viewID, dumpCtrl)
    local func = __funcs[viewID]
    if func then
        func(dumpCtrl)
    end
end

function M:hasCostsTips(costs)
    local flag = false
    costs = costs or {}
    for i, v in ipairs(costs) do
        local data = RewardUtil:getProcessRewardData(v)
        if data.user_num < data.data_num then
            flag = self:costsTips(data)
            if flag then
                break
            end
        end
    end
    return flag
end

function M:serverCostsTips(error_code)
    local flag = false
    local reward_type = RewardUtil.SERVER_ERROR_GIFT_CODE[error_code]
    if reward_type then
        local money_guide = ConfigManager:getCfgByName("money_guide")
        local info = money_guide[reward_type] or {}
        if info.itype == 1 then--货币类型
            local data = RewardUtil:getProcessRewardData({reward_type, 0, 0})
            flag = self:costsTips(data)
        end
    end
    return flag
end

 function M:serverItemCostsTips(item_id)
     local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.ITEM, item_id, 0})
     local flag = self:costsTips(data)
     return flag
 end
 
function M:costsTips(data)
    local flag = false
    if data.money_guide_cfg.itype == 1 then
        local item_id = data.money_guide_cfg.item_id or {} -- 关联使用物品id
        for ii, vv in ipairs(item_id) do
            local item_data, item_cfg = UserDataManager.item_data:getItemDataById(vv)
            local item_num = item_data.num
            if item_num > 0 then -- 有使用的关联道具，打开道具使用界面
                static_rootControl:openView("Pops.CommonUseItemPop", {item_id = vv, cost_item_data = data})
                flag = true
                return flag
            end
        end

        local go_type = data.money_guide_cfg.go_type or {} -- 产出途径(有跳转)
        if #go_type > 0 then -- 打开前往界面
            static_rootControl:openView("Pops.CommonQuickGoTo", {item_data = data})
            flag = true
            return flag
        end
    else
        local go_type = data.item_cfg.go_type or {} -- 产出途径(有跳转)
        if #go_type > 0 then -- 打开前往界面
            static_rootControl:openView("Pops.CommonQuickGoTo", {item_data = data})
            flag = true
            return flag
        end
    end
    return flag
end

return M
