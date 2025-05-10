-- Here is a simple example of a crafting recipe to replace broken plates.
-- If you use another crafting system than ox_inventory's one, you'll have to implement it yourself.

Example = {
	items = {
		{
			name = 'heavyplate',
			ingredients = {
				brokenplate = 2,
				carbide = 6,
				ceramics = 6
			},
			duration = 10000,
			count = 1,
		},
	},
	points = {
		vec3(1657.0558, 5.5811, 166.1179)
	},
	zones = {
		{
			coords = vec3(1657.0558, 5.5811, 166.1179),
			size = vec3(3.8, 1.05, 0.15),
			distance = 0.1,
			rotation = 315.0,
		},
	},
}