
import firebase_admin
from firebase_admin import firestore
from firebase_functions import https_fn
from openai import OpenAI
import os
import time
from math import radians, cos, sin, asin, sqrt

firebase_admin.initialize_app()
db = firestore.client()
openai_client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

# Twilio optional
twilio_client = None
try:
    from twilio.rest import Client
    TWILIO_SID = os.environ.get("TWILIO_ACCOUNT_SID")
    TWILIO_TOKEN = os.environ.get("TWILIO_AUTH_TOKEN")
    TWILIO_WHATSAPP = os.environ.get("TWILIO_WHATSAPP_NUMBER")
    if TWILIO_SID and TWILIO_TOKEN:
        twilio_client = Client(TWILIO_SID, TWILIO_TOKEN)
except ImportError:
    pass


ASSISTANT_IDS = {
    "vijay": "asst_uxkg08diooFsbEtgmOA3dhLW",  # Agent Vijay
    "material": "asst_9pKJwFDHXkjTDbuMVocXX10o",  # Agent Material
    "document_tracker": "asst_hx6nHjRw8l0KRjw7DizfVWC2",  # Agent Document Tracker
    "auto_assign": "asst_BUVPTpDLiMLCV9TwbIBkdI39",  # Agent Auto Assign
    "marketer": "asst_sxfuZfeg7s0Sx88laqKcqA6x",  # Agent Marketer
}

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # km
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    return R * c

@https_fn.on_call()
def routeAgentMessage(req):
    data = req.data
    agent_id = data.get("agentId")
    message = data.get("message")
    thread_id = data.get("threadId")
    user_phone = data.get("userPhone")
    builder_phone = data.get("builderPhone")
    project_id = data.get("projectId")

    if agent_id not in ASSISTANT_IDS:
        return {"error": "Invalid agentId"}

    assistant_id = ASSISTANT_IDS[agent_id]

    if not thread_id:
        thread = openai_client.beta.threads.create()
        thread_id = thread.id

    openai_client.beta.threads.messages.create(thread_id=thread_id, role="user", content=message)

    run = openai_client.beta.threads.runs.create(thread_id=thread_id, assistant_id=assistant_id)

    start = time.time()
    while run.status in ["queued", "in_progress"]:
        if time.time() - start > 180:
            return {"error": "Timeout"}
        time.sleep(3)
        run = openai_client.beta.threads.runs.retrieve(thread_id=thread_id, run_id=run.id)

    if run.status != "completed":
        return {"error": f"Run failed: {run.last_error or run.status}"}

    reply = openai_client.beta.threads.messages.list(thread_id=thread_id, limit=1).data[0].content[0].text.value

    # WhatsApp trigger for Document_tracker
    if agent_id == "document_tracker" and twilio_client:
        lower = reply.lower()
        if any(k in lower for k in ["finalized", "payment done", "job started", "job done", "changes added", "contract", "invoice", "plan approved"]):
            body = f"Patchworks: {reply[:150]}... Full in app."
            if user_phone:
                twilio_client.messages.create(from_=TWILIO_WHATSAPP, to=f"whatsapp:{user_phone}", body=body)
            if builder_phone:
                twilio_client.messages.create(from_=TWILIO_WHATSAPP, to=f"whatsapp:{builder_phone}", body=body)

    # Auto-assign commission (hidden, logged only)
    if agent_id == "auto_assign" and project_id:
        # Example: assume coords in message or DB
        # distance = haversine(home_lat, home_lon, builder_lat, builder_lon)
        # if distance > 5:
        #     commission = 0.10 * quote  # from context
        #     db.collection('commissions').add({'project': project_id, 'amount': commission, 'hidden': True})
        reply += "\n(10% commission logged internally - not visible to homeowner)"

    return {"reply": reply, "threadId": thread_id}