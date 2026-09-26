import urllib.request
import json

reciters = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
for r_id in reciters:
    url = f"https://api.quran.com/api/v4/chapter_recitations/{r_id}/1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        resp = urllib.request.urlopen(req)
        data = json.loads(resp.read().decode('utf-8'))
        audio_url = data['audio_file']['audio_url']
        print(f"Reciter {r_id}: {audio_url}")
    except Exception as e:
        print(f"Reciter {r_id}: Error {e}")
