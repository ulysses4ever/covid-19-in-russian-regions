# covid-19-in-russian-regions

This project aims to assist in updating the Wikipedia table

> [https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases](https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases)

showing dynamics of COVID-19 in Russia by region (“federal subject”).
The table is shown in the [main wikipage on COVID-19 in Russia](https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Russia).

The [`src/covid.jl`](src/covid.jl) Julia script generates relevant table rows
provided the data is available in [`data`](data) for desired date.
More comments on usage and the data formats are provided inside the script.


## Datasets

We use two data sources:

1. Rospotrebnadzor publishes region-wise numbers of new cases on daily basis
     on its website ([News section](https://rospotrebnadzor.ru/about/info/news/)).
     We don't use these data in the script per se, instead we use their URLs to
     provide references to "Authorative Sources".

2. Minzdrav publishes total numbers in regions in the form of JSON daily.
   The new data unfortunately overwrites the old data
   [using the same URL](https://covid19.rosminzdrav.ru/wp-json/api/mapdata/).

## User guide

1. Find Rospotrebnadzor data on its website: go to the 
    [News section](https://rospotrebnadzor.ru/about/info/news/)
    and find two pages named:
    
    1.  “_О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России_”,
    2.  “_Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом_”.
    
    Their URLs provide IDs for `DailyData.rsp`, which you should record manually
    in [`data/daily.jl`](data/daily.jl).

2. Download [Minzdrav data](https://covid19.rosminzdrav.ru/wp-json/api/mapdata/) 
    under `data/covidMMDD.json`. This is automated by
    [`src/get-covid-minzdrav.sh`](src/get-covid-minzdrav.sh).

3. Load [`src/covid.jl`](src/covid.jl) into Julia and run `main()`.

4. Profit.

