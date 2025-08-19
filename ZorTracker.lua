-- === ZorTracker ===
local playerClass = UnitClass('player')
local target = UnitName("target")
spellTimers = spellTimers or {}

ZorTrackerBars = ZorTrackerBars or {}
local bars = ZorTrackerBars

-- === Event Registration === --
function ZorTracker_OnLoad()
	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
end
-- === Event Handler === --
function ZorTracker_OnEvent(event, arg1)
    local now = GetTime()

    if event == "PLAYER_TARGET_CHANGED" then
        if playerClass == "Druid" then
			-- Cat
			ResetSpellTimer("Rake")
			ResetSpellTimer("Rip")
			-- Owl
			ResetSpellTimer("Moonfire")
			ResetSpellTimer("Insect Swarm")
		end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if playerClass == "Druid" then
			-- Cat
			ResetSpellTimer("Rake")
			ResetSpellTimer("Rip")
			-- Owl
			ResetSpellTimer("Moonfire")
			ResetSpellTimer("Insect Swarm")
        end
    elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_COMBAT_SELF_MISSES" )and arg1 then
        if playerClass == "Druid" then
			-- Cat
            if string.find(arg1, "Your Rake") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Rake", 9999)
					print(target .. " is immune to bleeds!")
				elseif string.find(arg1, "missed") or string.find(arg1, "dodged") or string.find(arg1, "parried") then
					ResetSpellTimer("Rake")
				elseif string.find(arg1, "hits") or string.find(arg1, "crits") then
					SetSpellTimer("Rake", 9)
				end
			elseif string.find(arg1, "Your Rip") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Rip", 9999)
					print(target .. " is immune to bleeds!")
				elseif string.find(arg1, "missed") or string.find(arg1, "dodged") or string.find(arg1, "parried") then
					ResetSpellTimer("Rip")
				end
			elseif string.find(arg1, "Your Faerie Fire") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Faerie Fire", 9999)
					print(target .. " is immune to spells!")
				end
            elseif string.find(arg1, "Your Pounce") then
				if string.find(arg1, "hits") or string.find(arg1, "crits") then
					SetSpellTimer("Pounce", 18)
				end
            elseif string.find(arg1, "Your Ferocious Bite") then
				if string.find(arg1, "hits") or string.find(arg1, "crits") then
					if GetTimeLeft("Rake") > 0 then
						SetSpellTimer("Rake", 9)
					end
					if GetTimeLeft("Rip") > 0 then
						SetSpellTimer("Rip", 18)
					end
				end
			-- Owl
			elseif string.find(arg1, "Your Moonfire") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Moonfire", 9999)
					print(target .. " is immune to arcane!")
				elseif string.find(arg1, "resisted") or string.find(arg1, "missed")then
					ResetSpellTimer("Moonfire")
				elseif string.find(arg1, "hits") or string.find(arg1, "crits") then
					SetSpellTimer("Moonfire", 18)
				end
			elseif string.find(arg1, "Your Insect Swarm") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Insect Swarm", 9999)
					print(target .. " is immune to nature!")
				elseif string.find(arg1, "resisted") or string.find(arg1, "missed")then
					ResetSpellTimer("Insect Swarm")
				end
			elseif string.find(arg1, "Your Starfire") then
				if string.find(arg1, "immune") and not string.find(arg1, "Stun") then -- Immune
					SetSpellTimer("Starfire", 9999)
					print(target .. " is immune to arcane!")
				end
			elseif string.find(arg1, "Your Wrath") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Wrath", 9999)
					print(target .. " is immune to nature!")
				end
			end
		end
	elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" and arg1 then
		if playerClass == "Druid" then
			-- Cat
			if string.find(arg1, "your Rake") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Rake", 9999)
					print(target .. " is immune to bleeds!")
				end
			elseif string.find(arg1, "your Rip") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Rip", 9999)
					print(target .. " is immune to bleeds!")
				elseif string.find(arg1, "suffers") then
					if GetTimeLeft("Rip") <= 0 then
						SetSpellTimer("Rip", 16)
					end
				end
			-- Owl
			elseif string.find(arg1, "your Moonfire") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Moonfire", 9999)
					print(target .. " is immune to arcane!")
				end
			elseif string.find(arg1, "your Insect Swarm") then
				if string.find(arg1, "immune") then -- Immune
					SetSpellTimer("Insect Swarm", 9999)
					print(target .. " is immune to nature!")
				elseif string.find(arg1, "suffers") then
					if GetTimeLeft("Insect Swarm") <= 0 then
						SetSpellTimer("Insect Swarm", 16.2)
					end
				end
			end
		end
	end
