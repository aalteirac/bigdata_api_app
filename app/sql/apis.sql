-- =============================================================================
-- Bigdata.com Native App - Internal API Procedures
-- =============================================================================

CREATE OR REPLACE PROCEDURE internal._bigdata_search(
    query STRING,
    search_mode STRING DEFAULT 'smart',
    max_chunks INT DEFAULT 10
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'main'
AS $$
import _snowflake
import requests
import json

def main(session, query: str, search_mode: str = 'smart', max_chunks: int = 10) -> str:
    api_key = _snowflake.get_generic_secret_string('api_key')
    
    url = "https://api.bigdata.com/v1/search"
    headers = {
        "Content-Type": "application/json",
        "X-API-KEY": api_key
    }
    
    payload = {
        "search_mode": search_mode,
        "query": {
            "text": query,
            "max_chunks": max_chunks
        }
    }
    
    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=60)
        resp.raise_for_status()
        return json.dumps(resp.json(), indent=2)
    except requests.exceptions.HTTPError as e:
        return json.dumps({"error": str(e), "response": resp.text[:500]})
    except Exception as e:
        return json.dumps({"error": str(e)})
$$;

CREATE OR REPLACE PROCEDURE internal._bigdata_research_agent(
    message STRING,
    research_effort STRING DEFAULT 'lite'
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'main'
AS $$
import _snowflake
import requests
import json

def main(session, message: str, research_effort: str = 'lite') -> str:
    api_key = _snowflake.get_generic_secret_string('api_key')
    
    url = "https://agents.bigdata.com/v1/research-agent"
    headers = {
        "Content-Type": "application/json",
        "X-API-Key": api_key
    }
    
    payload = {
        "research_effort": research_effort,
        "message": message,
        "persistence_mode": "disabled"
    }
    
    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=120, stream=True)
        resp.raise_for_status()
        
        results = []
        answer_parts = []
        
        for line in resp.iter_lines(decode_unicode=True):
            if line and line.startswith("data:"):
                data = line[5:].strip()
                if data:
                    try:
                        parsed = json.loads(data)
                        msg = parsed.get("message", {})
                        msg_type = msg.get("type")
                        
                        if msg_type == "ANSWER":
                            content = msg.get("content", "")
                            if content:
                                answer_parts.append(content)
                        elif msg_type == "THINKING":
                            results.append({"type": "thinking", "content": msg.get("content", "")})
                        elif msg_type == "ACTION":
                            results.append({"type": "action", "tool": msg.get("tool_name"), "args": msg.get("tool_arguments")})
                    except json.JSONDecodeError:
                        pass
        
        final_answer = "".join(answer_parts) if answer_parts else None
        
        return json.dumps({
            "answer": final_answer,
            "trace": results
        }, indent=2)
    except requests.exceptions.HTTPError as e:
        return json.dumps({"error": str(e), "response": resp.text[:500]})
    except Exception as e:
        return json.dumps({"error": str(e)})
$$;
