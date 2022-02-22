local function getStartTime()
	local gametime = GameTime:getInstance();
	local month = gametime:getMonth();
	if month>=2 and month<=4 then
		return getSandboxOptions():getOptionByName("NightXP.startSpring"):getValue();
	elseif month>=5 and month<=7 then
		return getSandboxOptions():getOptionByName("NightXP.startSummer"):getValue();
	elseif month>=8 and month<=10 then
		return getSandboxOptions():getOptionByName("NightXP.startAutumn"):getValue();
	end
	return getSandboxOptions():getOptionByName("NightXP.startWinter"):getValue();
end

local function getEndTime()
	local gametime = GameTime:getInstance();
	local month = gametime:getMonth();
	if month>=2 and month<=4 then
		return getSandboxOptions():getOptionByName("NightXP.endSpring"):getValue();
	elseif month>=5 and month<=7 then
		return getSandboxOptions():getOptionByName("NightXP.endSummer"):getValue();
	elseif month>=8 and month<=10 then
		return getSandboxOptions():getOptionByName("NightXP.endAutumn"):getValue();
	end
	return getSandboxOptions():getOptionByName("NightXP.endWinter"):getValue();
end

xpUpdate.onWeaponHitXp = function(owner, weapon, hitObject, damage)
    local isShove = false
    if hitObject:isOnFloor() == false and weapon:getType() == "BareHands" then
        isShove = true
    end
	local exp = 1 * damage * 0.9;
	local bonus_multiplier = getSandboxOptions():getOptionByName("NightXP.multiplier"):getValue();
	local hour = getGameTime():getTimeOfDay();
	local mult = 1;
	if hour >= getStartTime() and hour <= getEndTime() then
			mult = bonus_multiplier;
		else
			mult = 0.8;
		end
	end
	if exp > 3 then
		exp = 3;
	end
	-- add info of favourite weapon
	local modData = owner:getModData();
    if isShove == false then
        if modData["Fav:"..weapon:getName()] == nil then
            modData["Fav:"..weapon:getName()] = 1;
        else
            modData["Fav:"..weapon:getName()] = modData["Fav:"..weapon:getName()] + 1;
        end
    end
	-- if you sucessful swing your non ranged weapon
	if owner:getStats():getEndurance() > owner:getStats():getEndurancewarn() and not weapon:isRanged() then
		owner:getXp():AddXP(Perks.Fitness, 1);
	end
	-- we add xp depending on how many target you hit
	if not weapon:isRanged() and owner:getLastHitCount() > 0 then
		owner:getXp():AddXP(Perks.Strength, owner:getLastHitCount());
	end
	-- add xp for ranged weapon
	if weapon:isRanged() then
		local xp = owner:getLastHitCount();
		if owner:getPerkLevel(Perks.Aiming) < 5 then
			xp = xp * 2;
		end
		owner:getXp():AddXP(Perks.Aiming, xp);
	end
	-- add either blunt or blade xp (blade xp's perk name is Axe)
	if owner:getLastHitCount() > 0 and not weapon:isRanged() then
		if weapon:getScriptItem():getCategories():contains("Axe") then
			owner:getXp():AddXP(Perks.Axe, exp * mult);
		end
		if weapon:getScriptItem():getCategories():contains("Blunt") then
			owner:getXp():AddXP(Perks.Blunt, exp * mult);
		end
		if weapon:getScriptItem():getCategories():contains("Spear") then
			owner:getXp():AddXP(Perks.Spear, exp * mult);
		end
		if weapon:getScriptItem():getCategories():contains("LongBlade") then
			owner:getXp():AddXP(Perks.LongBlade, exp * mult);
		end
		if weapon:getScriptItem():getCategories():contains("SmallBlade") then
			owner:getXp():AddXP(Perks.SmallBlade, exp * mult * 2);
		end
		if weapon:getScriptItem():getCategories():contains("SmallBlunt") then
			owner:getXp():AddXP(Perks.SmallBlunt, exp * mult);
		end
	end
end