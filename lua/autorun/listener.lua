local enabled = CreateConVar("ttt_detective_suicide_listener_enable", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE}, 0, 1)

if !enabled:GetBool() then return end

-- object literals implementation
local death = {
    suicide = function(victim, inflictor, attacker) 
        if attacker != victim 
        and !attacker:IsWorld() then return false end

        return victim:Nick() .. " has suicided. "
    end,
    ["causes"] = {
        fall = function(victim, inflictor, attacker)
            if !attacker:IsWorld() 
            and !inflictor:IsWorld() then return false end

            return "They jumped to their death."
        end,
        console = function(victim, inflictor, attacker)
            if inflictor != victim 
            and inflictor != attacker then return false end 

            return "They used kill on console."
        end
    }
}

-- returns a single entry from provided table (which has to contain functions to check a specific death cause)
local function GetCause(victim, inflictor, attacker, cause_table)
    local cause = ""

    for _, item in ipairs(cause_table) do 
        print(item)
        local result = item(victim, inflictor, attacker)
        if !result then continue end

        cause = result

        break
    end 

    if cause == "" then 
        cause = "Their death was very weird. No apparent cause." 
    end

    return cause
end

hook.Add("PlayerDeath", "TTTDetectiveSuicideListener", function(victim, inflictor, attacker) 

    if !victim:IsRole(ROLE_DETECTIVE) then return end

    local suicide = death.suicide(victim, inflictor, attacker) or false

    if !suicide then return end

    print(inflictor)
    print(victim)
    print(attacker)

    local fall = death["causes"].fall(victim, inflictor, attacker) or ""

    local console = death["causes"].console(victim, inflictor, attacker) or ""

    print("This is the cause of death:")

    local death_cause_string = suicide .. GetCause(victim, inflictor, attacker, death["causes"])
    
    print(death_cause_string)

end)