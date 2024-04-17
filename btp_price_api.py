# make request to https://mercatiwdg.ilsole24ore.com/FinanzaMercati/api/TimeSeries/GetTimeSeries/IT0005217770.MOT?timeWindow=OneDayCurrent&
import requests

ONE_DAY_CURRENT = "OneDayCurrent"
ONE_WEEK = "OneWeek"
ONE_MONTH = "OneMonth"
THREE_MONTHS = "TreeMonths"
SIX_MONTHS = "SixMonths"
ONE_YEAR = "OneYear"
FIVE_YEARS = "FiveYears"
TEN_YEARS = "TenYears"


def get_btp_prices(isin, time_window=ONE_DAY_CURRENT):
    url = f"https://mercatiwdg.ilsole24ore.com/FinanzaMercati/api/TimeSeries/GetTimeSeries/{isin}.MOT?timeWindow={time_window}&"
    response = requests.get(url)
    return response.json()

print(get_btp_prices("IT0005217770"))

