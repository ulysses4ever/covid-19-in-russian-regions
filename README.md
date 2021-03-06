# [project is frozen as of Aug 2020] covid-19-in-russian-regions

This project aims to assist in updating the Wikipedia table

> [https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases](https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases)

showing dynamics of COVID-19 in Russia by region (“federal subject”).
The table is shown in the [main wikipage on COVID-19 in Russia](https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Russia).

The [`src/covid.jl`](src/covid.jl) Julia script generates relevant table rows
provided the data is available in [`data`](data) for desired date.
More comments on usage and the data formats are provided below and inside the script.

The result of executing the script is served on [julia.prl.fit.cvut.cz/covid](https://julia.prl.fit.cvut.cz/covid)
(see function `server` in [`src/covid.jl`](src/covid.jl)). You can ask for data on past 'N' days
by using (e.g. for `N=5`): [julia.prl.fit.cvut.cz/covid?d=5](https://julia.prl.fit.cvut.cz/covid?d=5)

## Datasets

We use two data sources:

1. Rospotrebnadzor publishes region-wise numbers of new cases on daily basis
     on its website ([News section](https://rospotrebnadzor.ru/about/info/news/)).
     We don't use these data in the script per se, instead we use their URLs to
     provide references to "Authorative Sources".

2. Minzdrav publishes total numbers in regions in the form of JSON daily.
   The new data unfortunately overwrites the old data
   [using the same URL](https://covid19.rosminzdrav.ru/wp-json/api/mapdata/).
   
   Sometimes Minzdrav suddendly stops doing (e.g. June 6th through 12th). In that case,
   we replace it with [стопкоронавирус.рф](https://стопкоронавирус.рф/information/).

## User guide

1. Find Rospotrebnadzor data on its website: go to the 
    [News section](https://rospotrebnadzor.ru/about/info/news/)
    and find two pages named:
    
    1.  “_О подтвержденных случаях новой коронавирусной инфекции COVID-2019 в России_”,
    2.  “_Информационный бюллетень о ситуации и принимаемых мерах по недопущению распространения заболеваний, вызванных новым коронавирусом_”.
    
    Their URLs provide IDs which we store inside [`data/rpn-url-ids`](data/rpn-url-ids)
    under the `MMDD`-formated filename.
    We automate getting these data in
    [`src/get-rpn.sh`](src/get-rpn.sh).
    
2. Download [Minzdrav data](https://covid19.rosminzdrav.ru/wp-json/api/mapdata/) 
    under `data/minzdrav/MMDD.json`. This is automated by
    [`src/get-minzdrav.sh`](src/get-minzdrav.sh).
	
	Alternatively, store data from [стопкоронавирус.рф](https://стопкоронавирус.рф/information/)
	under `data/minzdrav/MMDD.csv` and the total number of tests from Roskomnadzor link (2) (see
	previous point) under `data/minzdrav/MMDD.tests.txt`. You will need to fiddle with the `mode`
	variable in `covid.jl` (see comments) to make it switch between the input formats, unfortunately.

3. Load [`src/covid.jl`](src/covid.jl) into Julia and run `main()`. E.g. from the shell:

    ```
    julia -L src/covid.jl -e 'main()'
    ```

4. Profit.


To run the server:

```
nohup julia -L covid.jl -e 'server()' 2>&1 &
```

## Dependencies

The main script assumes Julia 1+ with the following packages:

* DataFrames
* CSV
* JSON
* HTTP

The auxiliary Bash scripts assume standard Unix shell environment + `iconv`.
