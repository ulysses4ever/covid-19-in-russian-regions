#
# This file defines two functions `main_latest` and `main_total`
# generating the last two rows for the Wikipedia  table
# 
#   https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases
#
# Latest is supposed to be today's update on numbers, but can be set to 
# whatever date (c.f. `n` constant below), provided we have data for 
# it (c.f. section Inputs below). Same with `total`: this is the total 
# numbers by the the date `n`, provided we have the data.
#

using Dates
using DataFrames
using CSV
using JSON


### Constants

# Tha date of interest
n=now()

### Dull constants (e.g. paths)

tag = Dates.format(n, "mmdd")
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
###########################################################
#
### Main
#

function main_latest()

    df = CSV.File(INPUT_LATEST) |> DataFrame
    d = Dict(zip(map(strip, df[!,:Region]), df[!,:NewCases]))

    rmdf = CSV.File(METADATA_DIR * "regions-map-rospotrebnadzor.csv") |> DataFrame
    r = Dict(zip(map(strip, rmdf[!,:RegionEn]), map(strip, rmdf[!,:RegionRu])))
    
    cum=data[tag]

    res_latest = """
!{{nobr|{{abbr|$(f(n, "d U"))|$(f(n, "d U, Y"))}}}}
<!-- Central -->
| $(my_get(d, r["Belgorod Oblast"]))
| $(my_get(d, r["Bryansk Oblast"]))
| $(my_get(d, r["Ivanovo Oblast"]))
| $(my_get(d, r["Kaluga Oblast"]))
| $(my_get(d, r["Kostroma Oblast"]))
| $(my_get(d, r["Kursk Oblast"]))
| $(my_get(d, r["Lipetsk Oblast"]))
| $(my_get(d, r["Moscow Oblast"]))
| $(my_get(d, r["Oryol Oblast"]))
| $(my_get(d, r["Ryazan Oblast"]))
| $(my_get(d, r["Smolensk Oblast"]))
| $(my_get(d, r["Tambov Oblast"]))
| $(my_get(d, r["Tula Oblast"]))
| $(my_get(d, r["Tver Oblast"]))
| $(my_get(d, r["Vladimir Oblast"]))
| $(my_get(d, r["Voronezh Oblast"]))
| $(my_get(d, r["Yaroslavl Oblast"]))
| $(my_get(d, r["Moscow"]))
<!-- Northwestern -->
| $(my_get(d, r["Republic of Karelia"]))
| $(my_get(d, r["Komi Republic"]))
| $(my_get(d, r["Arkhangelsk Oblast"]))
| $(my_get(d, r["Kaliningrad Oblast"]))
| $(my_get(d, r["Leningrad Oblast"]))
| $(my_get(d, r["Murmansk Oblast"]))
| $(my_get(d, r["Novgorod Oblast"]))
| $(my_get(d, r["Pskov Oblast"]))
| $(my_get(d, r["Vologda Oblast"]))
| $(my_get(d, r["Saint Petersburg"]))
| $(my_get(d, r["Nenets AO"]))
<!-- Southern -->
| $(my_get(d, r["Adygea"]))
| $(my_get(d, r["Republic of Crimea"]))
| $(my_get(d, r["Kalmykia"]))
| $(my_get(d, r["Krasnodar Krai"]))
| $(my_get(d, r["Astrakhan Oblast"]))
| $(my_get(d, r["Rostov Oblast"]))
| $(my_get(d, r["Volgograd Oblast"]))
| $(my_get(d, r["Sevastopol"]))
<!-- North Caucasian -->
| $(my_get(d, r["Chechnya"]))
| $(my_get(d, r["Dagestan"]))
| $(my_get(d, r["Ingushetia"]))
| $(my_get(d, r["Kabardino-Balkaria"]))
| $(my_get(d, r["Karachay-Cherkessia"]))
| $(my_get(d, r["North Ossetia"]))
| $(my_get(d, r["Stavropol Krai"]))
<!-- Volga -->
| $(my_get(d, r["Bashkortostan"]))
| $(my_get(d, r["Chuvashia"]))
| $(my_get(d, r["Mari El"]))
| $(my_get(d, r["Mordovia"]))
| $(my_get(d, r["Tatarstan"]))
| $(my_get(d, r["Udmurtia"]))
| $(my_get(d, r["Perm Krai"]))
| $(my_get(d, r["Kirov Oblast"]))
| $(my_get(d, r["Nizhny Novgorod Oblast"]))
| $(my_get(d, r["Orenburg Oblast"]))
| $(my_get(d, r["Penza Oblast"]))
| $(my_get(d, r["Samara Oblast"]))
| $(my_get(d, r["Saratov Oblast"]))
| $(my_get(d, r["Ulyanovsk Oblast"]))
<!-- Ural -->
| $(my_get(d, r["Chelyabinsk Oblast"]))
| $(my_get(d, r["Kurgan Oblast"]))
| $(my_get(d, r["Sverdlovsk Oblast"]))
| $(my_get(d, r["Tyumen Oblast"]))
| $(my_get(d, r["Khanty-Mansi AO"]))
| $(my_get(d, r["Yamalo-Nenets AO"]))
<!-- Siberian -->
| $(my_get(d, r["Altai Republic"]))
| $(my_get(d, r["Khakassia"]))
| $(my_get(d, r["Tuva"]))
| $(my_get(d, r["Altai Krai"]))
| $(my_get(d, r["Krasnoyarsk Krai"]))
| $(my_get(d, r["Irkutsk Oblast"]))
| $(my_get(d, r["Kemerovo Oblast"]))
| $(my_get(d, r["Novosibirsk Oblast"]))
| $(my_get(d, r["Omsk Oblast"]))
| $(my_get(d, r["Tomsk Oblast"]))
<!-- Far Eastern -->
| $(my_get(d, r["Buryatia"]))
| $(my_get(d, r["Yakutia"]))
| $(my_get(d, r["Kamchatka Krai"]))
| $(my_get(d, r["Khabarovsk Krai"]))
| $(my_get(d, r["Primorsky Krai"]))
| $(my_get(d, r["Zabaykalsky Krai"]))
| $(my_get(d, r["Amur Oblast"]))
| $(my_get(d, r["Magadan Oblast"]))
| $(my_get(d, r["Sakhalin Oblast"]))
| $(my_get(d, r["Chukotka AO"]))
| $(my_get(d, r["Jewish AO"]))
!{{nobr|{{abbr|$(f(n, "d U"))|$(f(n, "d U, Y"))}}}}
! $(cum.new.cases)
! $(cum.total.cases)
! $(cum.new.recovered)
! $(cum.total.recovered)
! $(cum.new.deaths)
! $(cum.total.deaths)
| $(cum.total_tests)
| $(refs(cum.rsp.id1, cum.rsp.id2))
|-
"""
end

