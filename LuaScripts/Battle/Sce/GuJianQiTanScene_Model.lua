--异界迷宫
---@class GuJianQiTanScene_Model : Scene_Model @
---@field super Scene_Model @Scene_Model
local M = class("GuJianQiTanScene_Model",Battle.Scene_Model)

--初始化场景
function M:init()
    M.super.init(self)
    self.talkList = Battle.List.new();
    --1.小怪 2.精英 3.boss 4.客栈 5.医馆 6.药王庙 7.商铺 8.空格 9.起点 10.怨灵马车 11.宝藏洞窟 12 奇遇事件 14 地面宝箱 16 宝箱
    --17~18~19~20 传送阵
    self.canClickType = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [10] = 1,
        [11] = 1,
        [12] = 1,
        [13] = 1,
        [14] = 1,
        [16] = 1,
        [21] = 1,
        [22] = 1,
        [23] = 1,
    }
    --奖励
    self.rewardType = {
        [14] = 1,
        [16] = 1,
        [21] = 1,
        [22] = 1,
        [23] = 1,
    }
end

function M:getCurSceneObjName()
    return "gujianqitanscene_data"
end

--进入场景
function M:enter( data )
    M.super.enter(self, data)
    self.autoTime = 2
    self.autoClickCellTime = 0.5;
    self.clickTime = 0.5;
    self.curClickTime = 0;
    self.autoUnlockSendServerTime = self.autoTime;
    self.left_top = {x = 10, y = 10};
    self.right_bottom = {x = -1,y = -1};
    self.mouseDown = false
    self.isMove = false
    self.isInMoving = false;
    self.talkList = Battle.List.new();
    --是否在传送中
    self.isTranfering = false;
    self.isMoveToRoom = false;

    TimeManager:set_baseUpdateDelaTime(TimeManager.hangUpUpdateDelteTime);

    local common_value = ConfigManager:getCommonValueById(482);
    if common_value ~= nil then
        self.curTalkDelayTime = common_value[1]
        self.curTalkTime = math.random( common_value[2],common_value[3] )
    else
        self.curTalkDelayTime = 3
        self.curTalkTime = math.random( 8,12 )
    end

    --初始化talk列表
    self:initTalkList();
end

--加载完成
function M:loadFinish()
    --加载场景物件
    self:loadSceneItem()
    --当前我要站立的item
    self.curItem = nil;
    --玩家
    self.player = nil;
    --每次移动过的路径
    self.movePassPath = Battle.List.new();
    --移动结束发送到服务器的时间
    self.moveEndSendToServer = 0.1;
    --当前移动结束时间
    self.curMoveEndTime = 0;
    --初始化talk列表
    self:initTalkList();
    --箭头每0.5秒矫正一次方向
    self:resetSceneData()
    self:sendEvent("load_finish", nil, "GuJianQiTan.GuJianQiTanMaze");
end

--重新设置场景数据
function M:resetSceneData( data )
    
    self:resetClickRoom();
    --本地取到 特效播放的记录
    self.boxEffectLocalData = UserDataManager.local_data:getLocalDataByKey("boxEffectLocalData") or {}
    
    --删掉所有的延迟函数
    TimeTools:killModel()
    --发送到迷宫清理格子
    self:sendEvent("maze_clear_grid", nil, "GuJianQiTan.GuJianQiTanMaze")
    --
    if data ~= nil then
        self.migong_data = data;
    else
        self.migong_data = self.m_data;
    end
    --自己组装的data
    self.pass_status = self.migong_data.m_data.pass_status;
    
    self.startGrid = nil
    
    --向服务器发送的间隔时间
    self.sendToServerNow = true;
    local maze_floor = ConfigManager:getCfgByName("sword_akuma_floor")[self.m_data.m_data.version]
    --多少层
    self.floor_id = self.migong_data.m_data.floor_id or 0
    self.cur_floor_data = maze_floor[self.floor_id]
    --当前的格子
    self.cell_id = self.migong_data.m_data.cell_id;
    
    local maze_prmap = ConfigManager:getCfgByName("sword_akuma_map")
    local mzee_map_data = maze_prmap[ self.migong_data.m_data.map_id];
    if mzee_map_data ~= nil then
        self.map_id = mzee_map_data.prefab_name
    else
        self.map_id = self.migong_data.m_data.map_id;
    end
    
    --当前点到的物体
    self.select_obj = nil;
    
    --临时移动完成
    self.temp_moveFinish_callback = nil;
    self.scene_obj_meishu = U3DUtil:GameObject_Find("Scene");
    self.tranformHelper = self.scene_obj_meishu:GetComponent("LuaTransformHelper");
    --平台和桥管理器
    self.pingtaiQiaoMgr = self.scene_obj_meishu:GetComponent("PingTaiQiaoManager");
    --注册行和位置
    --Logger.log(self.migong_data.m_data.map_id ," 迷宫服务器数据 地图id ~~~~~~~~~~~~~~~~~~~~~~~")
    --Logger.log(self.migong_data.m_data ," 迷宫服务器数据 ~~~~~~~~~~~~~~~~~~~~~~~")
    --Logger.log(self.migong_data.m_data.passed ," 迷宫已经移动格子 ~~~~~~~~~~~~~~~~~~~~~~~")
    --Logger.log(self.migong_data.m_data.cells ," 迷宫服务器格子 ~~~~~~~~~~~~~~~~~~~~~~~")
    --配置文件
    --Logger.logError( " 迷宫地图 id "..tostring(self.map_id) )
    self.config = ConfigManager:getCfgByName("maze_map~"..tostring(self.map_id));
    self.localConfig = require("Battle.Data.GuJianQiTan."..tostring(self.map_id));
    --格子位置信息
    self.MapPos = require("Battle.Data.GuJianQiTan.MapPos")
    --初始化AStar
    self.aStar = require("Battle.Data.AStarSix").new();
    --6边型
    self.aStar:init("MiGongSceneData", 1);
    self.aStar.sceneData:refresh(self.migong_data.m_data.cells)
    --所有有用的地图格子数据
    self.map_data = {}
    --AStar寻路路径
    if self.path ~= nil then
        self.path:clear();
    else
        self.path = Battle.List.new()
    end
    -- 已经开启的格子 
    self.openCells = {}
    self.pingtaiQiaoMgr:ResetAll(-200,-200,10,1,1)
    
    --临时移动目标
    self.temp_target = nil;
    --宽度
    self.max_w = #self.localConfig[0] +1;
    --高度
    self.max_h = #self.localConfig + 1;
    --每次进入刷新 9 * 9 格子数据
    for h = 1, 9 do
        for w = 1, 9 do
            local w_index = w-1;
            local h_index = h-1;
            local obj = self.pingtaiQiaoMgr:FindPingTaiGameObject("map_scene_"..w_index.."_"..h_index);
            --local yun_obj = self.pingtaiQiaoMgr:FindYunGameObject("yun_"..w_index.."_"..h_index);
            if obj ~= nil then
                --存储物体
                self:setObjData( obj, w_index, h_index)
            else
                Logger.log(" null ~~ obj ~~".."map_scene_"..w_index.."_"..h_index )
            end
        end
    end
    --是否还有宝箱
    self.scene_hasBox = self:hasBox();

    self.map_cell_ids = {}
    for k,v in pairs(self.map_data) do
        table.insert(self.map_cell_ids, k)
    end

    --0 表示没有发现宝箱 1 表示发现了宝箱
    self.findBoxState = 0;

    if self.click_effect == nil then
        self.click_effect = SceneManager:getCurSceneView():instanceGameObject("clickEffect",self.scene_obj_meishu);
    end
    self.click_effect.transform.position = Vector3(100000,100000,100000);
    self.click_set_effect_time = 0;
    
    GameMain.addUpdate("Maze_Update", handler(self,self.UnityUpdate))
    self.mouseDown = SceneManager:getCurSceneView().cameraController.mouseDown;
    self.mouseDownTime = 0;

    self:handlerPassedGrid();
    --创建迷宫玩家 
    self:createMigongPlayer();
    
    --注册一个点击事件
    -- DownObj
    -- UpObj
    -- ClickObj
    if CS.GameObjectClickMgr.Inst.RegisterNew ~= nil then
        CS.GameObjectClickMgr.Inst:RegisterNew("UpObj",handler(self,self.DownObj))
    else
        CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.DownObj))
    end
    CS.GameObjectClickMgr.Inst:GetListeners();

    SceneManager:setData("show_loading_black", false)
    static_rootControl:updateMsg("close_battle_loading")
