local M = class("StoryEventText", StoryEvent)

M.parentName = "text"

M.startPlay = false

M.needFinish = true

function M:createObj()
    local parent = GlobalTools:FindTransform(self.group.obj.transform, self.parentName)
    local trans = GlobalTools:FindTransform(parent, "storyText")
    if trans ~= nil then
        self.obj = trans.gameObject
    else
        self.obj = ResourceUtil:LoadUIGameObject("Story/Story"..self.type, Vector3.zero, parent.gameObject)
        self.obj.transform.localPosition = Vector3.New(0,0,0);
        self.obj.name = "storyText"
        local rect = self.obj:GetComponent("RectTransform")
        local offsetMin = rect.offsetMin
        offsetMin.x = 0
        offsetMin.y = 0
        rect.offsetMin = offsetMin

        local offsetMax = rect.offsetMax
        offsetMax.x = 0
        offsetMax.y = 0
        rect.offsetMax = offsetMax
    end
end

function M:play()
    local chat_tran = GlobalTools:FindTransform(self.obj.transform, "chat")
    local name_tran = GlobalTools:FindTransform(self.obj.transform, "role_name")

    local chat_text_tran = GlobalTools:FindTransform(self.obj.transform, "chat_text")
    local chat_text = chat_text_tran:GetComponent("Text")
    local name_text_tran = GlobalTools:FindTransform(self.obj.transform, "name_text")
    local name_text = name_text_tran:GetComponent("Text")

    local chat_img_tran = GlobalTools:FindTransform(self.obj.transform, "bg_img")
    local chat_img = chat_img_tran:GetComponent("Image")
    local name_img_tran = GlobalTools:FindTransform(self.obj.transform, "name_bg")
    local name_img = name_img_tran:GetComponent("Image")

    self:loadSprite(chat_img, self.data.chat_imagePath)
    self:loadSprite(name_img, self.data.name_imagePath)
    chat_text.text = self.data.message
    name_text.text = self.data.roleName

    chat_text.fontSize = self.data.messageFont_size
    name_text.fontSize = self.data.roleFont_size

    
    local name_color = name_text.color
    local color = ColorHexHelper.FromHexUnit(self.data.roleName_color)
    name_color.r = color.r
    name_color.g = color.g
    name_color.b = color.b
    name_color.a = color.a
    name_text.color = name_color

    local chat_color = chat_text.color
    local color1 = ColorHexHelper.FromHexUnit(self.data.message_color)
    chat_color.r = color1.r
    chat_color.g = color1.g
    chat_color.b = color1.b
    chat_color.a = color1.a
    chat_text.color = chat_color

    chat_img.rectTransform.anchoredPosition = self:getVector2(tonumber(self.data.chatPos.x), tonumber(self.data.chatPos.y));
    name_img.rectTransform.anchoredPosition = self:getVector2(tonumber(self.data.namePos.x), tonumber(self.data.namePos.y));
    chat_img.rectTransform.sizeDelta = self:getVector2(tonumber(self.data.chatScale.x), tonumber(self.data.chatScale.y));
    name_img.rectTransform.sizeDelta = self:getVector2(tonumber(self.data.nameScale.x), tonumber(self.data.nameScale.y));
    
    local clickToNext = self.data.clickToNext == "True"
    self.group.cacheText = self
    if clickToNext then
        local nextBtnObj = GlobalTools:FindTransform(self.obj.transform, "next")
        local nextBtn = nextBtnObj:GetComponent("Button")
        nextBtn.onClick:RemoveAllListeners()
        nextBtn.onClick:AddListener(
                function()
                    self:finish()
                    nextBtn.onClick:RemoveAllListeners()
                end)
    else
        self.startPlay = true
        local function waitForFinish()
            self:finish()
        end
        self.shake = self.group.story.view.m_control:setTimer(tonumber(self.data.waitTime), waitForFinish)
    end
end

return M