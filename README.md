# covid-19-in-russian-regions

This project aims to assist in updating the Wikipedia table

> [https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases](https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data/Russia_medical_cases)

showing dynamics of COVID-19 in Russia by region (“federal subject”).
The table is shown in the [main wikipage on COVID-19 in Russia](https://en.wikipedia.org/wiki/COVID-19_pandemic_in_Russia).

The [`src/covid.jl`](src/covid.jl) Julia script generates relevant table rows
provided the data is available in [`data`](data) for desired date.
More comments on usage and the data formats are provided inside the script.
