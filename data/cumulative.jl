###########################################################
#
# Aggregate numbers -- from:
# *  https://стопкоронавирус.рф/info/ofdoc/reports/
#     -- for all except total_tests
# * https://covid19.rosminzdrav.ru/
#     -- for total_tests
#
# Also, for the current day the "total" numbers can be taken from:
#
# > https://covid19.rosminzdrav.ru/
#
# (Scroll down, find the map)
#
# Note [Rospotrebnadzor URLs]: we need links to authorative sources.
# For that we use Rospotrebnadzor news. Here we store only IDs of
# their pages. Resulting Urls are of the form (note <Our ID>):
#
# > https://rospotrebnadzor.ru/about/info/news/news_details.php?ELEMENT_ID=<Our ID>
#

SRC_DIR = "$(@__DIR__)/../src/"
include(SRC_DIR * "structs.jl")

# Note [Total tests metric]
# as of 89abeff we don't need to put DailyData.total_tests in manually

data = Dict(

    "0518" => DailyData(
        new=Params(
            cases = "8,926",
            recovered = "2,836",
            deaths = "91",
        ),
        total=Params(
            cases = "290,678",
            recovered = "70,209",
            deaths = "2,722",
        ),
        rsp=RospotrebUrlIds(14482, 14479),
        total_tests="7,147,014"
    ),

    "0519" => DailyData(
        new=Params(
            cases = "9,263",
            recovered = "5,921",
            deaths = "115",
        ),
        total=Params(
            cases = "299,941",
            recovered = "76,130",
            deaths = "2,837",
        ),
        rsp=RospotrebUrlIds(14487, 14485),
        total_tests="7,352,316"
    ),

    "0520" => DailyData(
        new=Params(
            cases     = "8,764",
            recovered = "9,262",
            deaths    =   "135",
        ),
        total=Params(
            cases     = "308,705",
            recovered =  "85,392",
            deaths    =   "2,972",
        ),
        rsp=RospotrebUrlIds(14498, 14493),
        total_tests="7,578,029"
    ),

    "0521" => DailyData(
        new=Params(
            cases     = "8,849",
            recovered = "7,289",
            deaths    =   "127",
        ),
        total=Params(
            cases     = "317,554",
            recovered =  "92,681",
            deaths    =   "3,099",
        ),
        rsp=RospotrebUrlIds(14509, 14506),
        total_tests="" # c.f. Note [Total tests metric]
    ),

)