end


function M:initTalkList()
    self.talkList:clear();
    local talk = ConfigManager:getCfgByName("random_lines")
    for k,v in pairs(talk) do
        local type = v["type"]
        if type == 4 then
            self.talkList:add(v)
        end
    end
end


--检测聊天
function M:check_talk( dt )
    if self.curTalkDelayTime > 0 then
        self.curTalkDelayTime = self.curTalkDelayTime - dt;
        if self.curTalkDelayTime <= 0 then
            self:talk();
        end
    else
        if self.curTalkTime > 0 then
            self.curTalkTime = self.curTalkTime - dt
            if self.curTalkTime <= 0 then
                self:talk();
                self.curTalkTime = math.random( 8,12 )
            end
        end
    end
end


--弹出聊天框
function M:talk()
    if self.talkList ~= nil and self.talkList.Count > 0 then
        local index = 0
        if self.talkList.Count >= 2 then
            index = math.random(0,self.talkList.Count-1);
        end
        local talk_content = self.talkList:get(index);
        if talk_content["type"] == 4 then
            if self.player_view ~= nil then
                self.player_view:talk( Language:getTextByKey(talk_content["lines"]),talk_content.show_time)
            end
        end
    end
end



function M:UnityUpdate(dt)
    if self.headUI ~= nil then
        self.headUI:update(dt);
    end
    
    self:check_talk(dt)

    self.mouseDown = SceneManager:getCurSceneView().cameraController.mouseDown;
    if self.mouseDown == true then
        self.mouseDownTime = self.mouseDownTime + dt;
    else
        self.mouseDownTime = 0;
    end
    
    if static_rootControl:can3DTouchByViewName("GuJianQiTan.GuJianQiTanMaze") then
        if SceneManager:getCurSceneView().cameraController.CanDrag == false then
            SceneManager:getCurSceneView().cameraController.CanDrag = true;
            SceneManager:getCurSceneView().cameraController.mouseDown = false;
        end
    else
        if SceneManager:getCurSceneView().cameraController.CanDrag == true then
            SceneManager:getCurSceneView().cameraController.CanDrag = false;
        end
    end

    if self.click_set_effect_time > 0 then
        self.click_set_effect_time = self.click_set_effect_time - dt;
        if self.click_set_effect_time <= 0 then
            if self.click_effect ~= nil then
                self.click_effect.transform.position = Vector3(100000,100000,100000);
            end
            self.click_set_effect_time = 0;
        end
    end

    --更新玩家移动
    self:updatePlayerMove( dt )

    --发送到服务器
    if self.sendToServerNow == false then
        if self.autoUnlockSendServerTime > 0 then
            self.autoUnlockSendServerTime = self.autoUnlockSendServerTime - dt;
            if self.autoUnlockSendServerTime <= 0 then
                self.sendToServerNow = true;
            end
        end
    end
    
    --点击时间
    if self.curClickTime > 0 then
        self.curClickTime = self.curClickTime - dt;
        if self.curClickTime <= 0 then
            self.curClickTime = 0;
        end
    end
end

--更新玩家移动位置
function M:updatePlayerMove( dt )
    if self.isMove == true then
        if self.nextGrid ~= nil then
            local pos = self.MapPos["map_scene_"..self.nextGrid.index_pos.x.."_"..self.nextGrid.index_pos.y]
            local grid_fix_pos = GlobalTools:ToFixVector3(pos);
            local dir = GlobalTools:Dir(grid_fix_pos,self.player.position);
            local distance = GlobalTools:Distance(self.player.position, grid_fix_pos);
            self.player:setForward(dir)
            if distance > GlobalTools:ToFix2(GlobalTools.base1) then
                local dt_fix = GlobalTools:CommonToFix(dt);
                local time = GlobalTools:Mul(dt_fix, GlobalTools.base5)
                self.player:move_no_coillder(dir, time);
            else
                self.nextGrid = nil;
            end
        end

        if self.nextGrid == nil then
            ---移动
            if self.path.Count > 0 then
                --大于5个格子要瞬移
                if self.path.Count >= 5 then
                    for i = 1, self.path.Count do
                        local point = self.path:get(i-1);
                        self.movePassPath:add(point);
                    end
                    self.nextGrid = self.path:get(self.path.Count - 1);
                    self.startGrid = self.nextGrid
                    local key = self:infoToID(self.nextGrid.index_pos.x, self.nextGrid.index_pos.y)
                    local center_cell_data = self:getCellData(key)
                    self.path:clear();
                    local pos = self.MapPos["map_scene_"..self.nextGrid.index_pos.x.."_"..self.nextGrid.index_pos.y]
                    local grid_fix_pos = GlobalTools:ToFixVector3(pos);
                    grid_fix_pos.y = self.player.position.y;
                    self.player:setPos(grid_fix_pos)
                    if _G.next(self.summon_list) then
                        for i, v in ipairs(self.summon_list) do
                            v:setPos(grid_fix_pos - FixVector3.New(1,0,1) * GlobalTools.base2_5)
                        end
                    end
                    if self.player_view.shunyi ~= nil then
                        self.player_view.shunyi:SetActive(false);
                        self.player_view.shunyi:SetActive(true);
                    end
                    --迷宫小地图用的
                    --self:sendEvent("maze_move_grid", center_cell_data, "GuJianQiTan.GuJianQiTanMaze");
                    self:refreshCells(center_cell_data, false, true);
                    self:checkBoxAround(center_cell_data);
                else
                    --下一个格子
                    self.nextGrid = self.path:get(0);
                    --起始格子 
                    self.startGrid = self.nextGrid
                    --路径中移除
                    self.path:removeAt(0);
                    --移动路径
                    self.movePassPath:add(self.nextGrid);
                    local key = self:infoToID(self.nextGrid.index_pos.x, self.nextGrid.index_pos.y)
                    local center_cell_data = self:getCellData(key)
                    --迷宫小地图用的
                    --self:sendEvent("maze_move_grid", center_cell_data, "GuJianQiTan.GuJianQiTanMaze");
                    --刷新周围的格子
                    self:refreshCells(center_cell_data, false, true);
                    --检测周围的宝箱
                    self:checkBoxAround(center_cell_data);
                end
            else
                self.targetGrid = nil;
                self.isMove = false;
                self.sendToServerNow = true;
                self.player.animator:changeState("idle")
                --移动结束之后
                if self.gotoFinish ~= nil then
                    self.gotoFinish()
                    self.gotoFinish = nil;
                else
                    --只有点击空白的格子才能用这个延迟时间
                    self.curMoveEndTime = self.moveEndSendToServer;
                end
                static_rootControl:updateMsg("guide_check",data,"GuJianQiTan.GuJianQiTanMaze")
            end
        end
    else
        --临时目标
        if self.temp_target ~= nil then
            self.isInMoving = true;
            local pos = self.MapPos["map_scene_"..self.temp_target.index_pos.x.."_"..self.temp_target.index_pos.y]
            local grid_fix_pos = GlobalTools:ToFixVector3(pos);
            local dir = GlobalTools:Dir(grid_fix_pos,self.player.position);
            local distance = GlobalTools:Distance(self.player.position, grid_fix_pos);
            self.player:setForward(dir)
            if distance > GlobalTools:ToFix2(GlobalTools.base1) then
                local dt_fix = GlobalTools:CommonToFix(dt);
                local time = GlobalTools:Mul(dt_fix, GlobalTools.base5)
                self.player:move_no_coillder(dir, time);
            else
                self.isInMoving = false;
                self.player.animator:changeState("idle")
                self.sendToServerNow = true;
                local key = self:infoToID(self.temp_target.index_pos.x, self.temp_target.index_pos.y)
                local center_cell_data = self:getCellData(key)
                self:sendEvent("maze_move_grid", center_cell_data, "GuJianQiTan.GuJianQiTanMaze");
                if self.temp_target.value == 0 then
                    self:refreshCells(center_cell_data, false, true);
                end
                self:checkBoxAround(center_cell_data);
                self:moveTempFinish()
                self.temp_target = nil;
            end
        end
    end

    if self.curMoveEndTime > 0 then
        self.curMoveEndTime = self.curMoveEndTime - dt;
        if self.curMoveEndTime <= 0 then
            --goto完之后可以继续点击
            if self.temp_target == nil then
                self:resetClickRoom();
            end
            self:sendToServer()
        end
    end
