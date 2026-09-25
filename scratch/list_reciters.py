import urllib.request
import json

url = "https://api.quran.com/api/v4/resources/recitations"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
resp = urllib.request.urlopen(req)
data = json.loads(resp.read().decode('utf-8'))
for r in data['recitations']:
    print(f"{r['id']}|{r['reciter_name']}|{r.get('style')}")
