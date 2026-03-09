import json

import httpx

BASE_URL = "http://127.0.0.1:8000/v1/agent"


def run_test(location: str) -> None:
    payload = {
        "message": "Need a contractor recommendation",
        "location": location,
        "max_results": 5,
    }
    response = httpx.post(f"{BASE_URL}?persona=vijay", json=payload, timeout=60.0)
    print(f"\\n=== persona=vijay location={location} ===")
    print(f"status: {response.status_code}")
    try:
        data = response.json()
        print(json.dumps(data, indent=2, ensure_ascii=False))
    except Exception:
        print(response.text)


if __name__ == "__main__":
    run_test("Patancheru")
    run_test("Gachibowli")
