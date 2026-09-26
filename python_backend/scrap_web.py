import csv
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin

def scrape_fatwas_with_details(page_number=1):
    base_url = "https://alsalafiyyah.github.io"
    # Adjust URL pattern based on your site's pagination
    list_url = f"{base_url}/fatwas/" if page_number == 1 else f"{base_url}/fatwas/{page_number}/"

    print(f"Scraping list page: {list_url}")
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
    }

    response = requests.get(list_url, headers=headers)
    if response.status_code != 200:
        print(f"Failed to fetch list page. Status: {response.status_code}")
        return

    soup = BeautifulSoup(response.text, "html.parser")
    extracted_data = []

    fatwa_blocks = soup.find_all("div", class_="flex flex-col gap-2")

    for block in fatwa_blocks:
        scholar_tag = block.find("span", class_="text-zinc-400")
        scholar = scholar_tag.text.strip() if scholar_tag else "Unknown"

        title_tag = block.find("h3")
        title = title_tag.text.strip() if title_tag else "No Title"

        link_tag = block.find_parent("a") 
        if not link_tag and title_tag:
            link_tag = title_tag.find_parent("a")

        detail_url = "No Link"
        full_content = "No Content"

        if link_tag and 'href' in link_tag.attrs:
            detail_url = urljoin(base_url, link_tag['href'])
            
            print(f"  Fetching details for: {title[:30]}...")
            detail_response = requests.get(detail_url, headers=headers)
            
            if detail_response.status_code == 200:
                detail_soup = BeautifulSoup(detail_response.text, "html.parser")
                
                # Locate the main body wrapper
                main_content = detail_soup.find("article") or detail_soup.find("main") or detail_soup.find("body")
                
                if main_content:
                    # EXTRACT PARAGRAPHS, HEADINGS, AND LISTS
                    # This ensures "QUESTION:" and "ANSWER:" headers are caught alongside the text
                    elements = main_content.find_all(["h1", "h2", "h3", "h4", "h5", "h6", "p", "ul", "ol", "strong"])
                    
                    full_content = "\n\n".join([el.text.strip() for el in elements if len(el.text.strip()) > 0])
                else:
                    full_content = "Could not locate main text content."

        extracted_data.append([scholar, title, detail_url, full_content])

    # Save using utf-8-sig to ensure Excel reads special characters properly
    with open("fatwas_full_details.csv", "w", newline="", encoding="utf-8-sig") as file:
        writer = csv.writer(file)
        writer.writerow(["Scholar", "Title", "Link", "Full Content"])
        writer.writerows(extracted_data)

    print(f"Successfully saved {len(extracted_data)} items to 'fatwas_full_details.csv'")

# Execute the function
scrape_fatwas_with_details(1)