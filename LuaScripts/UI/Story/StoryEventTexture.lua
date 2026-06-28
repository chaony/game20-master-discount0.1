local M = class("StoryEventTexture", StoryEvent)

function M:createObj()
    local textureNumber = self.data.textureNumber
    if textureNumber == "1" then
        self.parentName = "distant"
    elseif textureNumber == "2" then
        self.parentName = "background"
    elseif textureNumber == "23" then
        self.parentName = "foreground"
    else
        self.parentName = "character"
    end
    
    local parent = GlobalTools:FindTransform(self.group.obj.transform, self.parentName)
    local trans = GlobalTools:FindTransform(parent, textureNumber)
    if trans ~= nil then
        self.obj = trans.gameObject
    else
        self.obj = ResourceUtil:LoadUIGameObject("Story/Story"..self.type, Vector3.zero, parent.gameObject)
        self.obj.transform.localPosition = Vector3.New(0,0,0);
        self.obj.name = textureNumber
    end
end

function M:play()
    self.image = self.obj:GetComponent("Image")

    self:loadSprite(self.image, self.data.imagePath)
    
    local isMirror = self.data.isMirror == "True"
    local scale = self.image.transform.localScale
    if isMirror == true then
        scale.x = -1;
    else
        scale.x = 1
    end
    self.image.transform.localScale = scale;
    
    local rectTransform = self.image.rectTransform
    rectTransform.anchoredPosition = self:getVector2(tonumber(self.data.Pos.x), tonumber(self.data.Pos.y))

    if IsNull(self.image.sprite) == false then
        rectTransform.sizeDelta = self:getVector2(self.image.sprite.rect.width * 
            tonumber(self.data.Scale.x), 
            self.image.sprite.rect.height * tonumber(self.data.Scale.y));
    end

    local color = self.image.color;
    color.a = tonumber(self.data.Alpha)
    self.image.color = color;
end

return M