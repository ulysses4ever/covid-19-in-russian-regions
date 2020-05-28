#
# This file defines two functions `latest` and `total`
# generating the last two rows for the Wikipedia  table
# 
#   https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases
#
# Latest is supposed to be today's update on numbers, but can be set to 
# whatever date (c.f. `n` constant below), provided we have data for 
# it (c.f. section Inputs below). Same with `total`: this is the total 
# numbers by the the date `n`, provided we have the data.
#
# For convenience, `main` prints results of both, `latest` and `total`
#

using Dates
using DataFrames
using CSV
using JSON

include("$(@__DIR__)/templates.jl")

### Constants

# Tha date of interest
n=now() # - Day(1)

### Dull constants (e.g. paths)

make_tag(d :: DateTime) = Dates.format(d, "mmdd")
tag = make_tag(n)
DATA_DIR = "$(@__DIR__)/../data/"
METADATA_DIR = DATA_DIR * "/meta/"

#
###########################################################
#
### Inputs
#
#
# Note: we have 3 inputs described below
#

# Cumulative numbers by region come from Minzdrav website (JSON)
# https://covid19.rosminzdrav.ru/wp-json/api/mapdata/
INPUT_TOTAL = DATA_DIR * "covid$(tag).json"

# SAme as above but for the previous day: to compute new cases for today ("latests")
INPUT_TOTAL_PREV = DATA_DIR * "covid$(make_tag(n - Day(1))).json"

# Daily data updated manually. Currently just URL IDs of Rospotrednadzor website
include(DATA_DIR * "daily.jl")

#
###########################################################
#
### Aux
#

# Put a comma after every 3 digits, starting from right, and excluding
# possible leading position
commify(n :: Int) = commify("$n")
function commify(s :: String)
    n = length(s)
    @assert(all(isdigit, s))
    comma_count = div(n - 1, 3) # 3 is magic: 
                                # we like to put things after every 3 digits!
    res = ""
    s = reverse(s)
    for i in 1:comma_count
        res *= s[3*i-2 : 3*i] * ","
    end
    reverse(res * s[comma_count*3+1 : end])
end

# Extracts value by key `k` out of dictionary `d` and commyfies it.
# Default value "" (empty string) is used when key is not found or value is 0.
function my_get(d, k)
    v=get(d, k, "")
    v == 0 ? "" : commify(v)
end

f=Dates.format

#
# Generate references to Rospotrebnadzor website
#
function ref(name :: String, url :: String, title :: String, 
        work :: String = "[[Rospotrebnadzor]] ")
    today = f(n, "d U Y")
    "<ref$(name)>{{cite news |title=$(title) |url=$(url) |accessdate=$(today) |work=$(work)|date=$(today)}}</ref>"
end

function refs(url_id1 :: Int, url_id2 :: Int)
    rospotreb_url_base="https://rospotrebnadzor.ru/about/info/news/news_details.php?ELEMENT_ID="
    url1 = "$(rospotreb_url_base)$(url_id1)"
    url2 = "$(rospotreb_url_base)$(url_id2)"

    t1 = "О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России"
    t2 = "Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом"

    name1 = " name=\"rus$(lowercase(f(n, "Ud")))\""
    name2 = ""

    ref(name1, url1, t1) * ref(name2, url2, t2)
    #"<ref name=\"Rus_Ministry\" />" 
end

#
# Get the total number of tests performed from Minzdrav's dataset
#
# Input: Vector od Dict's with `LocationName`, `Confirmed`, etc...
# See Minzdrav's JSON for full description
function get_tests(v :: Vector)
    id = findfirst(d ->
        d["LocationName"] ==   "No region speified", v)
    # weird but that's the key ^ Minzdrav stores the number of test under

    commify(v[id]["Observations"])
end

#
# Get the total number of the main `Params` (cases/recovered/deaths)
#
# Input: Vector od Dict's with `LocationName`, `Confirmed`, etc...
# See Minzdrav's JSON for full description
function get_total(v :: Vector)::Params
    c=0; r=0; d=0
    for x in v
        if x["LocationName"] == "No region speified"
            continue
        end
        c += x["Confirmed"]; r += x["Recovered"]; d += x["Deaths"]
    end
    Params(commify(c), commify(r), commify(d))
end

#
# Load input data, initialize input structures
#
function init()
    # Load dictionary of region names
    rdft = CSV.File(METADATA_DIR * "regions-map-minzdrav.csv") |> DataFrame
    rt = Dict(zip(
        map(strip, rdft[!,:RegionEn]), 
        map(strip, rdft[!,:RegionRu])))

    # Region totals for today:
    dft = JSON.parsefile(INPUT_TOTAL)["Items"]
    dtotal = Dict([r["LocationName"] => r["Confirmed"] for r in dft])

    # Region totals for the previous day
    dftp = JSON.parsefile(INPUT_TOTAL_PREV)["Items"]
    dtotal_prev = Dict([r["LocationName"] => r["Confirmed"] for r in dftp])

    # New ("latest") cases are: today_total - yesterday_total
    dlatest = merge(-, dtotal, dtotal_prev)

    # All-Russia totals (as opposed to region-wise totals stored in `dtotal`)
    cum=data[tag]
    cum.total_tests = get_tests(dft)
    cum.total = get_total(dft)
    cum.new = cum.total - get_total(dftp)

    (Inputs(dlatest, rt), Inputs(dtotal, rt), cum)
end

#
###########################################################
#
### Main
#

latest_inp, total_inp, cum = init()

latest(i :: Inputs, cum :: DailyData) =
    latest_template(i.data, i.region_names, cum)

total(i :: Inputs, cum :: DailyData) =
    total_template(i.data, i.region_names, cum)

function main()
    print(latest(latest_inp, cum))
    print(total(total_inp, cum))
end
