local M = class("StoryEventRemoveTexture", StoryEvent)

M.hasObj = false

function M:play() 
    local texture_obj = GlobalTools.FindTransform(self.group.obj.transform, self.data.textureId)
    
    self.image = texture_obj:GetComponent("Image")
    self.image:SetActive(false)

end

return M