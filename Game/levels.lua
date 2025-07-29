-- NUMBERS ARE AS PERCENTAGES OF SCREEN SIZE
return {
    {
        -- Golf ball and goal locations
        {x = 0.3, y = 0.33},
        {x = 0.3, y = 0.67},

        -- Top and bottom
        {x = 0.5, y = 0, width = 1, height = 0.4},
        {x = 0.5, y = 1, width = 1, height = 0.4},

        -- Left and right
        {x = 0, y = 0.5, width = 0.4, height = 1},
        {x = 1, y = 0.5, width = 0.4, height = 1},

        -- Middle obstacle
        {x = 0.35, y = 0.5, width = 0.5, height = 0.1}
    },
    {
        -- Golf ball and goal locations
        {x = 0.5, y = 0.85},
        {x = 0.5, y = 0.5},

        -- Top and bottoms
        {x = 0.5, y = 0, width = 1, height = 0.35},
        {x = 0.5, y = 1, width = 1, height = 0.05},
        {x = 0.25, y = 1, width = 0.35, height = 0.4},
        {x = 0.75, y = 1, width = 0.35, height = 0.4},

        -- Left and right
        {x = 0, y = 0.5, width = 0.35, height = 1},
        {x = 1, y = 0.5, width = 0.35, height = 1},

        -- Middle enclosure
        {x = 0.5, y = 0.6, width = 0.4, height = 0.05},
        {x = 0.35, y = 0.45, width = 0.1, height = 0.25},
        {x = 0.65, y = 0.45, width = 0.1, height = 0.25},
    },
    {
        -- Golf ball and goal locations
        {x = 0.22, y = 0.70},
        {x = 0.83, y = 0.3},

        -- Top and bottom
        {x = 0.5, y = 0, width = 1, height = 0.35},
        {x = 0.5, y = 1, width = 1, height = 0.35},

        -- Left and right
        {x = 0, y = 0.5, width = 0.3, height = 1},
        {x = 1, y = 0.5, width = 0.25, height = 1},

        -- Bottom Middle obstacles
        {x = 0.4, y = 0.7, width = 0.075, height = 0.25},
        {x = 0.55, y = 0.7, width = 0.075, height = 0.25},
        {x = 0.7, y = 0.7, width = 0.075, height = 0.25},
        {x = 0.85, y = 0.7, width = 0.075, height = 0.25},
        {x = 0.9, y = 0.7, width = 0.075, height = 0.25},

        -- Top Middle obstacles
        {x = 0.2, y = 0.3, width = 0.125, height = 0.25},
        {x = 0.3, y = 0.3, width = 0.075, height = 0.25},
        {x = 0.45, y = 0.3, width = 0.075, height = 0.25},
        {x = 0.6, y = 0.3, width = 0.075, height = 0.25},
        {x = 0.75, y = 0.3, width = 0.075, height = 0.25},
    }
}