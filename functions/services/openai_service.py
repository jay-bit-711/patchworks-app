from openai import OpenAI

from services.config import OPENAI_API_KEY, OPENAI_ASSISTANT_IDS


DISCLAIMER = '⚠️ I am an AI. Any data finalized by humans after site visit is final as I tend to make mistakes.'


def run_assistant(agent_id: str, user_message: str) -> str:
    assistant_id = OPENAI_ASSISTANT_IDS.get(agent_id)
    if not OPENAI_API_KEY or not assistant_id:
        raise ValueError(f'OpenAI config missing for {agent_id}')

    client = OpenAI(api_key=OPENAI_API_KEY)
    thread = client.beta.threads.create()
    client.beta.threads.messages.create(
        thread_id=thread.id,
        role='user',
        content=user_message,
    )

    run = client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=assistant_id,
    )

    if run.status != 'completed':
        raise RuntimeError(f'Assistant run failed with status={run.status}')

    messages = client.beta.threads.messages.list(thread_id=thread.id)
    first = messages.data[0]
    text = first.content[0].text.value if first.content else 'No response from assistant.'
    return f'{DISCLAIMER}\n\n{text}'
