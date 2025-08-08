local screen_width, screen_height = 1000, 600

return {
    {
        goal = {
            x = screen_width * .5, y = screen_height * .5
        },

        balls = { -- Ball spawn areas (NUM_BALLS / 4)
            {x = screen_width * .15, y = screen_height * .15, radius = 50},
            {x = screen_width * .15, y = screen_height * .85, radius = 50},
            {x = screen_width * .85, y = screen_height * .15, radius = 50},
            {x = screen_width * .85, y = screen_height * .85, radius = 50},
        },

        obstacles = {
            {x = screen_width * .33, y = screen_height * .25, width = screen_width * .15, height = 10},
            {x = screen_width * .25, y = screen_height * .342, width = 10, height = screen_height * .2},

            {x = screen_width * .67, y = screen_height * .25, width = screen_width * .15, height = 10},
            {x = screen_width * .75, y = screen_height * .342, width = 10, height = screen_height * .2},

            {x = screen_width * .33, y = screen_height * .75, width = screen_width * .15, height = 10},
            {x = screen_width * .25, y = screen_height * .658, width = 10, height = screen_height * .2},

            {x = screen_width * .67, y = screen_height * .75, width = screen_width * .15, height = 10},
            {x = screen_width * .75, y = screen_height * .658, width = 10, height = screen_height * .2},

            {x = screen_width * .5, y = screen_height * .4, width = screen_width * .1, height = 10},
            {x = screen_width * .5, y = screen_height * .6, width = screen_width * .1, height = 10},
            {x = screen_width * .4, y = screen_height * .5, width = 10, height = screen_height * .1},
            {x = screen_width * .6, y = screen_height * .5, width = 10, height = screen_height * .1},
        }
    },
    {
        goal = {
            x = screen_width * .1, y = screen_height * .5
        },

        balls = {
            {x = screen_width * .15, y = screen_height * .15, radius = 50},
            {x = screen_width * .15, y = screen_height * .85, radius = 50},
            {x = screen_width * .85, y = screen_height * .15, radius = 50},
            {x = screen_width * .85, y = screen_height * .85, radius = 50},
        },

        obstacles = {
            {x = screen_width * .15, y = screen_height * .33, width = screen_width * .3, height = 10},
            {x = screen_width * .15, y = screen_height * .67, width = screen_width * .3, height = 10},

            {x = screen_width * .4, y = screen_height * .1, width = 10, height = screen_height * .2},
            {x = screen_width * .4, y = screen_height * .9, width = 10, height = screen_height * .2},

            {x = screen_width * .8, y = screen_height * .33, width = screen_width * .4, height = 10},
            {x = screen_width * .8, y = screen_height * .67, width = screen_width * .4, height = 10},

            {x = screen_width * .4, y = screen_height * .5, width = 10, height = screen_height * .25},
            {x = screen_width * .15, y = screen_height * .5, width = 10, height = screen_height * .1},
        }
    },
    {
        goal = {
            x = screen_width * 0.9, y = screen_height * 0.9
        },

        balls = {
            {x = screen_width * .05, y = screen_height * .1, radius = 10},
            {x = screen_width * .15, y = screen_height * .1, radius = 10},
            {x = screen_width * .8, y = screen_height * .1, radius = 25},
            {x = screen_width * .9, y = screen_height * .35, radius = 50},
        },

        obstacles = {
            {x = screen_width * .1, y = screen_height * .425, width = 10, height = screen_height * .85},
            {x = screen_width * .222, y = screen_height * .85, width = screen_width * .25, height = 10},
            {x = screen_width * .222, y = screen_height * .35, width = 10, height = screen_height * .7},
            {x = screen_width * .35, y = screen_height * .759, width = 10, height = screen_height * .2},
            {x = screen_width * .35, y = screen_height * .5, width = screen_width * .25, height = 10},

            {x = screen_width * .5, y = screen_height * .9, width = 10, height = screen_height * .2},

            {x = screen_width * .7, y = screen_height * .2, width = screen_width * .6, height = 10},
            {x = screen_width * .6, y = screen_height * .5, width = 10, height = screen_height * .6},

            {x = screen_width * .875, y = screen_height * .5, width = screen_width * .25, height = 10},
        }
    }
}