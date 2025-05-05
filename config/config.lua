Config = {}

-- For performance reasons on bigger servers, we'd recommend you set this to false.
-- If you are a smaller server that doesn't mind some extra server events being triggered, you can opt to enable this.
-- With it disabled, plate health won't sync, only if the plate breaks.
Config.SyncPlatesEveryHit = true 

Config.PlateCarriers = {
    ['heavypc'] = { -- Item name (Should be the same as in the ox config!)
        plateType = 'heavy', -- 'heavy' or 'light'. Heavy plate carriers support 2 plates, and light plate carriers support 1 plate.
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
    ['lightpc'] = {
        plateType = 'light',
        clothing = {
            ['male'] = {
                drawableCategory = 9,
                drawable = 75,
                texture = 0
            },
            ['female'] = {
                drawableCategory = 9,
                drawable = 75,
                texture = 0
            }
        }
    },
}

Config.Plates = {
    ['heavyplate'] = { -- Item name (Should be the same as in the ox config!)
        plateType = 'heavy', -- 'heavy' or 'light'. Heavy plate carriers support 2 plates, and light plate carriers support 1 plate.
        armor = 50, -- Amount of armor to give when the plate is undamaged. Setting this value above 50 has no effect (since you can't exceed 100 armor)
    },
    ['lightplate'] = {
        plateType = 'light',
        armor = 25,
    },
}