end


function M:isTransfer( m_type )
    if m_type == 17 or m_type == 18 or m_type == 19 or m_type == 20then
        return true    
    end
    return false;
end


--创建玩家
function M:createMigongPlayer()
    --self.cell_id = 60010101
    if self.player == nil then
        local avatar,custom_prefab  = GameUtil:getUserOwnAvatar()
        local playerData = { id = tonumber(avatar), evo = 0, custom_prefab = custom_prefab }
        --玩家脚下的当前格子
        local cell_data = self:getCellData(self.cell_id);
        self:sendEvent("set_grid_position", cell_data, "GuJianQiTan.GuJianQiTanMaze")
        --起始格子
        self.startGrid = self.aStar.sceneData.data[cell_data.w_pos][cell_data.h_pos];
        --Logger.log(" 起始格子 "..self.startGrid.index_pos.x.." , "..self.startGrid.index_pos.y )
        --昆仑需要创建宠物
        
        self.player = self.plyMgr:createPlayer(playerData,1,0,nil,nil)
        self.player.loadPlayerViewFinish = function(ply)
            self.player_view = ply;
            local pos = cell_data.obj.transform.position;
            pos.y = 0;
            local fix_pos = FixVector3.New(0,0,0);
            fix_pos.x = GlobalTools:CommonToFix( pos.x );
            fix_pos.y = GlobalTools:CommonToFix( pos.y );
            fix_pos.z = GlobalTools:CommonToFix( pos.z );
            --玩家设定位置
            self.player:setPos( fix_pos )
            self.plyMgr:playerSpawnCamp(1);
            if self.player.animator ~= nil then
                self.player.animator:changeState("idle")
            end
            SceneManager:getCurSceneView().cameraController.transform.position = self.player_view:get_position()
            SceneManager:getCurSceneView().cameraController:ResetStart();
            SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
            self:closeloading();
            --放大3倍
            self.player:setBaseScale(GlobalTools.base3)
            --场景状态改成3
            self:set_sceneState(3)

            self:setViewEffect();
            if self.mainPlayerloadFinish ~= nil then
                self.mainPlayerloadFinish()
            end
            self:refreshCells( cell_data, true )
            self:checkBoxAround( cell_data );
            self.summon_list_view, self.summon_list = GlobalTools:CreateSummon(self.player, GlobalTools.base3, GlobalTools.base12)
            if _G.next(self.summon_list) then
                for i, v in ipairs(self.summon_list) do
                    v:setPos(fix_pos - FixVector3.New(1,0,1) * GlobalTools.base2_5)
                end
            end
        end
        
    else
        local cell_data = self:getCellData(self.cell_id);
        self:sendEvent("set_grid_position", cell_data, "GuJianQiTan.GuJianQiTanMaze")
        self.startGrid = self.aStar.sceneData.data[cell_data.w_pos][cell_data.h_pos];
        local pos = cell_data.obj.transform.position;
        pos.y = 0;
        local fix_pos = FixVector3.New(0,0,0);
        fix_pos.x = GlobalTools:CommonToFix( pos.x );
        fix_pos.y = GlobalTools:CommonToFix( pos.y );
        fix_pos.z = GlobalTools:CommonToFix( pos.z );
        self.player_view.arrowScirpt:SetTarget(self.door_obj);
        --玩家设定位置
        self.player:setPos( fix_pos )
        self.plyMgr:playerSpawnCamp(1);
        SceneManager:getCurSceneView().cameraController.transform.position = self.player_view:get_position()
        SceneManager:getCurSceneView().cameraController:ResetStart();
        SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
        self:closeloading();
        self:setViewEffect();
        self.player:setBaseScale(GlobalTools.base3)
        self:set_sceneState(3)
        self.player.animator:changeState("idle")
        self:refreshCells( cell_data, true )
        self:checkBoxAround( cell_data );
        if self.summon_list ~= nil and _G.next(self.summon_list) then
            for i, v in ipairs(self.summon_list) do
                v:setPos(fix_pos - FixVector3.New(1,0,1) * GlobalTools.base2_5)
            end
        end
    end
end


function M:setViewEffect()
    if self.player_view ~= nil then
        if self.player_view.arrow ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.arrow);
            self.player_view.arrow = nil;
        end
        if self.player_view.tanhao ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.tanhao);
            self.player_view.tanhao = nil;
        end
        if self.player_view.shunyi ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.shunyi);
            self.player_view.shunyi = nil;
        end
        
        self.player_view.tanhao = SceneManager:getCurSceneView():instanceGameObject("Fx_MiGong_GanTan_001");
        self.player_view.tanhao.transform:SetParent(self.player_view.tran);
        self.player_view.tanhao.transform.localPosition = Vector3(0,0,0)
        self.player_view.tanhao:SetActive(false);

        self.player_view.shunyi = ResourceUtil:LoadCommonEffect("FX_MiGong_ChuanS_001",nil);
        self.player_view.shunyi.transform:SetParent(self.player_view.tran);
        self.player_view.shunyi.transform.localPosition = Vector3(0,0,0)
        self.player_view.shunyi.transform.localScale = Vector3(1,1,1)
        self.player_view.shunyi:SetActive(false);

        self.player_view.arrow = SceneManager:getCurSceneView():instanceGameObject("Fx_MiGong_ZhiShi_001");
        self.player_view.arrow.transform:SetParent(self.player_view.tran);
        self.player_view.arrow.transform.localPosition = Vector3(0,0.2,0)
        self.player_view.arrow.transform.localScale = Vector3(1,1,1)
        self.player_view.arrowScirpt = self.player_view.arrow:GetComponent(typeof(CS.ArrowForward))
        self.player_view.arrowScirpt:SetTarget(self.door_obj);
    end 
