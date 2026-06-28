local M = class("HelpDagLevelView",LikeOO.OOPopBase)

M.m_uiName = "LittleGames/HelpDog/HelpDagLevel"
M.m_size_type = 2


function M:onEnter()
	self.m_content_panel = self:findGameObject("content_panel")
	self:setTextByLanKey("stage_name", Language:getTextByKey("little_game_text_008",self.m_model.level_id))
	self:setTextByLanKey("tips_open_text", "little_game_text_011")
	self:refreshUI()
end

function M:refreshUI()
	local level_name = "UI.LittleGames.HelpDog.HelpDogStageLevel.HelpDag_game_"..self.m_model.stage_id.."_"..self.m_model.level_id
	self.m_attr_node = self:LoginNode(self.m_control,level_name)
	self:showResultPanel(false)
	self:setGuide()
end

--设置引导
function M:setGuide()
	self:setObjectVisible("hand_btn",self.m_model.m_guide == 1 and self.m_model.level_id == 1)
	if self.m_model.m_guide == 1 and self.m_model.level_id == 1 then
		self.m_control:setOnceTimer(1.8, function()
			self:setObjectVisible("hand_btn", false)
		end)
	end
	self:setObjectVisible("close_btn",self.m_model.m_guide ~= 1)
	self:setObjectVisible("comeBack_btn",self.m_model.m_guide ~= 1)
end

--删除关卡
function M:deleteLevel()
	if self.m_attr_node then
		self.m_attr_node:cleanPoint()
		self.m_attr_node:destroy()
		self.m_attr_node = nil
	end
end

function M:LoginNode(control, name)
	local levelNode = CustomRequire(name)
	return levelNode.new(control,{parent = self.m_content_panel})
end

--显示通关展示
function M:showResultPanel(isShow)
	self:setObjectVisible("result",isShow)
end

--播放狗头动画
function M:showFailAnim(dog_name)
	self.m_attr_node:setObjectVisible(dog_name.."_cry",true)
	self.m_control:setOnceTimer(1.0, function()
		self.m_attr_node:setObjectVisible(dog_name.."_cry",false)
		self.m_attr_node:setObjectVisible(dog_name.."_bao",true)
		self.m_control:setOnceTimer(1.0,function()
			self:deleteLevel()
			self:refreshUI()
		end)
	end)
end

--显示guide位置
function M:showGuideBtn()
	self:setObjectVisible("guide_btn_1", true)
end

function M:destroy()
	self:deleteLevel()
	M.super.destroy(self)
end

return M