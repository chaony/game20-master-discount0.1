local M = class("StoryEventMoveTexture", StoryEvent)

M.hasObj = false

function M:play()
    self.waitTime = tonumber(self.data.waitTime)

    local texture_obj = GlobalTools:FindTransform(self.group.obj.transform, self.data.textureId)
    
    self.image = texture_obj:GetComponent("Image")
    local sequence = Tweening.DOTween.Sequence()
    local rectTransform = self.image.rectTransform
    if IsNull(self.image) == false then 

    	sequence:Append(DOTweenModuleUI.DOAnchorPos(rectTransform, self:getVector2(tonumber(self.data.Pos.x), tonumber(self.data.Pos.y)), self.waitTime))

	    if IsNull(self.image.sprite) == false then
	        sequence:Join(DOTweenModuleUI.DOSizeDelta(rectTransform, self:getVector2(self.image.sprite.rect.width * tonumber(self.data.Scale.x), self.image.sprite.rect.height * tonumber(self.data.Scale.y)), self.waitTime));
	    end

	    sequence:Join(DOTweenModuleUI.DOFade(self.image, tonumber(self.data.Alpha), self.waitTime));

	    sequence:OnComplete(function() 
	        self:finish()
	    end)
    end
end

return M