end


--场景加载完成
function M:closeloading()
    EventDispatcher:registerTimeEvent("delay_close_loading_time",function()
        static_rootControl:updateMsg("close_sync_load_big_loading");
    end,0.5,0.5)
end

--假装移动完成
function M:moveTempFinish()
    if self.temp_moveFinish_callback ~= nil then
        self.temp_moveFinish_callback()
        self.temp_moveFinish_callback = nil;
    end

    if self.moveTempFinish_sendServer ~= nil then
        self.moveTempFinish_sendServer()
        self.moveTempFinish_sendServer = nil;
    end
end


function M:upMoveYun( gridData, center, isDrect )
    if gridData.yun_script ~= nil and IsNull(gridData.yun_script) == false then
        local pos = self.MapPos["map_scene_"..center.w_pos.."_"..center.h_pos]
        gridData.yun_script:StartMove( Vector3(pos.x, pos.y, pos.z), isDrect );
    end
end


function M:clearHead()
    for k,v in ipairs(self.map_data) do
        if v.item ~= nil then
            v.item:showHead(false)
        end
    end
end

--得到3个格子内的所有格子
function M:getAroundCellByLen( center )
    local cells = {}
    --找到中心点周围的格子 
    local around_grid, around_index = self:getAroundCell( center );
    for k,v in ipairs(around_grid) do
        --已经开启的格子
        local key = self:infoToID(v.w_pos, v.h_pos)
        local cell = cells[key];
        if cell == nil then
            cells[key] = v;
        end
        local around_grid1, around_index1 = self:getAroundCell( v );
        for k1,v1 in ipairs(around_grid1) do
            --已经开启的格子
            local key = self:infoToID(v1.w_pos, v1.h_pos)
            local cell = cells[key];
            if cell == nil then
                cells[key] = v1;
            end
        end
    end
    return cells;
end

--周围时候有宝箱
function M:hasBoxsAround( center )
    local boxes = {}
    --得到3个格子内的所有格子
    local cells = self:getAroundCellByLen( center );
    for k,v in pairs(cells) do
        if v.server_data ~= nil and v.server_data.type == 14 and v.server_data.status ~= 1 then
            table.insert(boxes, v)
        end
    end
    return boxes;
end

function M:checkBoxAround( center )
    if center == nil then
        return;
    end
    --在场景中有宝箱的情况下
    if self.scene_hasBox == true then
        local cell_key = self:infoToID(center.w_pos, center.h_pos)
        if self.player ~= nil then
            local boxes = self:hasBoxsAround(center);
            if #boxes > 0 then
                if self.findBoxState == 0 then
                    if self.player_view ~= nil and not IsNull(self.player_view.tanhao) then
                        self.player_view.tanhao:SetActive(true);
                        --GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("new_str_0719"), delay_close = 2})
                        audio:SendEvtUI("UI_Ding")
                    end
                    self.findBoxState = 1;
                end
            else
                if self.findBoxState == 1 then
                    if self.player_view ~= nil and not IsNull(self.player_view.tanhao) then
                        self.player_view.tanhao:SetActive(false);
                    end
                    self.findBoxState = 0;
                end
            end
        end
    end
end

function M:setPassed( data )
    self.migong_data.m_data.passed = data;
end

--升起所有未开启的格子
function M:upAllNoopenCells()
    for i, v in pairs(self.map_data) do
        if self:inOpenCells(v) == false then
            self:refreshCells( v, false )
        end
    end
end


--是否在已经打开的格子列表中
function M:inOpenCells( cell )
    for open_index, open_cell in ipairs(self.openCells) do
        if cell == open_cell then
            return true;
        end
    end
    return false;
end


--刷新格子
function M:refreshCells( center, isDrect, useYun, upMoveCell )
    if upMoveCell == nil then
        upMoveCell = true
    end
    self:clearHead();
    if useYun == nil then
        useYun = true;
    end
    
    if useYun then
        self:upMoveYun( center, center, isDrect );
    end
    
    local around_grid, around_index = self:getAroundCell( center );
    --已经开启的格子
    table.insert(self.openCells, center);
    self:upToObj( center, isDrect, function()
        local index = 0;
        --处理桥
        for k,v in ipairs(around_grid) do
            index = index + 1;
            local qiaoObj = self:getQiao(center, v);
            if qiaoObj ~= nil then
                if isDrect then
                    self:upToQiao( qiaoObj, isDrect, center.obj )
                else
                    local time = 0.1 * index
                    TimeTools:delayTimeUnity(time,function()
                        self:upToQiao( qiaoObj, isDrect, center.obj )
                    end)
                end
            end
        end
    end)
    
    if upMoveCell then
        --处理周围格子
        local is_guide = false
        local index = 0
        for k,v in ipairs(around_grid) do
            index = index + 1;
            if isDrect then
                self:upToObj( v, isDrect )
                if useYun then
                    self:upMoveYun( v, center, isDrect );
                end
            else
                local time = 0.1 * index
                TimeTools:delayTimeUnity(time,function()
                    self:upToObj( v, isDrect )
                    if useYun then
                        self:upMoveYun( v, center, isDrect );
                    end
                end)
            end

            if v.item ~= nil then
                v.item:showHead(true)
            end

            table.insert(self.openCells, v);

            if is_guide == false and v.server_data then
                if v.server_data.type == 1 or v.server_data.type == 2 or v.server_data.type == 3 then
                    local id = ConfigManager:getCommonValueById(310, 0, true) -- 小怪
                    is_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
                elseif v.server_data.type == 4 then -- 佣兵
                    local id = ConfigManager:getCommonValueById(306,0, true)
                    is_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
                elseif v.server_data.type == 7 then -- 商人
                    local id = ConfigManager:getCommonValueById(305,0,true)
                    is_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
                elseif v.server_data.type == 13 then -- 出口
                    local id = ConfigManager:getCommonValueById(304,0,true)
                    is_guide = UserDataManager.guide_data:setAnyTeamGuide(id)
                    if self.pass_status == 0 then
                        self:upAllNoopenCells();
                        static_rootControl:updateMsg("upAllCells",self,"GuJianQiTan.GuJianQiTanMaze")
                        self.pass_status = 1
                    end
                end
            end
            self:refreshCells( v, isDrect, useYun, false)
        end
        if is_guide then
            self.guide_check_cell = center
        end

        self:refreshDragArea()
    else
        local index = 0
        for k,v in ipairs(around_grid) do
            index = index + 1;
            if isDrect then
                if useYun then
                    self:upMoveYun( v, center, isDrect );
                end
            else
                local time = 0.1 * index
                TimeTools:delayTimeUnity(time,function()
                    if useYun then
                        self:upMoveYun( v, center, isDrect );
                    end
                end)
            end
        end
    end
end


function M:getQiaoName( center, around )
    local qiaoName = "map_qiao_"..center.w_pos.."_"..center.h_pos.."_"..around.w_pos.."_"..around.h_pos;
    return qiaoName;
end

