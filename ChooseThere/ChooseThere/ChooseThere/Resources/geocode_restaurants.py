#!/usr/bin/env python3
"""
Script para geocodificar restaurantes usando Nominatim (OpenStreetMap).
Busca lat/lng baseado no endereço e salva no JSON.
"""

import json
import time
import os
import sys
import urllib.parse
import urllib.request

INPUT_FILE = "Restaurants.json"
OUTPUT_FILE = "Restaurants.json"

USER_AGENT = "ChooseThere/1.0 (iOS App Development; contact@example.com)"

# Nominatim API (OpenStreetMap) - gratuito e mais confiável
NOMINATIM_ENDPOINT = "https://nominatim.openstreetmap.org/search"


def extract_restaurants(payload):
    if isinstance(payload, dict) and isinstance(payload.get("restaurants"), list):
        return payload["restaurants"]
    if isinstance(payload, list):
        return payload
    return None


def build_query(item: dict) -> str:
    """Constrói a query de busca usando apenas o endereço (sem nome do restaurante)."""
    address = (item.get("address") or "").strip()
    city = (item.get("city") or "").strip()
    state = (item.get("state") or "").strip()

    # Se não tem endereço, usa apenas cidade/estado
    if not address:
        return f"{city}, {state}, Brasil" if city else None

    parts = []
    if address:
        parts.append(address)
    if city:
        parts.append(city)
    if state:
        parts.append(state)
    parts.append("Brasil")

    return ", ".join([p for p in parts if p])


def geocode_nominatim(query: str):
    """Busca coordenadas usando Nominatim API."""
    params = {
        "q": query,
        "format": "json",
        "limit": "1",
        "addressdetails": "1",
        "countrycodes": "br"
    }
    url = NOMINATIM_ENDPOINT + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if not data:
                return None, None, "ZERO_RESULTS"

            lat = float(data[0]["lat"])
            lng = float(data[0]["lon"])
            return lat, lng, "OK"
    except urllib.error.HTTPError as e:
        return None, None, f"HTTP_ERROR: {e.code}"
    except Exception as e:
        return None, None, f"ERROR: {e}"


def main():
    print("=== Geocoding Restaurants (Nominatim - OpenStreetMap) ===")
    print(f"📂 Input: {INPUT_FILE}")
    print(f"📂 Output: {OUTPUT_FILE}")
    print()

    if not os.path.exists(INPUT_FILE):
        print(f"❌ Arquivo não encontrado: {INPUT_FILE}")
        sys.exit(1)

    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        payload = json.load(f)

    restaurants = extract_restaurants(payload)
    if restaurants is None:
        print("❌ Estrutura do JSON não reconhecida.")
        sys.exit(1)

    print(f"✅ Carregado(s): {len(restaurants)} restaurantes")

    updated = 0
    skipped = 0
    failed = 0

    for idx, item in enumerate(restaurants, start=1):
        name = item.get("name", "Unknown")

        # Se já tem coordenadas válidas, pula
        if item.get("lat") is not None and item.get("lng") is not None:
            skipped += 1
            continue

        query = build_query(item)
        if not query:
            print(f"[{idx}/{len(restaurants)}] ⚠️  {name} -> Sem endereço, pulando...")
            failed += 1
            continue

        print(f"[{idx}/{len(restaurants)}] 🔍 {name}")
        print(f"    Query: {query}")

        lat, lng, status = geocode_nominatim(query)

        if status == "OK":
            item["lat"] = lat
            item["lng"] = lng
            updated += 1
            print(f"    ✅ lat={lat:.6f}, lng={lng:.6f}")
        else:
            print(f"    ❌ {status}")
            failed += 1

        # Rate limit - Nominatim pede 1 request por segundo
        time.sleep(1.1)

    # Salva o resultado
    if isinstance(payload, dict) and "restaurants" in payload:
        payload["restaurants"] = restaurants
        output_payload = payload
    else:
        output_payload = restaurants

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output_payload, f, ensure_ascii=False, indent=2)

    print()
    print("=" * 50)
    print(f"✅ Geocodados: {updated}")
    print(f"⏭️  Já tinham coords: {skipped}")
    print(f"❌ Falhas: {failed}")
    print(f"📦 Salvo em: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
