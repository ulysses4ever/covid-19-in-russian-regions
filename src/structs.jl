
struct Params
    cases       :: String
    recovered   :: String
    deaths      :: String

    Params(cases :: String, recovered :: String, deaths :: String) =
        new(cases, recovered, deaths)

    Params(;cases :: String, recovered :: String, deaths :: String) =
        new(cases, recovered, deaths)
    
    # The deafult constructor for initializations
    Params() = new("","","")
end

struct RospotrebUrlIds
    id1 :: Int
    id2 :: Int
end

mutable struct DailyData
    new   :: Params
    total :: Params
    rsp   :: RospotrebUrlIds
    total_tests :: String
    
    DailyData(;new :: Params = Params(),
              total :: Params = Params(),
              rsp :: RospotrebUrlIds,
              total_tests :: String = "") = new(new, total, rsp, total_tests)
end

struct Inputs
    data :: Dict
    region_names :: Dict
end

#
# Aux methods
#
import Base.-
function -(p1 :: Params, p2 :: Params)
    c1, r1, d1 = uncommify(p1)
    c2, r2, d2 = uncommify(p2)
    Params(commify(c1 - c2),
           commify(r1 - r2),
           commify(d1 - d2))
end

uncommify(s :: String) :: Int = parse(Int, filter(c -> c != ',', s))
uncommify(p :: Params) :: Tuple{Int, Int, Int} =
    (uncommify(p.cases), uncommify(p.recovered), uncommify(p.deaths))