function M:getQiao( center, around )
    local name = self:getQiaoName( center, around );
    local qiaoObj = self.pingtaiQiaoMgr:FindQiaoGameObject(name);
    if qiaoObj == nil then
        name = self:getQiaoName( around, center );
        qiaoObj = self.pingtaiQiaoMgr:FindQiaoGameObject(name);
    end
    return qiaoObj;
end


--格子是否在周围
function M:isAround( center, around )
    local w_pos = around.w_pos - center.w_pos;
    local h_pos = around.h_pos - center.h_pos;
    if center.w_pos % 2 == 1 then
        if (w_pos == -1 and h_pos == 1)
            or (w_pos == 0 and h_pos == 1)
            or (w_pos == 1 and h_pos == 1)
            or (w_pos == 1 and h_pos == 0)
            or (w_pos == 0 and h_pos == -1)
            or (w_pos == -1 and h_pos == 0) then
            return true;
        end
    else
        if (w_pos == -1 and h_pos == 0)
            or (w_pos == 0 and h_pos == 1)
            or (w_pos == 1 and h_pos == 0)
            or (w_pos == 1 and h_pos == -1)
            or (w_pos == 0 and h_pos == -1)
            or (w_pos == -1 and h_pos == -1) then
            return true;
        end
    end
end


