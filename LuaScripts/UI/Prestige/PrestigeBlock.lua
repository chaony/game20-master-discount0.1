---@class PrestigeBlock : OOUIbase
local M = class("PrestigeBlock", LikeOO.OOUIbase)

M.m_uiName = "Prestige/PrestigeBlock"

function M:onEnter()
    self:init(self.m_params.data)
end

function M:resetData(data)
    self:init(data)
end

function M:init(data)
    self.shape = data.shape
    if data.block_data then
        self.block_data = data.block_data
        self.is_mini_shape = data.is_mini_shape
        self.id = self.block_data.id
    else
        self.block_data = data
        self.id = data.id
    end
    self.transform = self.m_rootView.transform
    self.graphic_raycaster = self.m_rootView:GetComponent("GraphicRaycaster")
    if self.is_mini_shape then
        self.graphic_raycaster.enabled = false
    else
        self:addTrigger("block_btn", handler(self, self.onPointerDown), handler(self, self.onPointerUp))
    end
end

-- 鼠标点击事件
function M:onPointerDown()
    local msg = "press_prestige_block_" .. self.id
    local target_control = "Prestige.PrestigeEditor"
    self:updateMsg(msg, nil, target_control)
end

function M:onPointerUp()

end

-- 初始化单块数据
function M:initBlockUnitData(unit_data)
    self.unit_data = unit_data
    self.unit_img_objs = {}
    for k,v in ipairs(self.unit_data) do
        local luaBehaviour = v.luaBehaviour
        local img_obj = luaBehaviour:FindGameObject("img")
        self.unit_img_objs[k] = img_obj
    end
end

-- 获取单块相对于棋盘的位置，id = 1 时为锚点位置
function M:getUnitPosRelatedToBoard(unit_id)
    local unit_obj = self.unit_data[unit_id].obj
    local unit_transform = unit_obj.transform
    local before_rotate_pos = unit_transform.localPosition
    local after_rotate_pos
    if self.block_data.status == 2 then
        after_rotate_pos = Vector3(before_rotate_pos.y, -before_rotate_pos.x, before_rotate_pos.z)
    elseif self.block_data.status == 3 then
        after_rotate_pos = Vector3(-before_rotate_pos.x, -before_rotate_pos.y, before_rotate_pos.z)
    elseif self.block_data.status == 4 then
        after_rotate_pos = Vector3(-before_rotate_pos.y, before_rotate_pos.x, before_rotate_pos.z)
    else
        after_rotate_pos = before_rotate_pos
    end
    local pos_related_to_board = after_rotate_pos + self.transform.localPosition
    return pos_related_to_board
end

-- 旋转棋子
function M:rotateByStatus()
    local rotate_z = (self.block_data.status - 1) * -90
    self.m_rt.localRotation = Quaternion.Euler(0, 0, rotate_z)
    for _,v in ipairs(self.unit_img_objs) do
        v.transform.localRotation = Quaternion.Euler(0, 0, -rotate_z)
    end
end

function M:getTransform()
    return self.m_rt
end

function M:destroy()
    M.super.destroy(self)
end

return M
