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

@info "Loading package dependencies..."
using Dates
using DataFrames
using CSV
using JSON
using HTTP
@info "... done"

include("$(@__DIR__)/structs.jl")
include("$(@__DIR__)/templates.jl")

### Constants

# Tha date of interest
n()=now() # - Day(1)

### Dull constants (e.g. paths)

make_tag(d :: DateTime) = Dates.format(d, "mmdd")

DATA_DIR = "$(@__DIR__)/../data/"
DATA_RPN_DIR = DATA_DIR * "/rpn-url-ids/"
DATA_MINZDRAV_DIR = DATA_DIR * "/minzdrav/"
METADATA_DIR = DATA_DIR * "/meta/"

# The key Minzdrav uses to store number of tests
TESTS_LABEL = "No region speified"

#
# We had to introduce the concept of mode because Minzdrav suddently stopped
# to publish the data in JSON on their website since June 6th.
# We switched to use the стопкоронавирус.рф data, which we store in CSV,
# for the time being.
# Plus we manually store the number of tests from Roskomnadzor site.
# We still use `data/minzdrav` dir for those data for convenience.
# See .csv and .tests.txt file respectively.
#

USE_MINZDRAV = 1
USE_STOPKORONA = 2

mode = USE_STOPKORONA

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
# We normally need data for today and yesterday (to compute new cases)
DATA_FILE(when :: DateTime, format :: String) =
    DATA_MINZDRAV_DIR * "$(make_tag(when)).$(format)"

# Daily data updated manually. Currently just URL IDs of Rospotrednadzor website
INPUT_RPN(when :: DateTime) = "$(DATA_RPN_DIR)/$(make_tag(when))"

# We use Rospotrebnadzor website links to provide references to 
# "Authorative Sources". While we use Minzdrav website to get the actual data
# in nice machine-readable form (JSON), it is no good for referencing:
# Minzdrav overwrites the data daily. In contrast, Rospotrebnadzor
# preserves daily updates from the past.
#
# Note [Rospotrebnadzor URLs]: In the INPUT_RPN dir we store only _IDs_ of
# Rospotrebnadzor web pages. Resulting Urls are of the form (note <Our ID>):
#
# > https://rospotrebnadzor.ru/about/info/news/news_details.php?ELEMENT_ID=<Our ID>
#

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
    today = f(n(), "d U Y")
    "<ref$(name)>{{cite news |title=$(title) |url=$(url) |accessdate=$(today) |work=$(work)|date=$(today)}}</ref>"
end

function refs(url_id1 :: Int, url_id2 :: Int)
    rospotreb_url_base="https://rospotrebnadzor.ru/about/info/news/news_details.php?ELEMENT_ID="
    url1 = "$(rospotreb_url_base)$(url_id1)"
    url2 = "$(rospotreb_url_base)$(url_id2)"

    t1 = "О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России"
    t2 = "Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом"

    name1 = " name=\"rus$(lowercase(f(n(), "Ud")))\""
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
        d["LocationName"] == TESTS_LABEL, v)

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
        if x["LocationName"] == TESTS_LABEL
            continue
        end
        c += x["Confirmed"]; r += x["Recovered"]; d += x["Deaths"]
    end
    Params(commify(c), commify(r), commify(d))
end

#
# load_* function return a pair of data:
# 1) data-all: a vector of dictionaries with at least the following keys:
#    LocationName, Confirmed, Recovered, Deaths;
# 2) data-cases: a dictionary from a location name tothe total number of cases
#    in that location.
#

data_format = ["json", "csv"]
tests_format = ["json", "tests.txt"]

all_to_cases(dft :: Vector{Dict{K,V}} where K where V) :: Dict =
    Dict([r["LocationName"] => r["Confirmed"] for r in dft])

function load_minzdrav(when :: DateTime)
    dft = JSON.parsefile(DATA_FILE(when, data_format[mode]))["Items"]
    dtotal = all_to_cases(dft)
    (dft, dtotal)
end

