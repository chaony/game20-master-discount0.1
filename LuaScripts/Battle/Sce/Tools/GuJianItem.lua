--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-03-04 16:29:59
]]

---@class GuJianItem @
local M = class("GuJianItem")

function M:init( item_obj, data )
    self.obj = item_obj
    --MiGongPingTai
    self.script = self.obj:GetComponent("MiGongPingTai");
    self.script:ClearChild();
    --是否可以点击
    self.canClick = true;
    --data == nil 表示没有放东西
    if data ~= nil then
        self:resetData( data );
    end
    self.isPlaying = false;
end

--升起
function M:upToLand( finish )
    if self.isPlaying == false then
        self.script:Play( function()
            if finish ~= nil then
                finish();
            end
            self.isPlaying = false;
        end )
        local shuiEffect = SceneManager:getCurSceneView():instanceGameObject("FX_MiGong_Taizi_001",self.obj);
        if shuiEffect ~= nit then
            shuiEffect.transform.localPosition = Vector3(0,0,0)
        end
        self.isPlaying = true;
    end
end

--disable
function M:disable( loadfinish )
    if self.room ~= nil then
        self.room.roomObj:SetActive(false)
    end
end

--更新
function M:update_dt(dt)
    if self.room ~= nil then
        self.room:update_dt(dt);
    end
end

function M:isTransfer( m_type )
    if m_type == 17 or m_type == 18 or m_type == 19 or m_type == 20then
        return true
    end
    return false;
end

--重新设置数据
function M:resetData( data )
    --是否开启
    self.sourceData = data;
    self.m_type = data.type;
    self.status = data.status;
    if self.status == 0 or self:isTransfer(self.m_type) then
        self:createRoom();
    end
end

--创建宝箱
function M:createBox()
    if self.obj ~= nil then
        local box_tran = self.obj.transform:Find("Box");
        if box_tran ~= nil then
            self.boxobj = box_tran.gameObject;
            self.boxobj:SetActive(true);
            self.boxobj.transform.localPosition = Vector3(0,0,0);
            self.boxobj.transform.localRotation = Quaternion.Euler(0,-60,0);
            self.boxobj.transform.localScale = Vector3(1,1,1);
        end
    else
        Logger.logError("Error : "..self.obj.name);
    end
end

--创建房子
function M:createRoom()
    if self.room == nil then
        self.room = require("Battle.Sce.Tools.GuJianRoom").new()
        self.room:init(self.m_type, self.obj, self.sourceData );
    end
end

--是否显示可以点击的标识
function M:showHead( show )
    if self.room ~= nil then
        self.room:showHead( show )
    end
    self.canClick = show;
end

--是否可以点击
function M:isCanClick()
    return self.canClick;
end


--销毁房间
function M:destoryRoom()
    if self.room ~= nil then
        self.room:destroy();
        self.room = nil;
    end
end

--销毁
function M:destroy()
    if self.obj ~= nil then
        self:destoryRoom();
        self.obj = nil;
    end
    --销毁宝箱
    if self.boxobj ~= nil then
        self.boxobj:SetActive(false);
        self.boxobj = nil;
    end
end

return M