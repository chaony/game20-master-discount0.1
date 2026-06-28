local M = class("StoryEventFlicker", StoryEvent)

M.parentName = "flicker"

function M:play()

    self.image = self.obj:GetComponent("Image")
    
    local color = ColorHexHelper.FromHexUnit(self.data.img_color)

    color.a = 1
    
    self.image.color = color

    local sequence = Tweening.DOTween.Sequence()
    
    local tween = DOTweenModuleUI.DOFade(self.image, 0, tonumber(self.data.flickerTime))
    tween:SetEase(Tweening.Ease.Flash)
    sequence:Append(tween)
    sequence:OnComplete(function()
        self:finish()
    end)
end

return M