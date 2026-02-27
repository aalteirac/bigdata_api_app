-- =============================================================================
-- Bigdata.com Native App - MCP Tools Internal Procedures
-- =============================================================================

-- Drop old procedure signatures to avoid overload conflicts
DROP PROCEDURE IF EXISTS internal._mcp_company_tearsheet(STRING);
DROP PROCEDURE IF EXISTS internal._mcp_events_calendar(STRING, STRING, STRING);
DROP PROCEDURE IF EXISTS internal._mcp_country_tearsheet(STRING);

CREATE OR REPLACE PROCEDURE internal._mcp_call(
    tool_name STRING,
    arguments VARIANT
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

MCP_URL = "https://mcp.bigdata.com"

def main(session, tool_name: str, arguments: dict) -> str:
    api_key = _snowflake.get_generic_secret_string('api_key')
    
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "x-api-key": api_key
    }
    
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {"name": tool_name, "arguments": arguments or {}}
    }
    
    try:
        resp = requests.post(MCP_URL, headers=headers, json=payload, stream=True, timeout=180)
        resp.raise_for_status()
        
        result = None
        for line in resp.iter_lines(decode_unicode=True):
            if line and line.startswith("data:"):
                data = line[5:].strip()
                if data:
                    try:
                        result = json.loads(data)
                    except json.JSONDecodeError:
                        pass
        
        if result:
            if "result" in result:
                return json.dumps(result["result"], indent=2)
            elif "error" in result:
                return json.dumps({"error": result["error"]}, indent=2)
        return json.dumps(result, indent=2)
    except requests.exceptions.HTTPError as e:
        return json.dumps({"error": str(e), "response": resp.text[:500]})
    except Exception as e:
        return json.dumps({"error": str(e)})
$$;

CREATE OR REPLACE PROCEDURE internal._mcp_search(
    search_text STRING,
    max_chunks INT DEFAULT 10
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._mcp_call('bigdata_search', OBJECT_CONSTRUCT('search_text', :search_text, 'max_chunks', :max_chunks)) INTO result;
    RETURN result;
END;

CREATE OR REPLACE PROCEDURE internal._mcp_find_companies(
    query STRING
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._mcp_call('find_companies', OBJECT_CONSTRUCT('query', :query)) INTO result;
    RETURN result;
END;

CREATE OR REPLACE PROCEDURE internal._mcp_company_tearsheet(
    rp_entity_id STRING,
    company_type STRING,
    interval STRING DEFAULT 'quarter'
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._mcp_call('bigdata_company_tearsheet', OBJECT_CONSTRUCT('rp_entity_id', :rp_entity_id, 'company_type', :company_type, 'interval', :interval)) INTO result;
    RETURN result;
END;
