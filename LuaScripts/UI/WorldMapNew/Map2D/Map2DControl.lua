local M = class("Map2DControl")

function M:init( control )
    self.m_control = control;
    self.stack = LikeOO.OOStack.new()
    self.map_table = ConfigManager:getCfgByName("new_regional_map")
    self.curMap2D = nil;
end

--打开
function M:openMap2D( id , callback)
    self:changeScene(id, function()
        if self.curMap2D ~= nil then
            self.stack:addData(self.curMap2D.map_id)
            self.curMap2D:destroy()
        end
        local motherMapId = self:getMotherMapId(id)
        local isFirst = self.curMap2D == nil or self.curMap2D.motherMapId ~= motherMapId
        self.curMap2D = require("UI.WorldMapNew.Map2D.Map2D").new(self.m_control, {map_id = id, is_first = isFirst, callback = callback})
        audio:SendEvtUI("UI_ChangeScene")
    end)

end

--返回上一步
function M:back()
    if self.stack:hasData() then
        local cur_map_id = self.stack:pop()
        self:changeScene(cur_map_id, function()
            if self.curMap2D ~= nil then
                self.curMap2D:destroy()
            end
            self.curMap2D = require("UI.WorldMapNew.Map2D.Map2D").new(self.m_control, {map_id = cur_map_id, is_first = false})
        end)
    else
        if self.curMap2D ~= nil then
            self:closeMap()
        end
    end
end

--返回表里的母场景
function M:backToHigherMap()
    if self.curMap2D ~= nil then
        local motherMapId = self.map_table[self.curMap2D.map_id].mother_map_id
        if motherMapId ~= 0 and motherMapId ~= self.curMap2D.map_id then
            local cur_map_id = motherMapId
            self:changeScene(cur_map_id, function()
                if self.curMap2D ~= nil then
                    self.curMap2D:destroy()
                end
                self.curMap2D = require("UI.WorldMapNew.Map2D.Map2D").new(self.m_control, {map_id = cur_map_id, is_first = false})
            end)
        else
            if self.curMap2D ~= nil then
                self:closeMap()
            end
        end
    end
end

function M:backToMother()
    if self.curMap2D ~= nil then
        self.stack:cleanAll()
        local mother_map_id = self.curMap2D.motherMapId

        if mother_map_id ~= self.curMap2D.map_id then
            self:changeScene(mother_map_id, function()
                if self.curMap2D ~= nil then
                    self.curMap2D:destroy()
                end
                self.curMap2D = require("UI.WorldMapNew.Map2D.Map2D").new(self.m_control, {map_id = mother_map_id, is_first = false})
            end)
        else
            self:closeMap()
        end
    end
end

function M:closeMap(needMove)
    if self.curMap2D ~= nil then
        self.stack:cleanAll()

        self.curMap2D:destroy()
        self.curMap2D = nil;
        if SceneManager.curScene.checkPlayerMove ~= nil and needMove ~= false then
            SceneManager.curScene:checkPlayerMove()
        end
    end
end

function M:cameraShake(strength, time)
    if self.curMap2D ~= nil then
        local shakeTime = time
        local shakeDelta = 0.005
        self.shake = self.m_control:setTimer(0.033, function()
            if shakeTime > 0 then
                shakeTime = shakeTime - 0.033
                if shakeTime <= 0 then
                    self:setCameraRect(0,0,1,1)
                    self.m_control:removeTimer(self.shake)
                else
                    self:setCameraRect(shakeDelta * ( -1 + strength * math.random()),shakeDelta * ( -1 + strength * math.random()),1,1)
                end
            end
        end)
    end
end

function M:setCameraRect(x, y, w, h)
    local rect = static_ui_camera.rect
    rect.x = x
    rect.y = y
    rect.width = w
    rect.height = h
    static_ui_camera.rect = rect
end

function M:changeScene(map_id, changeFunc)
    if self.changeSceneNode == nil then
        local tab_cls = CustomRequire("UI.WorldMapNew.Map2D.ChangeSceneNode")
        self.changeSceneNode = tab_cls.new(self.m_control, {changeDir = self.map_table[map_id].scene_switching, changeFunc = changeFunc, finish = function()
            self.changeSceneNode = nil
        end })
    end
end

--获取任务根场景id
function M:getMotherMapId(id)
    local mother_map_id = self.map_table[id].mother_map_id
    if mother_map_id > 0 then
        if id == mother_map_id then return id end
        return self:getMotherMapId(mother_map_id)
    end
    return id
end

return M