function main_total()

    df = JSON.parsefile(INPUT_TOTAL)["Items"]
    d = Dict([r["LocationName"] => r["Confirmed"] for r in df])

    rmdf = CSV.File(METADATA_DIR * "regions-map-minzdrav.csv") |> DataFrame
    r = Dict(zip(map(strip, rmdf[!,:RegionEn]), map(strip, rmdf[!,:RegionRu])))

    cum=data[tag]

    res_total = """
! Total
<!-- Central -->
! $(my_get(d, r["Belgorod Oblast"]))
! $(my_get(d, r["Bryansk Oblast"]))
! $(my_get(d, r["Ivanovo Oblast"]))
! $(my_get(d, r["Kaluga Oblast"]))
! $(my_get(d, r["Kostroma Oblast"]))
! $(my_get(d, r["Kursk Oblast"]))
! $(my_get(d, r["Lipetsk Oblast"]))
! $(my_get(d, r["Moscow Oblast"]))
! $(my_get(d, r["Oryol Oblast"]))
! $(my_get(d, r["Ryazan Oblast"]))
! $(my_get(d, r["Smolensk Oblast"]))
! $(my_get(d, r["Tambov Oblast"]))
! $(my_get(d, r["Tula Oblast"]))
! $(my_get(d, r["Tver Oblast"]))
! $(my_get(d, r["Vladimir Oblast"]))
! $(my_get(d, r["Voronezh Oblast"]))
! $(my_get(d, r["Yaroslavl Oblast"]))
! $(my_get(d, r["Moscow"]))
<!-- Northwestern -->
! $(my_get(d, r["Republic of Karelia"]))
! $(my_get(d, r["Komi Republic"]))
! $(my_get(d, r["Arkhangelsk Oblast"]))
! $(my_get(d, r["Kaliningrad Oblast"]))
! $(my_get(d, r["Leningrad Oblast"]))
! $(my_get(d, r["Murmansk Oblast"]))
! $(my_get(d, r["Novgorod Oblast"]))
! $(my_get(d, r["Pskov Oblast"]))
! $(my_get(d, r["Vologda Oblast"]))
! $(my_get(d, r["Saint Petersburg"]))
! $(my_get(d, r["Nenets AO"]))
<!-- Southern -->
! $(my_get(d, r["Adygea"]))
! $(my_get(d, r["Republic of Crimea"]))
! $(my_get(d, r["Kalmykia"]))
! $(my_get(d, r["Krasnodar Krai"]))
! $(my_get(d, r["Astrakhan Oblast"]))
! $(my_get(d, r["Rostov Oblast"]))
! $(my_get(d, r["Volgograd Oblast"]))
! $(my_get(d, r["Sevastopol"]))
<!-- North Caucasian -->
! $(my_get(d, r["Chechnya"]))
! $(my_get(d, r["Dagestan"]))
! $(my_get(d, r["Ingushetia"]))
! $(my_get(d, r["Kabardino-Balkaria"]))
! $(my_get(d, r["Karachay-Cherkessia"]))
! $(my_get(d, r["North Ossetia"]))
! $(my_get(d, r["Stavropol Krai"]))
<!-- Volga -->
! $(my_get(d, r["Bashkortostan"]))
! $(my_get(d, r["Chuvashia"]))
! $(my_get(d, r["Mari El"]))
! $(my_get(d, r["Mordovia"]))
! $(my_get(d, r["Tatarstan"]))
! $(my_get(d, r["Udmurtia"]))
! $(my_get(d, r["Perm Krai"]))
! $(my_get(d, r["Kirov Oblast"]))
! $(my_get(d, r["Nizhny Novgorod Oblast"]))
! $(my_get(d, r["Orenburg Oblast"]))
! $(my_get(d, r["Penza Oblast"]))
! $(my_get(d, r["Samara Oblast"]))
! $(my_get(d, r["Saratov Oblast"]))
! $(my_get(d, r["Ulyanovsk Oblast"]))
<!-- Ural -->
! $(my_get(d, r["Chelyabinsk Oblast"]))
! $(my_get(d, r["Kurgan Oblast"]))
! $(my_get(d, r["Sverdlovsk Oblast"]))
! $(my_get(d, r["Tyumen Oblast"]))
! $(my_get(d, r["Khanty-Mansi AO"]))
! $(my_get(d, r["Yamalo-Nenets AO"]))
<!-- Siberian -->
! $(my_get(d, r["Altai Republic"]))
! $(my_get(d, r["Khakassia"]))
! $(my_get(d, r["Tuva"]))
! $(my_get(d, r["Altai Krai"]))
! $(my_get(d, r["Krasnoyarsk Krai"]))
! $(my_get(d, r["Irkutsk Oblast"]))
! $(my_get(d, r["Kemerovo Oblast"]))
! $(my_get(d, r["Novosibirsk Oblast"]))
! $(my_get(d, r["Omsk Oblast"]))
! $(my_get(d, r["Tomsk Oblast"]))
<!-- Far Eastern -->
! $(my_get(d, r["Buryatia"]))
! $(my_get(d, r["Yakutia"]))
! $(my_get(d, r["Kamchatka Krai"]))
! $(my_get(d, r["Khabarovsk Krai"]))
! $(my_get(d, r["Primorsky Krai"]))
! $(my_get(d, r["Zabaykalsky Krai"]))
! $(my_get(d, r["Amur Oblast"]))
! $(my_get(d, r["Magadan Oblast"]))
! $(my_get(d, r["Sakhalin Oblast"]))
! $(my_get(d, r["Chukotka AO"]))
! $(my_get(d, r["Jewish AO"]))
! Total
! colspan="2" | $(cum.total.cases){{efn|name="diamond-princess"}}
! colspan="2" | $(cum.total.recovered){{efn|name="diamond-princess"}}
! colspan="2" | $(cum.total.deaths)
! {{n/a}}
! <ref name="Rus_Ministry">{{cite web |title=Информация о новой коронавирусной инфекции |trans-title=Information on Novel Coronavirus Infection |url=https://www.rosminzdrav.ru/ministry/covid19 |publisher=[[Ministry of Health (Russia)|Ministry of Health]] |accessdate=19 May 2020 |language=ru}}</ref><ref name="Rus_Taskforce">{{cite web |title=Оперативные данные|trans-title=Operational data| url=https://xn--80aesfpebagmfblc0a.xn--p1ai/ |website=Стопкоронавирус.рф |accessdate=19 May 2020 |language=ru}}</ref>
"""

end
