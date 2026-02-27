# Bigdata.com Tools for Snowflake Cortex Agents

This Native App exposes Bigdata.com API tools as Snowflake stored procedures, enabling seamless integration with Snowflake Cortex Agents.

## Tools Available


`bigdata_search` : Search documents across news, filings, transcripts, and research 
`bigdata_research_agent` : AI research agent for comprehensive analysis and insights 

## Prerequisites

1. A Bigdata.com API key from [Developer Platform](https://platform.bigdata.com/api-keys)

## Usage

### Direct Calls

```sql
-- Search for financial news (smart mode auto-interprets query)
CALL bigdata_app.tools.bigdata_search('NVIDIA earnings Q4 2025', 'smart', 10);

-- Search with fast mode (direct query, no interpretation)
CALL bigdata_app.tools.bigdata_search('Microsoft Azure revenue growth', 'fast', 20);

-- Research agent for comprehensive analysis (standard effort)
CALL bigdata_app.tools.bigdata_research_agent(
    'What are the key takeaways from Apple latest earnings call?',
    'standard'
);

-- Quick research with lite effort (default)
CALL bigdata_app.tools.bigdata_research_agent(
    'Summarize Tesla stock performance this week',
    'lite'
);
```

### Integration with Cortex Agent

Use the **External Agent Setup** tab in the Streamlit app to generate a complete agent creation script. The generated script creates a Cortex Agent with both Bigdata.com tools configured.

Example agent specification:

```sql
CREATE OR REPLACE AGENT MY_DB.MY_SCHEMA.FINANCIAL_ANALYST
    FROM SPECIFICATION $$
{
    "models": {
        "orchestration": "auto"
    },
    "orchestration": {},
    "tools": [
        {
            "tool_spec": {
                "type": "generic",
                "name": "BIGDATA_SEARCH",
                "description": "Search for financial insights across news, SEC filings, earnings transcripts, and research documents.",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "query": {"type": "string", "description": "The financial info you are searching"},
                        "search_mode": {"type": "string", "description": "fast or smart"},
                        "max_chunks": {"type": "number", "description": "Number of chunks to return"}
                    },
                    "required": ["query", "search_mode", "max_chunks"]
                }
            }
        },
        {
            "tool_spec": {
                "type": "generic",
                "name": "BIGDATA_RESEARCH",
                "description": "AI research agent for comprehensive financial analysis.",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "message": {"type": "string", "description": "Research question"},
                        "research_effort": {"type": "string", "description": "lite or standard"}
                    },
                    "required": ["message", "research_effort"]
                }
            }
        }
    ],
    "tool_resources": {
        "BIGDATA_SEARCH": {
            "type": "procedure",
            "identifier": "BIGDATA_APP.TOOLS.BIGDATA_SEARCH",
            "execution_environment": {
                "type": "warehouse",
                "warehouse": "DEMO_WH",
                "query_timeout": 90
            }
        },
        "BIGDATA_RESEARCH": {
            "type": "procedure",
            "identifier": "BIGDATA_APP.TOOLS.BIGDATA_RESEARCH_AGENT",
            "execution_environment": {
                "type": "warehouse",
                "warehouse": "DEMO_WH",
                "query_timeout": 180
            }
        }
    }
}
$$;
```

### Streamlit App

The app includes a built-in Streamlit UI with three tabs:

1. **Search Documents** - Test the search API with different modes
2. **Research Agent** - Test the AI research agent
3. **External Agent Setup** - Generate SQL scripts to create Cortex Agents with Bigdata.com tools


## Support

- Bigdata.com API Documentation: https://docs.bigdata.com/
- Search API: https://docs.bigdata.com/api-reference/search/search-documents
- Research Agent: https://docs.bigdata.com/api-reference/research-agent/research-agent
