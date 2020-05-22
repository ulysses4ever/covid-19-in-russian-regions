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
n=now()

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

# Latest numbers by region come from Rospotrebnadzor website in the form
# of CSV manually created from their webpage :-( 
# well, with a little help of `src/clean-rpn.sh`, which turns a
# manually created text file into a CSV.
# C.f. the News section of their website
INPUT_LATEST = DATA_DIR * "covid$(tag).csv"

# Cumulative numbers by region come from Minzdrav website (JSON)
# https://covid19.rosminzdrav.ru/wp-json/api/mapdata/
INPUT_TOTAL = DATA_DIR * "total-covid$(tag).json"
# Will need to fetch previous day totals to compute news
INPUT_TOTAL_PREV = DATA_DIR * "total-covid$(make_tag(n - Day(1))).json"

# Total cumulative numbers in Russia:
include(DATA_DIR * "cumulative.jl")

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

# Extracts value by key `k` out of dictionary `d` and commyfies it
# default value is "" (empty string)
my_get(d, k) = commify(get(d, k, ""))

f=Dates.format

#
# Generate references to Rospotrebnadzor website
#
function ref(name :: String, url :: String, title :: String)
    today = f(n, "d U Y")
    "<ref$(name)>{{cite news |title=$(title) |url=$(url) |accessdate=$(today) |work=[[Rospotrebnadzor]] |date=$(today)}}</ref>"
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
    # Region new cases for today:
    dfl = CSV.File(INPUT_LATEST) |> DataFrame
    dl = Dict(zip(map(strip, dfl[!,:Region]), dfl[!,:NewCases]))

    rdfl = CSV.File(METADATA_DIR * "regions-map-rospotrebnadzor.csv") |> DataFrame
    rl = Dict(zip(map(strip, rdfl[!,:RegionEn]), map(strip, rdfl[!,:RegionRu])))

    # Region totals for today:
    dft = JSON.parsefile(INPUT_TOTAL)["Items"]
    dt = Dict([r["LocationName"] => r["Confirmed"] for r in dft])

    rdft = CSV.File(METADATA_DIR * "regions-map-minzdrav.csv") |> DataFrame
    rt = Dict(zip(map(strip, rdft[!,:RegionEn]), map(strip, rdft[!,:RegionRu])))

    # Region totals for the previous day (need to compute total news)
    dftp = JSON.parsefile(INPUT_TOTAL_PREV)["Items"]
    
    # We will need this when implement computation of region-news
    #dtp = Dict([r["LocationName"] => r["Confirmed"] for r in dftp])

    # Russia totals (aka cumulatives)
    cum=data[tag]
    cum.total_tests = get_tests(dft)
    cum.total = get_total(dft)
    cum.new = cum.total - get_total(dftp)

    (Inputs(dl,rl), Inputs(dt,rt), cum)
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
    println(total(total_inp, cum))
end
