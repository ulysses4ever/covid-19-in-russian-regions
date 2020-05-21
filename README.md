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
     This comes in HTML, we manually create text file
     and turn it into a CSV using [`src/getclean-rpn.sh`](src/getclean-rpn.sh).

2. Minzdrav publishes total numbers in regions in the form of JSON.
   The new data unfortunately overwrites the old data 
   [using the same URL](https://covid19.rosminzdrav.ru/wp-json/api/mapdata/).

We call these datasets Rospotrebnadzor and Minzdrav accordingly. 


## User guide

0. Step zero -- manual input (TODO: remove in the future.)  
    Some data requires to be collected manually -- navigate to
    [`data/cumulative.jl`](data/cumulative.jl) for details: we need to
    fill in a new instance of `DailyData` every day.

1. Find Rospotrebnadzor data on its website: go to the 
    [News section](https://rospotrebnadzor.ru/about/info/news/)
    and find two pages named:
    
    1.  “_О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России_”,
    2.  “_Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом_”.
    
    First, their URLs provide IDs for `DailyData.rsp`. The first page 
    has a list with desired numbers, which should be saved as plain text
    
    Second, store the list on the page (1) (“_О подтвержденных…_”)
    as the plain text under `data/covidMMDD.csv` and feed this file to
    [`src/clean-rpn.sh`](src/clean-rpn.sh) to turn it into CSV.

2. Download Minzdrav data under `data/total-covidMMDD.json`.
