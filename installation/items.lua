-- Do NOT replace your items.lua file with this one.
-- Instead, copy the contents of this file and paste it into your own items.lua file.
Items = {

-- Copy from HERE
['heavypc'] = {
    label = 'Heavy Plate Carrier',
    description = 'Modular vest with 2 plate slots.',
    weight = 1500,
    stack = false,
    consume = 0,
    client = {
        export = 'next-kevlar.useVest'
    }
},

['lightpc'] = {
    label = 'Light Plate Carrier',
    description = 'Modular vest with a plate slot.',
    weight = 1000,
    stack = false,
    consume = 0,
    client = {
        export = 'next-kevlar.useVest'
    }
},

['lightplate'] = {
    label = 'Light Plate',
    weight = 250,
    stack = false,
    description = 'A light plate, made of Polyethylene'
},

['heavyplate'] = {
    label = 'Heavy Plate',
    weight = 500,
    stack = false,
    description = 'A heavy plate, made of Ceramics'
},

['brokenplate'] = {
    label = 'Broken Plate',
    weight = 500,
    stack = false,
    description = 'This plate has shattered!'
},
-- To HERE

}