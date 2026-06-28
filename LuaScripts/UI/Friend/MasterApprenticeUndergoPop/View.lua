local M = class("MasterApprenticeUndergoPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MasterApprenticeUndergoPop"
M.m_size_type = 2


function M:onEnter()
	self.msgs_content = self:findGameObject("msgs_content")
	self:refreshUI()
end

function M:refreshUI()
	self:creatMsgs()
end

function M:creatMsgs()
	for k,v in pairs(self.m_model.m_msgs) do
		local item = self:creatCell()
		local luaBehaviour = UIUtil.findLuaBehaviour(item)
		if luaBehaviour then
			local desc = self.m_model:getDesc(k)
			if desc then
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"desc_text", desc) 
			end

		end
	end
	local function func()
		self.msgs_content:SetActive(false)
		self.msgs_content:SetActive(true)
	end
	self.m_control:setOnceTimer(0.05, func)
end

function M:creatCell()
	local cell = ResourceUtil:LoadUIGameObject("Friend/MasterApprenticeUndergo_Cell", Vector3.zero,nil)
	cell.transform:SetParent(self.msgs_content.transform, false)
	return cell
end

return M