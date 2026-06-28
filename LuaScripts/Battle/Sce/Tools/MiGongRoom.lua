---@class MiGongRoom @
local M = class("MiGongRoom")

--1.小怪 2.精英 3.boss 4.客栈 5.医馆 6.药王庙 7.商铺 8.空格 9.起点 10.怨灵马车 11.宝藏洞窟
function M:init( m_type, parent, data )
    self:resetData(m_type, data);
    if self.obj ~= nil then
        self:destroy();
    end
    self.roomObj = SceneManager:getCurSceneView():instanceGameObject("Room_"..m_type,parent);
    self.roomObj.transform.localPosition = Vector3(0,0,0);
    self.roomObj.name = "Room_"..m_type;
    self.luaHelper = self.roomObj:GetComponent("LuaTransformHelper");
    --self.roomBox = self.roomObj:GetComponent("BoxCollider");
    self.headObj = self.luaHelper:FindObj(self.roomObj.transform, "head");
end

--显示可以点击的物体
function M:showHead( show )
    if self.headObj ~= nil then
        self.headObj:SetActive( show );
    end
end

function M:resetData(m_type, data)
    self.sourceData = data;
    self.room_type = m_type;
end

function M:update_dt(dt)

end


function M:getName()
    if self.room_type == 1 then
        return "小怪"
    elseif self.room_type == 2 then
        return "精英"
    elseif self.room_type == 3 then
        return "boss"
    elseif self.room_type == 4 then
        return "客栈"
    elseif self.room_type == 5 then
        return "医馆"
    elseif self.room_type == 6 then
        return "药王庙"
    elseif self.room_type == 7 then
        return "商铺"
    elseif self.room_type == 8 then
        return "空格"
    elseif self.room_type == 9 then
        return "起点"
    elseif self.room_type == 10 then
        return "怨灵马车"
    elseif self.room_type == 11 then
        return "宝藏洞窟"
    elseif self.room_type == 12 then
        return "事件"
    elseif self.room_type == 13 then
        return "出口"
    elseif self.room_type == 14 then
        return "地图宝箱"
    end
end


--返回Room位置
function M:getPosition()
    return GlobalTools:ToFixVector3(self.obj.transform.position);
end


function M:destroy()
    if self.roomObj ~= nil then
        ResourceUtil:DestroyInstance(self.roomObj);
        self.roomObj = nil;
    end
    if self.obj ~= nil then
        ResourceUtil:DestroyInstance(self.obj);
        self.obj = nil;
    end
end

return M;