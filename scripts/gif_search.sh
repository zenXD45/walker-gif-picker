#!/usr/bin/env python3
import sys
import requests
import json
import os

API_KEY = "xMhfFvI1XshG5fAuoHLFLYqRAgOA9Tdtz4Qgouj8xaOTTbGk1DI4DHB9kkGBdZ2V"
SEARCH_URL = f"https://api.klipy.com/api/v1/{API_KEY}/gifs/search"
LIMIT = 20

def hunt_for_url(obj):
    if isinstance(obj, str) and obj.startswith("http"): return obj
    if isinstance(obj, dict):
        for key in ['gif', 'url', 'original', 'fixed_height']:
            if key in obj and isinstance(obj[key], str) and obj[key].startswith("http"): return obj[key]
        for val in obj.values():
            res = hunt_for_url(val)
            if res: return res
    if isinstance(obj, list):
        for item in obj:
            res = hunt_for_url(item)
            if res: return res
    return None

def fetch_gifs(query):
    if not query: return []
    try:
        r = requests.get(SEARCH_URL, params={"q": query, "per_page": LIMIT}, timeout=5)
        if r.status_code != 200: return []
        
        data = r.json()
        items = []
        if isinstance(data.get('data'), dict):
            items = data['data'].get('data', [])
        elif isinstance(data.get('data'), list):
            items = data['data']
        elif 'results' in data:
            items = data['results']

        results = []
        for g in items:
            if not isinstance(g, dict): continue
            title = (g.get('name') or g.get('title') or "Untitled GIF").split("|")[0].strip()
            files = g.get('files') or g.get('media_formats') or g
            url = hunt_for_url(files)
            if url:
                results.append({"title": title, "url": url})
        return results
    except Exception:
        return []

import concurrent.futures
import shutil
import hashlib

CACHE_DIR = "/tmp/walker_gifs"
os.makedirs(CACHE_DIR, exist_ok=True)

def download_thumbnail(item):
    url = item['url']
    url_hash = hashlib.md5(url.encode()).hexdigest()
    local_path = os.path.join(CACHE_DIR, f"{url_hash}.gif")
    
    if not os.path.exists(local_path):
        try:
            r = requests.get(url, stream=True, timeout=3)
            if r.status_code == 200:
                with open(local_path, 'wb') as f:
                    shutil.copyfileobj(r.raw, f)
            else:
                return None
        except Exception:
            return None
    return local_path

def main():
    try:
        with open("/tmp/walker_gif.log", "a") as f:
            f.write(f"Args: {sys.argv}\n")
        
        use_plain = "--plain" in sys.argv
        args = [arg for arg in sys.argv[1:] if arg not in ["--json", "--plain"]]
        query = " ".join(args)
                
        if not query:
            return

        gifs = fetch_gifs(query)
        
        if use_plain:
            for g in gifs:
                print(f"{g['url']}|{g['title']}")
        else:
            # Download thumbnails in parallel to keep it snappy
            with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
                future_to_gif = {executor.submit(download_thumbnail, g): g for g in gifs}
                for future in concurrent.futures.as_completed(future_to_gif):
                    g = future_to_gif[future]
                    local_path = future.result()
                    if local_path:
                        g['local_path'] = local_path
                    else:
                        g['local_path'] = g['url'] # Fallback
            
            walker_items = []
            for g in gifs:
                local_path = g.get('local_path', g['url'])
                item = {
                    "label": g['title'],
                    "sub": g['url'],
                    "image": local_path,
                    "exec": f"gif-copy {g['url']}",
                    "preview": {
                        "type": "image",
                        "content": local_path
                    }
                }
                walker_items.append(item)
            print(json.dumps(walker_items))
    except Exception as e:
        with open("/tmp/gif_search_error.log", "a") as f:
            f.write(f"Error: {str(e)}\n")

if __name__ == "__main__":
    main()
