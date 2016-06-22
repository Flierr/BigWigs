------------------------------
--      Are you local?      --
------------------------------

local veklor = AceLibrary("Babble-Boss-2.2")["Emperor Vek'lor"]
local veknilash = AceLibrary("Babble-Boss-2.2")["Emperor Vek'nilash"]
local boss = AceLibrary("Babble-Boss-2.2")["The Twin Emperors"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. boss)

local started = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Twins",

	bug_cmd = "bug",
	bug_name = "Exploding Bug Alert",
	bug_desc = "Warn for exploding bugs",

	teleport_cmd = "teleport",
	teleport_name = "Teleport Alert",
	teleport_desc = "Warn for Teleport",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for Twins Healing",

	porttrigger = "casts Twin Teleport.",
	portwarn = "Teleport!",
	portdelaywarn = "Teleport in 5 seconds!",
	portdelaywarn10 = "Teleport in 10 seconds!",
	bartext = "Teleport",
	explodebugtrigger = "gains Explode Bug",
	explodebugwarn = "Bug exploding nearby!",
	enragetrigger = "becomes enraged.",
	trigger = "Blizzard",
	enragewarn = "Twins are enraged",
	healtrigger1 = "'s Heal Brother heals",
	healtrigger2 = " Heal Brother heals",
	healwarn = "Casting Heal!",
	startwarn = "Twin Emperors engaged! Enrage in 15 minutes!",
	enragebartext = "Enrage",
	warn1 = "Enrage in 10 minutes",
	warn2 = "Enrage in 5 minutes",
	warn3 = "Enrage in 3 minutes",
	warn4 = "Enrage in 90 seconds",
	warn5 = "Enrage in 60 seconds",
	warn6 = "Enrage in 30 seconds",
	warn7 = "Enrage in 10 seconds",
	firewarn = "Run from Blizzard!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsTwins = BigWigs:NewModule(boss)
BigWigsTwins.zonename = AceLibrary("Babble-Zone-2.2")["Ahn'Qiraj"]
BigWigsTwins.enabletrigger = {veklor, veknilash}
BigWigsTwins.toggleoptions = {"bug", "teleport", "enrage", "heal", "bosskill"}
BigWigsTwins.revision = tonumber(string.sub("$Revision: 16970 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsTwins:OnEnable()
	started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "TwinsTeleport", 10)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsTwins:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, veklor) or msg == string.format(UNITDIESOTHER, veknilash) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.2"):new("BigWigs")["%s have been defeated"], boss), "Bosskill", nil, "Victory") end
                BigWigs:Flawless()
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsTwins:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(msg)
	if string.find(msg, L["trigger"]) then
		self:CancelScheduledEvent("bwtwinsfire")
		self:ScheduleEvent("bwtwinsfire", self.Stopb, 10, self )
		self:TriggerEvent("BigWigs_Message", L["firewarn"], "Personal", true, "Alarm")
	        BigWigsThaddiusArrows:Direction("Blizzard")
	end
end

function BigWigsTwins:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["trigger"]) then
            BigWigsThaddiusArrows:Blizzardstop()
	end
end

function BigWigsTwins:Stopb()
            BigWigsThaddiusArrows:Blizzardstop()
end

function BigWigsTwins:BigWigs_RecvSync(sync, rest, nick)
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if self.db.profile.teleport then
	                self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Noth") end, 25)
			self:ScheduleEvent("BigWigs_Message", 20, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 25, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			--Bars and warnings for 10 mins, because VG has no teleport in combatlog - needs testing
			self:ScheduleEvent("BigWigs_Message", 50, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 55, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 60, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 80, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 85, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 90, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 110, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 115, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 120, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 140, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 145, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 150, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 170, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 175, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 180, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 200, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 205, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 210, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 230, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 235, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 240, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 260, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 265, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 270, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 290, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 295, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 300, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 320, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 325, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 330, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 350, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 355, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 360, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 380, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 385, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 390, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 410, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 415, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 420, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 440, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 445, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 450, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 470, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 475, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 480, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 500, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 505, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 510, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 530, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 535, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 540, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 560, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 565, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 570, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 590, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 595, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 600, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 620, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 625, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 630, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 650, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 655, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 660, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 680, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 685, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 690, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
			
			self:ScheduleEvent("BigWigs_Message", 710, L["portdelaywarn10"], "Urgent")
			self:ScheduleEvent("BigWigs_Message", 715, L["portdelaywarn"], "Urgent")
			self:TriggerEvent("BigWigs_StartBar", 720, self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")

	end
		if self.db.profile.enrage then
	                self:ScheduleRepeatingEvent("bwtwinstelebar", self.Telebar, 30.1, self)
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Important")
			self:TriggerEvent("BigWigs_StartBar", self, L["enragebartext"], 900, "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
			self:ScheduleEvent("bwtwinswarn1", "BigWigs_Message", 300, L["warn1"], "Attention")
			self:ScheduleEvent("bwtwinswarn2", "BigWigs_Message", 600, L["warn2"], "Attention")
			self:ScheduleEvent("bwtwinswarn3", "BigWigs_Message", 720, L["warn3"], "Attention")
			self:ScheduleEvent("bwtwinswarn4", "BigWigs_Message", 810, L["warn4"], "Urgent")
			self:ScheduleEvent("bwtwinswarn5", "BigWigs_Message", 840, L["warn5"], "Urgent")
			self:ScheduleEvent("bwtwinswarn6", "BigWigs_Message", 870, L["warn6"], "Important")
			self:ScheduleEvent("bwtwinswarn7", "BigWigs_Message", 890, L["warn7"], "Important")
		end
	elseif sync == "TwinsTeleport" and self.db.profile.teleport then
		self:TriggerEvent("BigWigs_Message", L["portwarn"], "Attention")
		self:ScheduleEvent("BigWigs_Message", 20, L["portdelaywarn10"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 25, L["portdelaywarn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 30, "Interface\\Icons\\Spell_Arcane_Blink")
		
	end
end

function BigWigsTwins:Telebar()
                klhtm:ResetRaidThreat()
	        self:ScheduleEvent(function() BigWigsThaddiusArrows:Direction("Noth") end, 25)
		self:ScheduleEvent("BigWigs_Message", 20, L["portdelaywarn10"], "Urgent")
		self:ScheduleEvent("BigWigs_Message", 25, L["portdelaywarn"], "Urgent")
		self:TriggerEvent("BigWigs_StartBar", self, L["bartext"], 30.1, "Interface\\Icons\\Spell_Arcane_Blink")
end	

--not working on VG
function BigWigsTwins:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if (string.find(msg, L["porttrigger"])) then
		self:TriggerEvent("BigWigs_SendSync", "TwinsTeleport")
	end
end

function BigWigsTwins:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if (string.find(msg, L["explodebugtrigger"]) and self.db.profile.bug) then
		self:TriggerEvent("BigWigs_Message", L["explodebugwarn"], "Personal", true)
	end
end

function BigWigsTwins:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF(msg)
	if (not self.prior and (string.find(msg, L["healtrigger1"]) or string.find(msg, L["healtrigger2"])) and self.db.profile.heal) then
		self:TriggerEvent("BigWigs_Message", L["healwarn"], "Important")
		self.prior = true
		self:ScheduleEvent(function() BigWigsTwins.prior = nil end, 10)
	end
end

function BigWigsTwins:CHAT_MSG_MONSTER_EMOTE(msg)
	if (string.find(msg, L["enragetrigger"]) and self.db.profile.enrage) then
		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important")
	end
end

