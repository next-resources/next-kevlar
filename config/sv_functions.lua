-- Implement your own Anticheat logic here.
function PunishPlayer(source, reason)
    local name = GetPlayerName(source) or 'Unknown'
    print(('^3[next-kevlar] ^1[punishment]^0 Player ^2%d ^0(^6%s^0) should be punished for: ^4%s^0'):format(source, name, reason))
end