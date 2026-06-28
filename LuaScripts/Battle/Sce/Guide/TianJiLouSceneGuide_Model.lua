--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-17 19:45:55
]]

--天机楼场景引导
---@class TianJiLouSceneGuide_Model @
local M = class("TianJiLouSceneGuide_Model")

--目标点
M.target = nil
--初始化
function M:init( guide, scene )

    self.sceneGuide = guide
    --导航组件上面的Transform组件
    self.sceneGuideTran = guide:GetComponent("Transform")
    self.sceneGuideScript = guide:GetComponent("SceneGuide_Tianji")
    self.luaViewHelper = guide:GetComponent("LuaViewHelper")

    self.playerHelperArr = LuaCSharpArr.New(8)
	local CSharpAccess = self.playerHelperArr:GetCSharpAccess()
    self.luaViewHelper:PinTable(CSharpAccess)
    
    --位置
    self.startPosition = FixVector3.New(-22.07, -5.8, 1.16)
    --初始位置
    self:setPos( self.startPosition );
    --初始方向
    self:setForward( GlobalTools:ToFixVector3(self.sceneGuideTran.forward) )
    self.curSpeed = 7;
    self:initPoints();
    self.cameraStart =  false;
    self.moveEndTime = 5;
    self.curMoveEndTime = self.moveEndTime;
    --旋转时间
    self.rotationTime = 0.3;
    --当前旋转时间
    self.curRotationTime = 0;
end

function M:setPos( pos )
    if self.positon == nil then
        self.position = FixVector3.New(0,0,0)
    end
    self.position.x = pos.x;
    self.position.y = pos.y;
    self.position.z = pos.z;
end

function M:setForward( dir )
    if self.moveDirection == nil then
        self.moveDirection = FixVector3.New(0,0,0)
    end
    self.moveDirection.x = dir.x;
    self.moveDirection.y = dir.y;
    self.moveDirection.z = dir.z;
end



--初始化点
function M:initPoints()
	
	--玩家要跟随的点
	self.pointLists = Battle.List.new()
	for i=1,self.sceneGuideTran.childCount,1 do
		self.pointLists:add(self.sceneGuideTran:GetChild(i-1))
    end
    
    self.sceneItemList = Battle.List.new()
    self.sceneDirList = Battle.List.new();
    for i=1,self.sceneGuideScript.sceneItems.Count do
        local pos = GlobalTools:ToFixVector3( self.sceneGuideScript.sceneItems[i-1].transform.position )
        local dir = GlobalTools:ToFixVector3( self.sceneGuideScript.sceneItems[i-1].transform.forward )
        self.sceneItemList:add(pos);
        self.sceneDirList:add(dir);
    end

    self.index = 0;
    self.maxIndex = self.sceneItemList.Count
end

--开始播放
function M:play()
    self.target = self.sceneItemList:get(self.index)
    self.targetDir = self.sceneDirList:get(self.index)
end

function M:destroy()
    self.sceneGuide = nil
    --导航组件上面的Transform组件
    self.sceneGuideTran = nil
end

--更新
function M:update(dt,unsdt)
    if self.target ~= nil then
        if self.curMoveEndTime > 0 then
            self.curMoveEndTime = self.curMoveEndTime - dt;
            if self.curMoveEndTime <= 0 then
                self:battleStart();
                self.curMoveEndTime = 0;
            end
        end
        --距离
        -- local dis = GlobalTools:Distance3D(self.target, self.position)
        -- --
        -- if dis > GlobalTools:ToFix2(0.1) then
        --     self:setForward(GlobalTools:Dir3D(self.target,self.position));
        --     --位置改变
        --     local outPos = self.moveDirection * self.curSpeed * dt
        --     self:setPos( self.position + outPos )
        -- else
        --     self.index = self.index + 1
        --     if self.index < self.sceneItemList.Count then
        --         self.target = self.sceneItemList:get(self.index)
        --         self.targetDir = self.sceneDirList:get(self.index)
        --     else
        --         self:setPos( self.target );
        --         self:setForward(self.targetDir);
        --         self:battleStart()
        --         self.target = nil;
        --         self.targetDir = nil;
        --     end
        -- end
    end
end

--战斗开始
function M:battleStart()
    static_rootControl:updateMsg("player_move_end",nil,"TowerStage.TowerStageStartBattle")
end

--获取追踪点
function M:getPoint(index)
	if index >= self.pointLists.Count then
		index = 0
    end
    local position = self.pointLists:get(index).position
	return GlobalTools:ToFixVector3(position)
end


function M:setPosition()
    self.playerHelperArr[1] = self.position.x;
    self.playerHelperArr[2] = self.position.y;
    self.playerHelperArr[3] = self.position.z;

    self.playerHelperArr[4] = self.moveDirection.x;
    self.playerHelperArr[5] = self.moveDirection.y;
    self.playerHelperArr[6] = self.moveDirection.z;
end

return M

