--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-04 13:37:48
]]
---@class MiGongGuide_Model @
local M = class("MiGongGuide_Model")

M.isMove = true;

M.scene =nil

function M:init( guide, scene )
    self.targetPoint = nil;
    self.mouseDown = false;
    self.mouseDownTime = 0;
    self.mouseUpTime = 0;
    self.scene = scene
    --场景巡逻器
    self.sceneGuide = guide
    --是否可以移动
    self.isMove = false;

    self.isClickBox = false;
    self.isClickOpenDoor = false;
    --导航组件上面的Transform组件
    self.sceneGuideTran = self.sceneGuide:GetComponent("Transform")
    --玩家要跟随的点
	self.pointLists = Battle.List.new()
	for i=1,self.sceneGuideTran.childCount,1 do
		self.pointLists:add(self.sceneGuideTran:GetChild(i-1))
    end
    self.fix_pos_list = {}
    for i = 1, 5 do
        self.fix_pos_list[i] = FixVector3(0,0,0)
    end
    
    CS.GameObjectClickMgr.Inst:Register("ClickObj",handler(self,self.clickObject))
end

--GameObject, string, int
function M:clickObject( obj, data, id )
    local obj_name = data;
    local strTab = string.split( obj_name,'_' )
    if string.find( strTab[1], "Room" ) then
        local index = tonumber(strTab[2]);
        local item = SceneManager.curScene:getItemByIndex(index);
        if item:isCanClick() then
            --记录当前的id
            SceneManager.curScene:remeberId( item );
            static_rootControl:updateMsg("cell_click",{data = item.sourceData, id = item.index},"MazeStage")
        end
    else
         --self:startMove(obj)
    end

    if string.find( obj_name,"Box" ) then
        local is_over = SceneManager.curScene.migong_data:getFloorIsOver()
        local data = SceneManager.curScene.migong_data.m_data;
        if is_over then
            if data.recv == 0 then
                if self.isClickBox == false then
                    static_rootControl:updateMsg("box_btn",nil,"MazeStage");
                    SceneManager.curScene.open_door:SetActive(true);
                    obj.transform.parent.gameObject:SetActive(false);
                    self.isClickBox = true;
                end
            end
        end
    elseif string.find( obj_name,"OpenDoor" ) then
        local is_over = SceneManager.curScene.migong_data:getFloorIsOver()
        local data = SceneManager.curScene.migong_data.m_data;
        if is_over then
            if self.isClickOpenDoor == false then
                self:startMove(obj)
                self.isClickOpenDoor = true;
            end
        end
    end
end


function M:destroy()
    self.sceneGuide = nil
    --导航组件上面的Transform组件
    self.sceneGuideTran = nil
end

--获取追踪点
function M:getPoint(index)
	if index >= self.pointLists.Count then
		index = 0
    end
    local position = self.pointLists:get(index).position
    local position_fix = self.fix_pos_list[index+1]
    position_fix:Set(position.x,position.y,position.z)
	return position_fix
end

--操作结束
function M:startMove(obj)
    self.isMove = true;
    if self.scene.mache ~= nil then
        self.scene.mache:PlayRun("run")
    end
    self.targetPoint = obj;
    self.targetPos = Vector3(self.targetPoint.transform.position.x, self.targetPoint.transform.position.y, self.targetPoint.transform.position.z)
    self.mPos = Vector3(self.sceneGuideTran.position.x, self.sceneGuideTran.position.y, self.sceneGuideTran.position.z);
end

--更新
function M:update(dt)
    if self.isMove == true then
        if self.targetPoint ~= nil then
            self.mPos.x = self.sceneGuideTran.position.x;
            self.mPos.y = self.sceneGuideTran.position.y;
            self.mPos.z = self.sceneGuideTran.position.z;
            local distance = GlobalTools:Distance( self.targetPos,self.mPos );
            if distance > 1 then
                local dir = GlobalTools:Dir( self.targetPos, self.mPos );
                self.sceneGuideTran.position = self.sceneGuideTran.position + dir * 15 * dt;
                local chardir = Vector3(self.sceneGuideTran.forward.x, 0, self.sceneGuideTran.forward.z);
                self.sceneGuideTran.forward = Vector3.RotateTowards(chardir, Vector3(dir.x, 0, dir.z),  2*dt, 1000000);
            else
                self.isMove = false;
                self.scene.mache:PlayRun("idle")
                local is_over = SceneManager.curScene.migong_data:getFloorIsOver()
                SceneManager.curScene:arrive();
                if is_over and self.isClickOpenDoor then
                    static_rootControl:updateMsg("next_btn",nil,"MazeStage");
                end
            end
        end
    end

    if self.mouseDownTime > 0 then
        self.mouseDownTime = self.mouseDownTime -dt;
        if self.mouseDownTime <= 0 then
            self.mouseDownTime = 0
        end
    end 

    --if U3DUtil:Input_GetMouseButtonDown(0) then
    --    if self.mouseDownTime <= 0 then
    --        self.mouseDown = true;
    --    end
    --
    --    local obj = CS.GameObjectClickMgr.Inst:GetMouseDownGameObject();
    --    if IsNull(obj) == false then
    --        local obj_name = obj.transform.parent.name;
    --        local strTab = string.split( obj_name,'_' )
    --        if string.find( strTab[1], "Room" ) then
    --            local index = tonumber(strTab[2]);
    --            local item = SceneManager.curScene:getItemByIndex(index);
    --            if item:isCanClick() then
    --                --记录当前的id
    --                SceneManager.curScene:remeberId( item );
    --                static_rootControl:updateMsg("cell_click",{data = item.sourceData, id = item.index},"MazeStage")
    --            end
    --        end
    --        
    --        if string.find( obj.name,"Box" ) then
    --            local is_over = SceneManager.curScene.migong_data:getFloorIsOver()
    --            local data = SceneManager.curScene.migong_data.m_data;
    --            if is_over then
    --                if data.recv == 0 then
    --                    if self.isClickBox == false then
    --                        static_rootControl:updateMsg("box_btn",nil,"MazeStage");
    --                        SceneManager.curScene.open_door:SetActive(true);
    --                        obj:SetActive(false);
    --                        self.isClickBox = true;
    --                    end
    --                end
    --            end
    --        elseif string.find( obj.name,"OpenDoor" ) then
    --            local is_over = SceneManager.curScene.migong_data:getFloorIsOver()
    --            local data = SceneManager.curScene.migong_data.m_data;
    --            if is_over then
    --                if self.isClickOpenDoor == false then
    --                    self:startMove(obj)
    --                    self.isClickOpenDoor = true;
    --                end
    --            end
    --        end  
    --    end
    --end
    --
    --if U3DUtil:Input_GetMouseButtonUp(0) and self.mouseDown then
    --    if self.mouseDown then
    --        self.mouseDown =  false; 
    --    end     
    --end
end


function M:setPosition()

end

return M