--- 逸闻
local M = class("HeroBiographyNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/HeroBiographyNode"

local SKILL_NAME_TAB = {"结局一", "结局二", "结局三"}
local SKILL_Color_TAB = {Color( 204/255, 239/255, 239/255), Color( 74/255, 237/255, 109/255),}

function M:onEnter()
	self.right_obj = self:findGameObject("right_obj")
	self.strengthen_btn = self:findGameObject("strengthen_btn")
	local eventTeamId = self.m_model.herocfg.map_event_team
	self.stage = ConfigManager:getCfgByName("stage")
	--local eventTeamTable = ConfigManager:getCfgByName("map_event_team")
	--self.eventTeamData = eventTeamTable[eventTeamId]
	--self.eventTable = ConfigManager:getCfgByName("map_event")
	
	self.skillImproveGroup = ConfigManager:getCfgByName("skill_improve_group")
	
	local icon = self:findImage("skill1Icon")
	self.grayMat = icon.material
    
	self:refreshUI()    
end

function M:refreshUI()
	self:setSpine()
	self:setHeroStory()
	--self:setSkillInfo()
end

function M:setHeroStory()
	self:setTextByLanKey("content_text",self.m_model:getHeroDesA())
	if self.eventTeamData ~= nil then
		self:setTextByLanKey("title_text",self.eventTeamData.team_name)
		--self:setTextByLanKey("content_text",self.eventTeamData.event_story)
	end
end

function M:setSkillInfo()
	if self.eventTeamData ~= nil then
		for k,v in ipairs(self.eventTeamData.ending_id) do
			self:setTextByLanKey("skill"..k.."_text",SKILL_NAME_TAB[k])
			self:setTextByLanKey("skill"..k.."_title_text", self.skillImproveGroup[self.eventTable[v].unlock_skill].name)
			
			self:setImg("a_ui_currency_jineng_linshi", "hero_ui", "skill"..k.."Icon")

			local skillImprove = UserDataManager.skillImprove_data.m_skillImprove[self.m_model.herocfg.id]
			local icon = self:findImage("skill"..k.."Icon")
			--未解锁
			if skillImprove == nil or table.indexof(skillImprove.groups, self.eventTable[v].unlock_skill) == false then
				if self.eventTeamData.stage > UserDataManager:getCurStage() then
					self:setObjectVisible("skill"..k.."_state1_text", true)
					self:setText("skill"..k.."_state1_text", Language:getTextByKey("new_str_0059", Language:getTextByKey(self.stage[self.eventTeamData.stage].map_point_name)))
				else
					self:setObjectVisible("skill"..k.."_state1_text", false)
				end
				self:setObjectVisible("skill"..k.."_state2_text", false)
				self:setTextColor("skill"..k.."_title_text", SKILL_Color_TAB[1])
				self:setObjectVisible("skill"..k.."Icon_select", false)
				self:setObjectVisible("skill"..k.."_select_text", false)
				self:setObjectVisible("skill"..k.."_lock_text", true)
				icon.material = self.grayMat
			else
				self:setObjectVisible("skill"..k.."_state1_text", false)
				self:setObjectVisible("skill"..k.."_state2_text", true)
				self:setObjectVisible("skill"..k.."_lock_text", false)
				icon.material = nil
				--选中
				if skillImprove.cur_id == self.eventTable[v].unlock_skill then
					self:setTextColor("skill"..k.."_title_text", SKILL_Color_TAB[2])
					self:setObjectVisible("skill"..k.."Icon_select", true)
					self:setObjectVisible("skill"..k.."_select_text", true)

					--未选中
				else
					self:setTextColor("skill"..k.."_title_text", SKILL_Color_TAB[1])
					self:setObjectVisible("skill"..k.."Icon_select", false)
					self:setObjectVisible("skill"..k.."_select_text", false)
				end

			end
		end
	end	
end

--[[
    @desc: 英雄动画
]]
function M:setSpine()
	self:setTextByLanKey("hero_name_text", self.m_model:getHero_Name())
	if self.m_model:getPoetry() then
		local poet = self.m_model:getPoetry()
		if poet and #poet >= 4 then
			self:setText("poet_text", poet[1]..poet[2])
			self:setText("poet_text2", poet[3]..poet[4])
		end
	end
	local icon = self.m_model:getHeroBigAnim()
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon
	end
	local pos_x = -8
	local pos_y = -8
	local play_img = self:findGameObject("hero_spine")
	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos =self.m_model:getSpinePos()
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

function M:skillOnClick(index)
	local skillGroupId = self.eventTable[self.eventTeamData.ending_id[index]].unlock_skill
	self:skillInfo(self.m_control, {heroId = self.m_model.herocfg.id, groupId = skillGroupId, click_transform = self:findRectTransform("skill"..index.."_btn")})
end

function M:skillInfo(control, params)
	local skillInfo = CustomRequire("UI.HeroInfo.SkillImproveInfo")
	skillInfo.new(control, params)
end

function M:enterSetSkillRedPoint()
end

return M