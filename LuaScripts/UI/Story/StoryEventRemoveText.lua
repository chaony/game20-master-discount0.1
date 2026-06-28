local M = class("StoryEventRemoveText", StoryEvent)

M.hasObj = false

function M:play() 
    local textParent = GlobalTools.FindTransform(self.group.obj.transform, "text")
   
    for i=1,textParent.childCount do
    	local text = textParent:GetChild(i).gameObject;
    	if text.activeSelf then
    		 text:SetActive(false);
    	end
    end

end

return M