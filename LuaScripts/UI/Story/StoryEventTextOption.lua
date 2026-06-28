local M = class("StoryEventFlicker", StoryEvent)

M.parentName = "options"

M.needFinish = true

function M:play()
    for i = 0, table.nums(self.data.options) - 1 do
        local data = self.data.options[i..""]
        local obj = ResourceUtil:LoadUIGameObject("Story/"..self.type .."_btn", Vector3.zero, self.obj)
        local btn = obj:GetComponent("Button")
        local textObj = GlobalTools:FindTransform(obj.transform, "Text")
        local text = textObj:GetComponent("Text")
        text.text = data

        btn.onClick:AddListener(
                function()
                    if self.group.cacheText ~= nil then
                        self.group.cacheText:reset()
                        self.group.cacheText = nil
                    end
                    local key = self.id .."_" .. i
                    if self.parentId ~= "" then
                        key = self.parentId + "." + key
                    end
                    self.group.curEventListId = key
                    self.group:play(key)
                    self:finish()
                    btn.onClick:RemoveAllListeners()
                end)
    end
end

function M:finish()
    self:reset()
end

return M