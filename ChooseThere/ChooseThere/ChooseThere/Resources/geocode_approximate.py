#!/usr/bin/env python3
"""
Script para adicionar coordenadas aproximadas aos restaurantes
baseado em bairros/ruas conhecidas de São Paulo.
"""

import json
import random

INPUT_FILE = "Restaurants.json"
OUTPUT_FILE = "Restaurants.json"

# Centro de São Paulo como base
SP_CENTER_LAT = -23.5505
SP_CENTER_LNG = -46.6333

# Mapeamento de bairros/ruas para coordenadas aproximadas
LOCATION_MAP = {
    # Bairros
    "pinheiros": (-23.5631, -46.6917),
    "vila madalena": (-23.5535, -46.6913),
    "jardins": (-23.5645, -46.6591),
    "itaim bibi": (-23.5848, -46.6796),
    "moema": (-23.5987, -46.6629),
    "higienópolis": (-23.5427, -46.6569),
    "consolação": (-23.5515, -46.6566),
    "paulista": (-23.5629, -46.6544),
    "centro": (-23.5475, -46.6361),
    "república": (-23.5437, -46.6426),
    "bela vista": (-23.5594, -46.6454),
    "liberdade": (-23.5584, -46.6303),
    "vila buarque": (-23.5402, -46.6494),
    "perdizes": (-23.5365, -46.6726),
    "santa cecília": (-23.5370, -46.6476),
    "brooklin": (-23.6032, -46.6805),
    "campo belo": (-23.6131, -46.6719),
    "vila olímpia": (-23.5972, -46.6856),
    "ibirapuera": (-23.5870, -46.6588),
    "barra funda": (-23.5254, -46.6668),
    "aclimação": (-23.5690, -46.6353),
    
    # Ruas conhecidas
    "fradique coutinho": (-23.5614, -46.6875),
    "augusta": (-23.5515, -46.6534),
    "oscar freire": (-23.5651, -46.6692),
    "haddock lobo": (-23.5631, -46.6550),
    "joão moura": (-23.5571, -46.6927),
    "mourato coelho": (-23.5619, -46.6870),
    "aspicuelta": (-23.5598, -46.6918),
    "fidalga": (-23.5552, -46.6914),
    "lorena": (-23.5718, -46.6663),
    "bela cintra": (-23.5581, -46.6602),
    "padre joão manuel": (-23.5612, -46.6604),
    "artur de azevedo": (-23.5565, -46.6780),
    "fernão dias": (-23.5572, -46.6800),
    "mateus grou": (-23.5564, -46.6917),
    "harmonia": (-23.5521, -46.6924),
    "pedroso de morais": (-23.5631, -46.6882),
    "av. paulista": (-23.5614, -46.6556),
    "av. faria lima": (-23.5751, -46.6869),
    "alameda lorena": (-23.5681, -46.6668),
    "alameda campinas": (-23.5669, -46.6565),
    "rua da consolação": (-23.5558, -46.6545),
    "ipiranga": (-23.5377, -46.6406),
}


def get_coordinates(restaurant):
    """Tenta encontrar coordenadas baseado no endereço."""
    address = (restaurant.get("address") or "").lower()
    city = (restaurant.get("city") or "").lower()
    
    # Se já tem coordenadas válidas, mantém
    if restaurant.get("lat") is not None and restaurant.get("lng") is not None:
        return restaurant["lat"], restaurant["lng"]
    
    # Se não é São Paulo, pula
    if "são paulo" not in city and "sp" not in city.lower():
        # Rio de Janeiro - Barra da Tijuca
        if "rio" in city.lower() or "barra da tijuca" in address:
            return -23.0002, -43.3656
        return None, None
    
    # Procura por matches no mapa de localizações
    best_match = None
    for location, coords in LOCATION_MAP.items():
        if location in address:
            best_match = coords
            break
    
    if best_match:
        # Adiciona pequena variação para não empilhar pins
        lat = best_match[0] + random.uniform(-0.002, 0.002)
        lng = best_match[1] + random.uniform(-0.002, 0.002)
        return round(lat, 6), round(lng, 6)
    
    # Se não encontrou, usa centro de SP com variação maior
    lat = SP_CENTER_LAT + random.uniform(-0.03, 0.03)
    lng = SP_CENTER_LNG + random.uniform(-0.03, 0.03)
    return round(lat, 6), round(lng, 6)


def main():
    print("=== Geocoding Aproximado ===")
    
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        payload = json.load(f)
    
    restaurants = payload.get("restaurants", [])
    print(f"✅ Carregado(s): {len(restaurants)} restaurantes")
    
    updated = 0
    for restaurant in restaurants:
        lat, lng = get_coordinates(restaurant)
        if lat is not None and lng is not None:
            if restaurant.get("lat") is None:
                restaurant["lat"] = lat
                restaurant["lng"] = lng
                updated += 1
                print(f"📍 {restaurant['name']}: {lat}, {lng}")
    
    payload["restaurants"] = restaurants
    
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Atualizados: {updated}/{len(restaurants)}")
    print(f"📦 Salvo em: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()






