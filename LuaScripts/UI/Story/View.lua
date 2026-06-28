local M = class("StoryView",LikeOO.OOPopBase)

M.m_uiName = "Story/Story"
M.m_size_type = 2

function M:onEnter()
    M.super.onEnter(self)
    self:startStory(self.m_model.m_params.id)
end


function M:destroy()
    M.super.destroy(self)
end

function M:startStory(storyId)
    local file_name = "StoryData."..storyId
    local file_name_lua = "LuaScripts/StoryData/"..storyId..".lua"
    if io.exists(file_name_lua) then
        local data = require(file_name)
        self.curStory = require("UI.Story.StoryParagraph").new()

        self.curStory:init(data, self)
    else
        Logger.logError("加载的文件 "..file_name.." 不存在")
    end
end

function M:tryFinish()
    if self.curStory ~= nil then
        self.curStory:checkFinish()
    else
        self.m_control:closeView()
    end
end

function M:finish()
    self.curStory:destroy()
    self.curStory = nil
    self.m_control:closeView()
end

return M