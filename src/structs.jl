
struct Params
    cases       :: String
    recovered   :: String
    deaths      :: String
    
    Params(;cases :: String, recovered :: String, deaths :: String) =
        new(cases, recovered, deaths)
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
    
    DailyData(;new :: Params,
              total :: Params,
              rsp :: RospotrebUrlIds,
              total_tests :: String) = new(new, total, rsp, total_tests)
end

struct Inputs
    data :: Dict
    region_names :: Dict
end
