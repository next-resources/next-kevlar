Config = {}

-- For performance reasons on bigger servers, we'd recommend you set this to false.
-- If you are a smaller server that doesn't mind some extra server events being triggered, you can opt to enable this.
-- With it disabled, plate health won't sync, only if the plate breaks.
Config.SyncPlatesEveryHit = true 

Config.PlateCarriers = {
    ['platecarrier'] = { -- Item name (Should be the same as in the ox config!)
        plateType = 'heavy', -- 'heavy' or 'light'. Heavy plate carriers support up to 100 armor (full bar), and light plate carriers support up to 50 armor (half bar).
        clothing = {
            ['male'] = {
                drawableCategory = 9, -- The clothing category the vest has.
                drawable = 76, -- The ped component variation that the player should wear when having this vest equipped. 
                texture = 10 -- The drawable texture that should be equipped.
            },
            ['female'] = {
                drawableCategory = 9,
                drawable = 76,
                texture = 10
            }
        }
    },
}

Config.Plates = {
    {
        name = 'plate_heavy', -- Item name (Should be the same as in the ox config!)
        plateType = 'heavy',
        armor = 50,
    },
    {
        name = 'plate_light',
        plateType = 'heavy',
        armor = 25,
    },
}