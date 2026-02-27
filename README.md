# Bigdata.com Native App for Snowflake

A Snowflake Native App that exposes Bigdata.com API tools for integration with Snowflake Cortex Agents.

## Overview

This app provides two tools:
- **bigdata_search** - Search across news, SEC filings, earnings transcripts, and research documents
- **bigdata_research_agent** - AI-powered research agent for comprehensive financial analysis

## Project Structure

```
├── app/
│   ├── manifest.yml          # Native App manifest
│   ├── README.md             # In-app documentation
│   ├── sql/
│   │   ├── init.sql          # Main setup script
│   │   ├── callbacks.sql     # Reference callbacks
│   │   ├── apis.sql          # Internal API procedures
│   │   └── proxies.sql       # Public proxy procedures
│   └── streamlit/
│       └── streamlit_app.py  # UI application
├── snowflake.yml             # Snow CLI configuration
├── Makefile                  # Build commands
└── README.md                 # This file
```

## Prerequisites

1. [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) installed
2. A Snowflake connection configured (e.g., `MainAnthonyAccount`)
3. A Bigdata.com API key from [Developer Platform](https://platform.bigdata.com/api-keys)

## Deployment

```bash

# Install/upgrade the app
snow app run --connection <CONNECTION_NAME>
```

Or use the Makefile:

```bash
make deploy
make run
```

## Consumer Setup

After installation, the consumer must configure:

1. **Secret** containing the Bigdata.com API key
2. **External Access Integration** allowing connections to `api.bigdata.com` and `agents.bigdata.com`

These are configured through the app's reference callbacks during setup.

## Documentation

- [Bigdata.com API Docs](https://docs.bigdata.com/)
- [Search API](https://docs.bigdata.com/api-reference/search/search-documents)
- [Research Agent](https://docs.bigdata.com/api-reference/research-agent/research-agent)
