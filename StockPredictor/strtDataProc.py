# -*- coding: utf-8 -*-
"""
Created on Thu Mar 31 21:16:45 2016

@author: Jerry Wong
"""

import requests
import json
import csv
port = ['ABMD.OQ']
k = len(port)
#===============================Pull Data=====================
url = "https://dev.api.thomsonreuters.com/eikon/v1/timeseries"

querystring = {"X-TR-API-APP-ID":"SVmwQ31EoclQ8QNgzN10QuXL57V8sRkO"}

payload = "{\r\n     \"rics\": ['GOOG.O'],\r\n     \"interval\": \"Daily\",\r\n     \"startdate\": \"2010-01-04T00:00:00Z\",\r\n     \"enddate\": \"2012-12-31T23:59:59Z\",\r\n     \"fields\":  \r\n       [\"TIMESTAMP\",\"OPEN\",\"HIGH\",\"LOW\",\"CLOSE\",\"VOLUME\"]\r\n}"
headers = {
    'cache-control': "no-cache",
    'postman-token': "c5250829-c43b-8401-97d1-00f2095b4131"
    }

resp1 = requests.request("POST", url, data=payload, headers=headers, params=querystring)


url = "https://dev.api.thomsonreuters.com/eikon/v1/datagrid"

querystring = {"X-TR-API-APP-ID":"SVmwQ31EoclQ8QNgzN10QuXL57V8sRkO"}

payload = "{\r\n     \"instruments\": ['GOOG.O'],\r\n     \"fields\":[ \r\n\t{\"name\": \"TR.GrossProfit.date\"},\r\n\t{\"name\":  \"TR.GrossProfit\"},\r\n\t{\"name\": \"TR.OperatingIncome\"},  \r\n\t{\"name\": \"TR.NetIncomeBeforeTaxes\"},\r\n\t{\"name\":  \"TR.TotalCurrentAssets\"}],\r\n     \"parameters\": {\"Period\":\"FY-1\",\"Period\":\"FY0\"}\r\n}\r\n"
headers = {
    'cache-control': "no-cache",
    'postman-token': "b7a1a575-7d96-1ca7-a9dc-f55291d83e78"
    }

resp2 = requests.request("POST", url, data=payload, headers=headers, params=querystring)
#===========================Assign data to lists======================


timedata = json.loads(resp1.text)['timeseriesData'][0]['dataPoints']
tfields = json.loads(resp1.text)['timeseriesData'][0]['fields']
tdlab = []
for item in tfields:
    tdlab = tdlab+[item['name']]


instdata = json.loads(resp2.text)['data']
ifields = json.loads(resp2.text)['headers'][0]
inlab = []
for item in ifields:
    inlab = inlab + [item['displayName']]
    
#=======================================================================
with open('price.csv', 'w', newline='') as fp:
    a = csv.writer(fp, delimiter=',')
    data = timedata
    a.writerows(data)