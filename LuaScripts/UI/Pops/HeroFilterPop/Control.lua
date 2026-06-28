local M = class("HeroFilterPopControl",LikeOO.OOControlBase)

function M:onEnter()
	
end

function M:onHandle(msg , data)
    if msg == 99999 then 
		self:closeView()
	elseif msg == "cancle_btn" then
		self:closeView()
	elseif msg == "check_index" then
		if type(self.m_model.m_callback) == "function" then
    		self.m_model.m_callback(data)
    	end
		self:closeView()
    end
end

return M;
