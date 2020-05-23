###########################################################
#
# We use Rospotrebnadzor website links to provide references to 
# "Authorative Sources". While we use Minzdrav website to get the actual data
# in nice machine-readable form (JSON), it is no good for referencing:
# Minzdrav overwrites the data daily. In contrast, Rospotrebnadzor
# preserves daily updates from the past.
#
# Note [Rospotrebnadzor URLs]: Here we store only _IDs_ of
# Rospotrebnadzor web pages. Resulting Urls are of the form (note <Our ID>):
#
# > https://rospotrebnadzor.ru/about/info/news/news_details.php?ELEMENT_ID=<Our ID>
#

SRC_DIR = "$(@__DIR__)/../src/"
include(SRC_DIR * "structs.jl")

data = Dict(

    "0518" => DailyData(
        rsp=RospotrebUrlIds(14482, 14479), # Cf. Note [Rospotrebnadzor URLs]
    ),

    "0519" => DailyData(
        rsp=RospotrebUrlIds(14487, 14485),
    ),

    "0520" => DailyData(
        rsp=RospotrebUrlIds(14498, 14493),
    ),

    "0521" => DailyData(
        rsp=RospotrebUrlIds(14509, 14506),
    ),

    "0522" => DailyData(
        rsp=RospotrebUrlIds(14519, 14517),
    ),

    "0523" => DailyData(
        rsp=RospotrebUrlIds(14526, 14525),
    ),

)
