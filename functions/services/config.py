import os
from pathlib import Path

from dotenv import load_dotenv

# Load functions/.env first, then environment variables from runtime.
ENV_PATH = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=ENV_PATH, override=False)

OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
OPENAI_ASSISTANT_IDS = {
    'agent_vijay': os.getenv('ASSISTANT_VIJAY_ID', ''),
    'agent_material': os.getenv('ASSISTANT_MATERIAL_ID', ''),
    'agent_document_tracker': os.getenv('ASSISTANT_DOCUMENT_TRACKER_ID', ''),
    'agent_marketer': os.getenv('ASSISTANT_MARKETER_ID', ''),
    'agent_auto_assign': os.getenv('ASSISTANT_AUTO_ASSIGN_ID', ''),
}

WHATSAPP_TOKEN = os.getenv('WHATSAPP_TOKEN', '')
WHATSAPP_PHONE_NUMBER_ID = os.getenv('WHATSAPP_PHONE_NUMBER_ID', '')
WHATSAPP_API_VERSION = os.getenv('WHATSAPP_API_VERSION', 'v21.0')

RAZORPAY_KEY_ID = os.getenv('RAZORPAY_KEY_ID', '')
RAZORPAY_KEY_SECRET = os.getenv('RAZORPAY_KEY_SECRET', '')

META_GRAPH_TOKEN = os.getenv('META_GRAPH_TOKEN', '')
TELEGRAM_BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN', '')
YOUTUBE_API_KEY = os.getenv('YOUTUBE_API_KEY', '')