end

-- === Utilities === --
function SetSpellTimer(spellName, duration)
    local current = spellTimers[spellName]
    if current and current.duration > 1000 and duration <= 1000 then
        return -- immune
    end
    spellTimers[spellName] = {
        appliedAt = GetTime(),
        duration = duration
    }
end
function GetTimeLeft(spellName)
    local timer = spellTimers[spellName]
    if not timer then
        return 0
    end

    local elapsed = GetTime() - timer.appliedAt
    local remaining = timer.duration - elapsed
    if remaining <= 0 then
        spellTimers[spellName] = nil
        return 0
    end
    return remaining
end
function ResetSpellTimer(spellName)
    spellTimers[spellName] = nil
end

-- ========================================== Tracker ==========================================
-- ======= Movable Anchor Frame =======
local anchor = CreateFrame("Frame", "ZorTrackerAnchor", UIParent)
anchor:SetWidth(10)
anchor:SetHeight(10)
anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
anchor:EnableMouse(true)
anchor:SetMovable(true)
anchor:RegisterForDrag("LeftButton")

-- Drag scripts
anchor:SetScript("OnDragStart", function() anchor:StartMoving() end)
anchor:SetScript("OnDragStop", function() anchor:StopMovingOrSizing() end)

-- Optional: invisible background for testing
--local tex = anchor:CreateTexture(nil, "OVERLAY")
--tex:SetAllPoints(anchor)
--tex:SetTexture(1,0,0)

-- ======= Floating DoT Bars =======
local dots = {"Rake", "Rip", "Moonfire", "Insect Swarm", "Faerie Fire", "Pounce"}
local bars = bars or {}

for i, dot in ipairs(dots) do
    if not bars[dot] then
        local bar = CreateFrame("StatusBar", nil, anchor)
        bar:SetWidth(180)
        bar:SetHeight(15)
        bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(0)

        -- Background
        bar.bg = bar:CreateTexture(nil, "BACKGROUND")
        bar.bg:SetAllPoints(bar)
        bar.bg:SetTexture(0.2,0.2,0.2)
        bar.bg:SetAlpha(0.8)

        -- Text
        bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        bar.text:SetPoint("CENTER", bar, "CENTER")
        bar.text:SetText(dot)

        bar:Hide()
        bars[dot] = bar
    end
end


-- Update function
local function UpdateBars()
    local yOffset = 0
    local spacing = 18

    for _, dot in ipairs(dots) do
        local bar = bars[dot]
        local timeLeft = GetTimeLeft(dot)
        if timeLeft > 0 then
            local duration = spellTimers[dot] and spellTimers[dot].duration or 1
            bar:SetMinMaxValues(0, duration)
            bar:SetValue(timeLeft)

            -- Color and text
            if duration >= 1000 then
                bar:SetStatusBarColor(1,0,0)  -- immune = red
                bar.text:SetText(dot .. " (Immune)")
            else
                bar:SetStatusBarColor(0,1,0)  -- active = green
                bar.text:SetText(dot .. " " .. math.floor(timeLeft))
            end

            -- Stack bars downward from anchor
            bar:SetPoint("TOP", anchor, "TOP", 0, yOffset)
            yOffset = yOffset - spacing
            bar:Show()
        else
            bar:Hide()
        end
    end
end

-- OnUpdate
local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self, elapsed)
    UpdateBars()
end)
