from typing import Any, Dict, Optional

import requests

from services.config import TELEGRAM_BOT_TOKEN


TELEGRAM_API_BASE = 'https://api.telegram.org'


def send_telegram_message(chat_id: str, text: str) -> Dict[str, Any]:
    if not TELEGRAM_BOT_TOKEN:
        raise ValueError('TELEGRAM_BOT_TOKEN is missing')

    url = f'{TELEGRAM_API_BASE}/bot{TELEGRAM_BOT_TOKEN}/sendMessage'
    response = requests.post(
        url,
        json={
            'chat_id': chat_id,
            'text': text[:4096],
            'disable_web_page_preview': True,
        },
        timeout=20,
    )
    response.raise_for_status()
    return response.json()


def send_telegram_photo(chat_id: str, photo_url: str, caption: Optional[str] = None) -> Dict[str, Any]:
    if not TELEGRAM_BOT_TOKEN:
        raise ValueError('TELEGRAM_BOT_TOKEN is missing')

    url = f'{TELEGRAM_API_BASE}/bot{TELEGRAM_BOT_TOKEN}/sendPhoto'
    payload = {'chat_id': chat_id, 'photo': photo_url}
    if caption:
        payload['caption'] = caption[:1024]

    response = requests.post(url, json=payload, timeout=20)
    response.raise_for_status()
    return response.json()