function load_stopkorona(when :: DateTime)
    csv = CSV.File(DATA_FILE(when, data_format[mode]))
    regmap_stopkor_to_canon =
        Dict(zip(r_stopkor[!,:RegionRu], r_stopkor[!,:RegionEn]))
    dft = [
        Dict(
                "LocationName" => rt[regmap_stopkor_to_canon[strip(row.LocationName)]],
                "Confirmed" => row.Confirmed,
                "Recovered" => row.Recovered,
                "Deaths" => row.Deaths
        )
        for row in csv
    ]

    dtotal = all_to_cases(dft)
    
    # Handle tests
    tests = open(f -> parse(Int,read(f, String)), DATA_FILE(when, tests_format[mode]))
    push!(dft,
          Dict(
              "LocationName" => TESTS_LABEL,
              "Observations" => tests
          )
    )

    (dft, dtotal)
end

load_data(mode :: Int, when :: DateTime = n()) =
    if mode == USE_MINZDRAV
        load_minzdrav(when)
    elseif mode == USE_STOPKORONA
        load_stopkorona(when)
    else
        error("Unknown mode")
    end

#
# Load input data, initialize input structures
#
function init(when :: DateTime)
    # Which mode we use to load inputs
    # TODO: Autodetect instead of hardcode

    # Region totals for today and yesterday:
    dft, dtotal = load_data(mode, when)
    dftp, dtotal_prev = load_data(mode, when - Day(1))

    # New ("latest") cases are: today_total - yesterday_total
    dlatest = merge(-, dtotal, dtotal_prev)

    # RPN URLs
    urls_str = open(f -> read(f, String), INPUT_RPN(when))
    urls = eval(Base.Meta.parse(urls_str))
    rpn_urls = RospotrebUrlIds(urls...)

    # Get number of tests and check if it's been updated
    tests = get_tests(dft)
    if tests == get_tests(dftp)
        error("The number of tests has not been renewed by Minzdrav yet")
    end
    
    # All-Russia totals (as opposed to region-wise totals stored in `dtotal`)
    total_cum = get_total(dft)
    cum = DailyData(
        new = total_cum - get_total(dftp),
        total = total_cum,
        total_tests = tests,
        rpn = rpn_urls)

    (Inputs(dlatest, rt), Inputs(dtotal, rt), cum)
end

function init_global(when :: DateTime)
    global latest_inp, total_inp, cum = init(when)
end

#
# The "latest" part of the table
#
latest(i :: Inputs, cum :: DailyData) =
    latest_template(i.data, i.region_names, cum, n())

#
# The "total" part of the table
#
total(i :: Inputs, cum :: DailyData) =
    total_template(i.data, i.region_names, cum)


check_data_available(when :: DateTime) =
    isfile(DATA_FILE(when, data_format[mode])) &&
    isfile(DATA_FILE(when, tests_format[mode])) &&
    isfile(INPUT_RPN(when))

#
# Check that the data available and generate the both rows
# of the table
#
function generate_table()
    try
        when = n()
        if !check_data_available(when)
            return "COVID-19 data for today is not available in our data " *
                   "sources (Minzdrav, Rospotrebnadzor) yet\n"
        end
        init_global(when)
        latest(latest_inp, cum) * total(total_inp, cum)
    catch e
        if isa(e, ErrorException)
            e.msg
        else
            "Unknown error:\n$(e)\n"
        end
    end
end

#
# Serve table via HTTP
#
function server()
    HTTP.serve() do req::HTTP.Request
        @info "Server received a request with target $(req.target)"
        return if req.target == "/"
            @info "Generating response..."
            r = HTTP.Response(200, resp_html(generate_table()))
            @info "... done"
            r
        else
            HTTP.Response(404)
        end
    end
end

#
###########################################################
#
### Main
#

main() = print(generate_table())

@info "Loading dictionary of region names..."
rdft = CSV.File(METADATA_DIR * "regions-map-minzdrav.csv") |> DataFrame
rt = Dict(zip(
    map(strip, rdft[!,:RegionEn]), 
    map(strip, rdft[!,:RegionRu])))
r_stopkor = CSV.File(METADATA_DIR * "regions-map-stopkorona.csv") |> DataFrame
@info "... done"
