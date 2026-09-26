from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
from bs4 import BeautifulSoup

app = FastAPI(title="Al-Salafiyyah Scholars API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_soup(page_number: int):
    base_url = "https://alsalafiyyah.github.io"
    list_url = f"{base_url}/fatwas/" if page_number == 1 else f"{base_url}/fatwas/{page_number}/"
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
    }
    response = requests.get(list_url, headers=headers)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Failed to fetch data")
    return BeautifulSoup(response.text, "html.parser"), base_url


@app.get("/scholars")
def get_scholars(page: int = 1):
    soup, _ = get_soup(page)
    unique_scholars = set()
    fatwa_blocks = soup.find_all("div", class_="flex flex-col gap-2")

    for block in fatwa_blocks:
        scholar_tag = block.find("span", class_="text-zinc-400")
        if scholar_tag:
            scholar_name = scholar_tag.text.strip().title()
            unique_scholars.add(scholar_name)

    return {
        "page": page,
        "count": len(unique_scholars),
        "scholars": sorted(list(unique_scholars))
    }


# NEW ENDPOINT: Fetch all content, optionally filtered by Scholar
@app.get("/fatwas")
def get_fatwas(scholar: str = None, page: int = 1):
    soup, base_url = get_soup(page)
    fatwas = []
    fatwa_blocks = soup.find_all("div", class_="flex flex-col gap-2")

    for block in fatwa_blocks:
        scholar_tag = block.find("span", class_="text-zinc-400")
        current_scholar = scholar_tag.text.strip().title() if scholar_tag else "Unknown"

        # Filter by scholar if the parameter is provided
        if scholar and current_scholar.lower() != scholar.lower():
            continue

        title_tag = block.find("h3")
        title = title_tag.text.strip() if title_tag else "No Title"
        
        summary_tag = block.find("p")
        summary = summary_tag.text.strip() if summary_tag else "No Summary"

        # Find the URL for the specific fatwa
        link_tag = block.find_parent("a") 
        if not link_tag and title_tag:
            link_tag = title_tag.find_parent("a")
            
        link = ""
        if link_tag and 'href' in link_tag.attrs:
            href = link_tag['href']
            link = f"{base_url}{href}" if href.startswith('/') else href

        fatwas.append({
            "scholar": current_scholar,
            "title": title,
            "summary": summary,
            "link": link
        })

    return {
        "page": page,
        "filter": scholar,
        "count": len(fatwas),
        "fatwas": fatwas
    }