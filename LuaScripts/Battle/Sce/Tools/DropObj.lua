--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-02-28 18:51:41
]]

--玩家死后的掉落物
---@class DropObj @
local M = class("DropObj")

function M:init(itemName, from)
    self.speed = 20
    self.liveTime = 0.5;
    self.curLiveTime = 0;
    self.obj = ResourceUtil:GetItem("Common/"..itemName, SceneManager.curScene.gameObject, "common")
    self.obj.transform.position = from;
    self.tran = self.obj:GetComponent("LuaTransformHelper")
    self.luaViewHelper = self.obj:GetComponent("LuaViewHelper")

    self.playerHelperArr = LuaCSharpArr.New(6)
	local CSharpAccess = self.playerHelperArr:GetCSharpAccess()
	self.luaViewHelper:PinTable(CSharpAccess)

    self.moveing = false;
    self.finish = false;
    self.delayTime = math.random(3,8) * 0.1;
    self.position = self.obj.transform.position;
    
    self.playerHelperArr[1] = GlobalTools:ToFix( self.position.x );
    self.playerHelperArr[2] = GlobalTools:ToFix( self.position.y );
    self.playerHelperArr[3] = GlobalTools:ToFix( self.position.z );

    self.tuowei = self.tran:FindObj(self.obj.transform,"tuowei")
    if self.tuowei then
        self.tuowei:SetActive(false)
    end
    self.target = SceneManager.curScene.cameraController.transform:Find("Target");
    TimeTools:delayTimeUnity(self.liveTime + self.delayTime,function()
        self:destroy();
    end)
end


function M:update(dt)
    if self.delayTime > 0 then
        self.delayTime = self.delayTime  - dt;
        if self.delayTime <= 0 then
            self.moveing = true
            if self.tuowei then
                self.tuowei:SetActive(true)
            end
        end
    end

    if self.moveing == true then
        self.curLiveTime = self.curLiveTime + dt;
        if self.curLiveTime >= self.liveTime then
            self.curLiveTime = self.liveTime;
        end
        if GlobalTools.dropFlyTarget ~= nil then
            self.target_position = UIUtil.UITo3D( GlobalTools.dropFlyTarget.position );
            self.target.position = self.target_position;
        end
        self.percent = self.curLiveTime / self.liveTime;
        -- if self.obj ~= nil then
        --     self.obj.transform.position = Vector3.Lerp(self.obj.transform.position,self.target.position,self.percent);
        -- end
        self.position = Vector3.Lerp(self.position,self.target.position,self.percent);

        self.playerHelperArr[1] = GlobalTools:ToFix( self.position.x );
        self.playerHelperArr[2] = GlobalTools:ToFix( self.position.y );
        self.playerHelperArr[3] = GlobalTools:ToFix( self.position.z );

        local distance = Vector3.Distance(self.obj.transform.position, self.target.position);
        if distance < 0.2 then
            self.moveing = false;
            self:destroy();
        end
    end
end

--销毁
function M:destroy()
    if self.obj ~= nil then
        self.moveing = false
        self.finish = true;
        ResourceUtil:ReturnItem(self.obj);
        self.obj = nil;
    end
end

return M