--通过中心格子获取周围格子
function M:getAroundCell( center )
    local around = {}
    local around_index = ""
    if center.w_pos % 2 == 0 then
        --center 6-6
        --5-6
        if center.w_pos > 0 then
            local key = self:infoToID(center.w_pos - 1, center.h_pos)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(0);
            end
        end
        --7-6
        if center.w_pos < self.max_w then
            local key = self:infoToID(center.w_pos + 1, center.h_pos)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(2);
            end
        end
        --6-5
        if center.h_pos > 0 then
            local key = self:infoToID(center.w_pos, center.h_pos-1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(4);
            end
        end
        --6-7
        if center.h_pos < self.max_h then
            local key = self:infoToID(center.w_pos, center.h_pos + 1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(1);
            end
        end
        --7-5
        if center.w_pos < self.max_w and center.h_pos > 0 then
            local key = self:infoToID(center.w_pos + 1, center.h_pos - 1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(3);
            end
        end
        --5-5
        if center.h_pos > 0 and center.w_pos > 0 then
            local key = self:infoToID(center.w_pos - 1, center.h_pos - 1)
            if center.w_pos < self.max_w then
                local map_data_item = self:getCellData(key);
                if map_data_item ~= nil then
                    table.insert(around, map_data_item);
                    around_index = around_index.."-"..tostring(5);
                end
            end
        end
    else
        --center 5-5
        --4-5
        if center.w_pos > 0 then
            local key = self:infoToID(center.w_pos - 1, center.h_pos)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(5);
            end
        end
        --6-5
        if center.w_pos < self.max_w then
            local key = self:infoToID(center.w_pos + 1, center.h_pos)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(3);
            end
        end
        --5-4
        if center.h_pos > 0 then
            local key = self:infoToID(center.w_pos, center.h_pos-1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(4);
            end
        end
        --5-6
        if center.h_pos < self.max_h then
            local key = self:infoToID(center.w_pos, center.h_pos + 1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(1);
            end
        end
        
        --4-6
        if center.w_pos > 0 and center.h_pos < self.max_h then
            local key = self:infoToID(center.w_pos - 1, center.h_pos + 1)
            local map_data_item = self:getCellData(key);
            if map_data_item ~= nil then
                table.insert(around, map_data_item);
                around_index = around_index.."-"..tostring(0);
            end
        end
        --6-6
        if center.h_pos < self.max_h and center.w_pos < self.max_w then
            local key = self:infoToID(center.w_pos + 1, center.h_pos + 1)
            if center.w_pos < self.max_w then
                local map_data_item = self:getCellData(key);
                if map_data_item ~= nil then
                    table.insert(around, map_data_item);
                    around_index = around_index.."-"..tostring(2);
                end
            end
        end
    end
    return around, around_index;
end


--处理已经走过的格子
function M:handlerPassedGrid()
    --默认fog模式，即没有fog字段
    if self.cur_floor_data.fog == nil or self.cur_floor_data.fog == 0 then
        --根据服务器的逐步打开
        local passed = self.migong_data.m_data.passed;
        if passed ~= nil then
            for k,v in ipairs(passed) do
                local grid = self:getCellData(v);
                if grid ~= nil then
                    if grid.server_data ~= nil and grid.server_data.status == 1 then
                        local grid_data = self.aStar.sceneData.data[grid.w_pos][grid.h_pos]
                        grid_data:setValue(0);
                    end
                    self:refreshCells( grid, true )
                end
            end
        end
    else
        --一开始关卡全开
        local cells = self.map_cell_ids;
        if cells ~= nil then
            for k,v in ipairs(cells) do
                local grid = self:getCellData(v);
                self:refreshCells( grid, true )
            end
        end
        
        local passed = self.migong_data.m_data.passed;
        if passed ~= nil then
            for k,v in ipairs(passed) do
                local grid = self:getCellData(v);
                if grid ~= nil then
                    if grid.server_data ~= nil and grid.server_data.status == 1 then
                        local grid_data = self.aStar.sceneData.data[grid.w_pos][grid.h_pos]
                        grid_data:setValue(0);
                    end
                end
            end
        end
    end
end

--刷新拖拽区域
function M:refreshDragArea()
    for k,v in ipairs(self.openCells) do
        if self.left_top.x >= v.w_pos then
            self.left_top.x = v.w_pos ;
        end
        if self.left_top.y >= v.h_pos then
            self.left_top.y = v.h_pos;
        end
        if self.right_bottom.x <= v.w_pos  then
            self.right_bottom.x = v.w_pos;
        end
        if self.right_bottom.y <= v.h_pos then
            self.right_bottom.y = v.h_pos;
        end
    end

    --设定最左最右格子
    local left_top_cell = self.pingtaiQiaoMgr:FindPingTaiGameObject("map_scene_"..self.left_top.x.."_"..self.left_top.y);
    local right_bottom_cell = self.pingtaiQiaoMgr:FindPingTaiGameObject("map_scene_"..self.right_bottom.x.."_"..self.right_bottom.y);
    if left_top_cell ~= nil and right_bottom_cell ~= nil then
        local left_top_pos = left_top_cell.transform.position;
        left_top_pos.y = 0;
        left_top_pos.x = left_top_pos.x;
        left_top_pos.z = left_top_pos.z;
        local right_bottom_pos = right_bottom_cell.transform.position;
        right_bottom_pos.y = 0;
        right_bottom_pos.x = right_bottom_pos.x;
        right_bottom_pos.z = right_bottom_pos.z;
        SceneManager:getCurSceneView().cameraController.left_top_area.transform.position = left_top_pos;
        SceneManager:getCurSceneView().cameraController.right_bottom_area.transform.position = right_bottom_pos;
    end
end
--
--找路径
function M:findPaths( target_w, target_h )
    --每次找路径都要清空重新找
    self.path:clear();
    --目标格子
    self.targetGrid = self.aStar.sceneData.data[target_w][target_h]
    --Logger.logError(" AStar 寻路路径 起始格子 ~~~ "..self.startGrid.index_pos.x.." -- "..self.startGrid.index_pos.y)
    --Logger.logError(" AStar 寻路路径 目标格子 ~~~ "..self.targetGrid.index_pos.x.." -- "..self.targetGrid.index_pos.y)
    if self.targetGrid ~= nil and self.startGrid ~= nil then
        -- AStar找到的路径
        self.path = self.aStar:findPath(self.startGrid,self.targetGrid)
        for i = 1, self.path.Count do
            local grid = self.path:get(i-1)
            --Logger.logError(" AStar 寻路路径格子 ~~~ "..grid.index_pos.x.." -- "..grid.index_pos.y)
        end
    end
    if self.path.Count <= 0 then
        static_rootControl:updateMsg("show_no_move_messag",nil,"GuJianQiTan.GuJianQiTanMaze")
        self:resetClickRoom();
        self.isTranfering = false;
    end
end


--发送到服务器路径
function M:sendToServer()
    --如果现在可以发送到服务器
    if self.movePassPath.Count > 0 then
        local path_list = {}
        for i=1,self.movePassPath.Count do
            local grid = self.movePassPath:get(i-1);
            local grid_id = self:infoToID(grid.index_pos.x,grid.index_pos.y)
            path_list[i] = grid_id;
        end
        local path_data = { path = path_list, cell_id = path_list[#path_list] }
        --Logger.logError(path_data," 送到服务器的goto参数 ")
        self:sendEvent("maze_goto",path_data,"GuJianQiTan.GuJianQiTanMaze")
        self.movePassPath:clear();
    end
end

--信息装换成id
function M:infoToID( w, h )
    return tonumber(self.map_id) * 10000 + w * 100 + h
end

--处理回调
function M:handlerFinish()
    local fly = false;
    if self.select_grid ~= nil then
        local select_cell_id = self:infoToID(self.select_grid.w_pos, self.select_grid.h_pos)
        local m_server_data = self.migong_data.m_data.cells[tostring(select_cell_id)];
        local m_local_cell_data = self:getCellData(tostring(select_cell_id))
        if m_server_data ~= nil then
            --更新本地的数据状态
            m_local_cell_data.server_data.status = m_server_data.status;
            if m_server_data.status == 1 then
                self.select_grid:setValue(0)
                self:refreshCells(m_local_cell_data, false);
                if self.select_obj ~= nil then
                    self.select_obj:SetActive(false);
                    self.select_obj = nil;
                end
                local strTab = string.split( self.select_obj_name,'_' )
                local roomType = strTab[1];
                if roomType == "Room" then
                    local m_type = tonumber(strTab[2]);
                    if m_type == 1 or m_type == 2 or m_type == 3 then
                        fly = true;
                    end
                end
            end
            self:checkBoxAround( m_local_cell_data );
        end
        self.select_grid = nil
    end
    self:resetClickRoom();
end

--显示迷宫转场
function M:ShowMazeEffect()
    --显示迷宫转场动画
    SceneManager:getCurSceneView().cameraController:ShowMazeEffect();
end

--更新格子信息
function M:updateCellData( cell_id, event_id )
    local cell_data = self:getCellData(cell_id);
    if cell_data ~= nil and  cell_data.server_data ~= nil and cell_data.server_data.encounter ~= nil then
        cell_data.server_data.encounter.event_id = event_id;
    end
end


function M:selectCore( obj, data, id )
    local obj_name = data;
    --Logger.logError(" selectTargetGrid ~~~~~~~~~~~~~~~~~~~~~ obj.name = " .. tostring(obj.name) .. " ; obj_name = " .. tostring(obj_name))
    local strTab = string.split( obj.name,'_' )
    local map_strTab = string.split( obj_name,'_' )
    self.select_obj_name = obj.name;
    --roomType 物件类型
    local roomType = strTab[1];
    local w = 0;
    local h = 0;
    local m_type = tonumber(strTab[2]);
    local map_type = "xx";
    if string.find( roomType, "Room" ) then
        map_type = map_strTab[1]
        w = tonumber(map_strTab[3]);
        h = tonumber(map_strTab[4]);
    else
        w = tonumber(strTab[3]);
        h = tonumber(strTab[4]);
    end

    --起始格子和选中格子是同一个
    if self.startGrid.w_pos == w and self.startGrid.h_pos == h then
        return;
    end

    --当前点击时间 > 0 
    if self.curClickTime > 0 then
        Logger.logWarningAlways(self.curClickTime, "MiGongScene_Model self.curClickTime")
        return;
    end

    --鼠标点击时间 > 0.2
    if self.mouseDownTime > 0.2 then
        Logger.logWarningAlways(self.mouseDownTime, "MiGongScene_Model self.mouseDownTime")
        return;
    end

    --如果是在移动中
    if self.isInMoving == true then
        Logger.logWarningAlways(self.isInMoving, "MiGongScene_Model self.isInMoving")
        return;
    end

    --在移动到目标点的时候
    if self.isMoveToRoom == true then
        Logger.logWarningAlways(" 正在移动到目标点的时候不能点击 " )
        return;
    end

    --在传送中不能点击
    if self.isTranfering == true then
        Logger.logWarningAlways(" 在传送中不能点击 " )
        return;
    end

    self:sendEvent("maze_goto_guide",nil,"GuJianQiTan.GuJianQiTanMaze")
    self.curClickTime = self.clickTime;
    --我站立的格子
    local center = { w_pos = self.startGrid.w_pos, h_pos = self.startGrid.h_pos }
    --鼠标选中的格子
    local around = { w_pos = w, h_pos = h }

    -- 不在周围
    if string.find( roomType, "Room" ) and not self:isTransfer(m_type) then
        self.isMoveToRoom = true;
        if self.rewardType[m_type] ~= nil then
            self:clickObjectMode1(w, h, center, around, obj, m_type)
        else
            self:clickObjectMode2(w, h, center, around, obj, m_type)
        end
    else
        if self:isTransfer(m_type) then
            self.isTranfering = true;
        end
        self:clickEmpty(w, h)
    end
end


--点击到某个物体
function M:DownObj( obj, data, id )
    self:selectCore( obj, data, id );
end


--重新设定点击处理
function M:resetClickRoom()
    self.isMoveToRoom = false;
end


function M:clickObjectMode2(w, h, center, around, obj, m_type)
    --找到当前点击的格子数据
    local key = self:infoToID(w,h);
    --当前的格子数据
    self.select_map_data = self:getCellData(key);
    --当前选中的格子 
    self.select_grid = self.aStar.sceneData.data[w][h];
    --格子id
    self.select_map_data.server_data.id = tonumber(self.select_map_data.key)
    self.select_obj = obj;
    --如果当前的选中的格子可以点击
    if self.select_map_data ~= nil and self.select_map_data.item ~= nil and self.select_map_data.item:isCanClick() then
        --通知UI打开界面
        local data = {
            data = self.select_map_data.server_data,
            clickCallBack = function( moveBackdata )
                local callback = nil
                if moveBackdata ~= nil and moveBackdata.callback ~= nil then
                    callback = moveBackdata.callback
                end
                self:clickObjectCallNext(w, h, center, around, obj, m_type, callback );
            end
        }
        static_rootControl:updateMsg("cell_click",data,"GuJianQiTan.GuJianQiTanMaze")
    end
end


function M:clickObjectCallNext(w,h,center, around, obj, m_type, moveFinish)
    --点到物件
    if self:isAround(center,around) then
        --如果在周围 ~~ 只有不在移动的时候才能点击
        if self.isMove == false then
            self.autoUnlockSendServerTime = self.autoClickCellTime;
            if self.sendToServerNow == true then
                self:sendToServer();
                if moveFinish ~= nil then
                    moveFinish()
                end
                self.sendToServerNow = false
            end
        end
    else
        --Logger.logError(" 点击回调 ~~~~~~~~~~ 不在周围 ~~~~~~~~~~~ ")
        --不在周围
        local key = self:infoToID(w,h);
        local select_map_data = self:getCellData(key);
        --特效物体
        if self.click_effect ~= nil then
            self.click_effect.transform.position = select_map_data.obj.transform.position;
            self.click_set_effect_time = 1;
        end
        --目标格子
        self:findPaths(w,h);
        self:startGo(w,h);
        self.gotoFinish = function()
            self.autoUnlockSendServerTime = self.autoClickCellTime;
            if self.sendToServerNow == true then
                self:sendToServer();
                if moveFinish ~= nil then
                    moveFinish()
                end
                self.sendToServerNow = false
            end
        end
    end
end



--点击到了物件 模式1 选中某个物体，人先走道周围才弹出界面
-- w 横坐标 
-- h 纵坐标
function M:clickObjectMode1(w, h, center, around, obj, m_type)
    local key = self:infoToID(w,h);
    --当前的格子数据
    self.select_map_data = self:getCellData(key);
    --当前选中的格子 
    self.select_grid = self.aStar.sceneData.data[w][h];
    --格子id
    self.select_map_data.server_data.id = tonumber(self.select_map_data.key)
    self.select_obj = obj;
    if self.select_map_data and self.select_map_data.server_data and self.select_map_data.server_data.type == 21 and self.m_data.m_data.keys <= 0 then --特殊的奖励类型，上锁的宝箱，在跑过去前需要检查钥匙数量，有足够的钥匙再跑过去
        self:sendEvent("lock_box_without_key_tips", center_cell_data, "GuJianQiTan.GuJianQiTanMaze");
        return
    end
    
    --点到物件
    if self:isAround(center,around) then
        --如果在周围
        if self.select_map_data ~= nil and self.select_map_data.item ~= nil and self.select_map_data.item:isCanClick() then
            if self.isMove == false then
                --Logger.logError(" clickObjectMode1 静止中 ~~~~~~~~~~~ 在周围 "..m_type)
                self.autoUnlockSendServerTime = self.autoClickCellTime;
                if self.sendToServerNow == true then
                    self:sendToServerAll();
                    self.sendToServerNow = false
                end
            end
        end
    else
        --Logger.logError(" clickObjectMode1 ~~~~~~~~~~~ 不在周围 "..m_type)
        --不在周围
        local key = self:infoToID(w,h);
        local select_map_data = self:getCellData(key);
        --特效物体
        if self.click_effect ~= nil then
            self.click_effect.transform.position = select_map_data.obj.transform.position;
            self.click_set_effect_time = 1;
        end
        --目标格子
        self:findPaths(w,h);
        self:startGo(w,h);
    
        self.gotoFinish = function()
            self.autoUnlockSendServerTime = self.autoClickCellTime;
            if self.sendToServerNow == true then
                self:sendToServerAll();
                self.sendToServerNow = false
            end
        end
    end
end



function M:sendToServerAll()
    --移动结束的最后一个格子
    local data = { data = self.select_map_data.server_data }
    local cell_type = self.select_map_data.server_data.type
    if self.canClickType[cell_type] ~= nil then
        self:clickSure(cell_type, function()
            self:sendToServer();
            self:sendEvent("cell_click",data,"GuJianQiTan.GuJianQiTanMaze")
        end)
    end
end


--点击空地
function M:clickEmpty(w, h)
    --下面是点击空地
    --if self.isMove == false then
    local key = self:infoToID(w,h);
    local select_map_data = self:getCellData(key);
    --特效物体
    if self.click_effect ~= nil then
        self.click_effect.transform.position = select_map_data.obj.transform.position;
        self.click_set_effect_time = 1;
    end
    self.gotoFinish = nil;
    self:findPaths(w,h);
    self:startGo(w,h);
    audio:SendEvtUI('UI_Level_Selected')
    --end
end


--是否还有宝箱
function M:hasBox()
    local boxNum = 0;
    for k,v in pairs(self.map_data) do
        if v.server_data ~= nil and v.server_data.type == 14 and v.server_data.status ~= 1 then
            boxNum = boxNum +1
        end
    end
    return boxNum > 0
end

function M:clickSure( m_type, callback )
    if self.canClickType[m_type] ~= nil then
        if self.select_grid ~= nil then
            --目标格子
            --临时移动目标
            if self.player_view ~= nil then
                SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
            end
            if self.player ~= nil then
                self.player.animator:changeState("run")
            end
            self.temp_target = self.select_grid;
            self.startGrid = self.temp_target
            self.temp_moveFinish_callback = callback;
        end
    end
end

function M:playerAttack()
    self.isInMoving = true;
    self.player.animator:changeState("attack1")
    self.player.animator.curState.onCompleteHandler = function()
        self.player.animator:changeState("idle")
    end
end

--更新场景
--受到时间 TimeScale 影响的 更新函数
function M:update_dt(dt)
    M.super.update_dt(self,dt)
end

function M:upToQiao( obj, isDrect, center )
    if obj ~= nil and IsNull(obj) == false then
        local pos = obj.transform.localPosition
        if isDrect then
            if pos.y < 0 then
                pos.y = 0
                obj.transform.localPosition = pos
            end
        else
            if pos.y < 0 then
                local qiaoScript = self.pingtaiQiaoMgr:FindQiao(obj.name);
                qiaoScript:Play( center )
            end
        end
    end
end

--升起
function M:upToObj( objData, isDrect, finish )
    if objData.obj ~= nil and IsNull(objData.obj) == false then
        local pos = objData.obj.transform.localPosition
        if isDrect then
            if pos.y < 0 then
                pos.y = 0
                objData.obj.transform.localPosition = pos
            end
            if finish ~= nil then
                finish();
            end
        else
            if pos.y < 0 then
                objData.item:upToLand( finish );
            end
        end
        self:sendEvent("maze_show_grid", objData, "GuJianQiTan.GuJianQiTanMaze")
    end
end

--设定物体数据
function M:setObjData( m_obj, w_index, h_index )
    --取到格子数据
    local grid_data = nil;
    local m_cell_id = self:infoToID(w_index, h_index);
    local grid_data = self.config[m_cell_id];
    --属性 sx_id 小于0 表示 策划不想看到这个格子
    if grid_data ~= nil and grid_data.group < 99 then
        --云的脚本
        if m_obj ~= nil then
            m_obj:SetActive(true)
        end
        --if m_yun_obj ~= nil then
        --    m_yun_obj:SetActive(true)
        --end
        --  ["zs_id"] = 0,
        --  ["gn_id"] = 0,
        --  ["sx_id"] = 0,
        --存储的key
        local m_key = tostring(m_cell_id)
        --服务器下发数据
        local m_server_data = self.migong_data.m_data.cells[m_key];
        --迷宫Item, 在平台上的物件
        local m_item = require("Battle.Sce.Tools.GuJianItem").new();
        m_item:init( m_obj, m_server_data );
        if m_server_data ~= nil then
            if self:isTransfer(m_server_data.type) then
                local star_grid = self.aStar.sceneData.data[w_index][h_index];
                if star_grid ~= nil then
                    star_grid:setValue(0);
                end
            end
            --表示当前格子完成了
            local star_grid = self.aStar.sceneData.data[w_index][h_index];
            if star_grid ~= nil and m_server_data.status == 1 then
                m_item:destoryRoom();
                star_grid:setValue(0);
            end
            --记录当前层的门对象
            if m_server_data.type == 13 then
                self.door_obj = m_obj;
            end
        end
        --物体数据
        local objData = { 
            --格子数据
            data = grid_data,
            --地图id
            map_id = self.map_id, 
            --格子id
            cell_id = m_cell_id,
            --本地数据key
            key = m_key,
            --服务器下发的数据
            server_data = m_server_data;
            --横向
            w_pos = w_index,
            --纵向
            h_pos = h_index,
            --物体
            obj = m_obj,
            --云脚本
            --yun_script = m_yun_script,
            --item
            item = m_item,
            --云物体
            --yun_obj = m_yun_obj
        } 
        --存储到地图数据上
        self.map_data[m_key] = objData;
    else
        if m_obj ~= nil then
            m_obj:SetActive(false)
        end
        --if m_yun_obj ~= nil then
        --    m_yun_obj:SetActive(false)
        --end
    end
end

--获取格子数据
function M:getCellData( cell_id )
    return self.map_data[tostring(cell_id)]
end

--迷宫场景
function M:getCurSceneName()
    self:createSceneConfig(140)
    return self.scene_info.resource;
end


--加载场景Item
function M:loadSceneItem()
    --if self.obj ~= nil then
    --    self.sceneRoot = self.obj.transform:Find("SceneRoot")
    --    --获取导航
    --    local guideObj = self.obj.transform:Find("Guide")
    --    if guideObj ~= nil then
    --        local guideCls = require("Battle.Sce.Guide.MiGongGuide")
    --        self.guide = guideCls.new()
    --        self.guide:init( guideObj, self )
    --    end
    --end
end

--设定位置
function M:setPosition(dt,unsdt)
    M.super.setPosition(self,dt,unsdt)
end

--解析服务器传来的id数据
--1001 00 00
function M:idToInfo( id )
    local id = tonumber(id);
    local grid_info = {}
    local mapid = math.floor(id/10000);
    local grid_x = math.floor(id/100) - mapid * 100;
    local grid_y = id - mapid * 10000 - grid_x * 100;
    grid_info.mapid = mapid;
    grid_info.x = grid_x;
    grid_info.y = grid_y;
    return grid_info
end

--更新格子数据
function M:updateCellDataByCellId( cell_id, data )
    local cell_data = self:getCellData(cell_id);
    if cell_data ~= nil and cell_data.server_data ~= nil then
        table.merge(cell_data.server_data, data);
    end
end


--开始移动
function M:startGo( w, h )
    --打断发送服务器的时间
    self.curMoveEndTime = 0;
    local click_grid = self.aStar.sceneData.data[w][h]
    if self.path.Count > 0 then
        self.isMove = true;
        self.player.animator:changeState("run")
    end

    if click_grid.data ~= nil then
        local eventId = self:getEventId(click_grid.data);
        SceneManager.eventMgr:addEvent(eventId, click_grid.data);
    end

    if self.player ~= nil then
        SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
    end
end


--服务器返回移动
function M:rpgGoto(data)
    --next判断是否是空表
    if next(data) ~= nil then
        if data.is_transfer == 1 then
            local key = data.cell_id;
            local center_cell_data = self:getCellData(key)
            self.startGrid = self.aStar.sceneData.data[center_cell_data.w_pos][center_cell_data.h_pos];
            SceneManager:getCurSceneView().cameraController.Target = nil;
            local pos = center_cell_data.obj.transform.position;
            pos.y = 0;
            SceneManager:getCurSceneView().cameraController.gameObject.transform.position = pos;
            --迷宫小地图用的
            --self:sendEvent("maze_move_grid", center_cell_data, "GuJianQiTan.GuJianQiTanMaze");
            self:refreshCells(center_cell_data, false, true);
            self:checkBoxAround(center_cell_data);
            TimeTools:delayTimeUnity(1, function()
                self.path:clear();
                local pos = self.MapPos["map_scene_"..center_cell_data.w_pos.."_"..center_cell_data.h_pos]
                local grid_fix_pos = GlobalTools:ToFixVector3(pos);
                grid_fix_pos.y = self.player.position.y;
                self.player:setPos(grid_fix_pos)
                if _G.next(self.summon_list) then
                    for i, v in ipairs(self.summon_list) do
                        v:setPos(grid_fix_pos - FixVector3.New(1,0,1) * GlobalTools.base2_5)
                    end
                end
                if self.player_view.shunyi ~= nil then
                    self.player_view.shunyi:SetActive(false);
                    self.player_view.shunyi:SetActive(true);
                end
                SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
                self.isTranfering = false;
            end)
        end
        --后端报错了
        --if data.cell_error ~= nil then
        --    local server_cell_id = data.server_cell_id;
        --    local center_cell_data = self:getCellData(server_cell_id)
        --    self.startGrid = self.aStar.sceneData.data[center_cell_data.w_pos][center_cell_data.h_pos];
        --    --迷宫小地图用的
        --    self:refreshCells(center_cell_data, false, true);
        --    self:checkBoxAround(center_cell_data);
        --    self.path:clear();
        --    local pos = self.MapPos["map_scene_"..center_cell_data.w_pos.."_"..center_cell_data.h_pos]
        --    local grid_fix_pos = GlobalTools:ToFixVector3(pos);
        --    grid_fix_pos.y = self.player.position.y;
        --    self.player:setPos(grid_fix_pos)
        --    if self.player_view.shunyi ~= nil then
        --        self.player_view.shunyi:SetActive(false);
        --        self.player_view.shunyi:SetActive(true);
        --    end
        --    SceneManager:getCurSceneView().cameraController.Target = self.player_view.tran
        --end
        --local cur_click_info = self:idToInfo(data.click_id);
        --local click_grid = self.aStar.sceneData.data[cur_click_info.x][cur_click_info.y]
        
        --self.path:clear();
        --for k,v in ipairs(data.path) do
        --    local grid_info = self:idToInfo(v);
        --    local grid = self.aStar.sceneData.data[grid_info.x][grid_info.y]
        --    self.path:add(grid);
        --    Logger.logError(" 加入路径数据 "..grid_info.x.." - "..grid_info.y.." Count "..self.path.Count )
        --end
        --self:startGo();
    end
end


function M:stopScene()
    self.isMove = false;
    self.nextGrid = nil;
    self.path:clear();
    self.temp_target = nil
    self.isInMoving = false;
    self:resetClickRoom();
    GameMain.removeUpdate("Maze_Update");
end

--销毁
function M:destroy( nextScene )
    if self.player_view then
        if self.player_view.arrow ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.arrow);
            self.player_view.arrow = nil;
        end
        if self.player_view.tanhao ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.tanhao);
            self.player_view.tanhao = nil;
        end
        if self.player_view.shunyi ~= nil then
            U3DUtil:GameObjectDestroy(self.player_view.shunyi);
            self.player_view.shunyi = nil;
        end
    end
    
    M.super.destroy(self,nextScene);
    if self.headUI ~= nil then
        self.headUI:destroy();
        self.headUI = nil;
    end
    U3DUtil:GameObjectDestroy(self.click_effect);
    self.click_effect = nil;
    self.openCells = {};
    GameMain.removeUpdate("Maze_Update");
end

return M