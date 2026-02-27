-- =============================================================================
-- Bigdata.com Native App - Public Proxy Procedures
-- =============================================================================

CREATE OR REPLACE PROCEDURE tools.bigdata_search(
    query STRING,
    search_mode STRING DEFAULT 'smart',
    max_chunks INT DEFAULT 10
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._bigdata_search(:query, :search_mode, :max_chunks) INTO result;
    RETURN result;
END;

GRANT USAGE ON PROCEDURE tools.bigdata_search(STRING, STRING, INT) TO APPLICATION ROLE app_public;

CREATE OR REPLACE PROCEDURE tools.bigdata_research_agent(
    message STRING,
    research_effort STRING DEFAULT 'lite'
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._bigdata_research_agent(:message, :research_effort) INTO result;
    RETURN result;
END;

GRANT USAGE ON PROCEDURE tools.bigdata_research_agent(STRING, STRING) TO APPLICATION ROLE app_public;

-- =============================================================================
-- MCP Tools - Public Proxy Procedures
-- =============================================================================

-- Drop old procedure signatures to avoid overload conflicts
DROP PROCEDURE IF EXISTS tools.mcp_company_tearsheet(STRING);
DROP PROCEDURE IF EXISTS tools.mcp_events_calendar(STRING, STRING, STRING);
DROP PROCEDURE IF EXISTS tools.mcp_country_tearsheet(STRING);

CREATE OR REPLACE PROCEDURE tools.mcp_search(
    search_text STRING,
    max_chunks INT DEFAULT 10
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._mcp_search(:search_text, :max_chunks) INTO result;
    RETURN result;
END;

GRANT USAGE ON PROCEDURE tools.mcp_search(STRING, INT) TO APPLICATION ROLE app_public;

CREATE OR REPLACE PROCEDURE tools.mcp_find_companies(
    query STRING
)
RETURNS STRING
LANGUAGE SQL
AS
DECLARE
    result STRING;
BEGIN
    CALL internal._mcp_find_companies(:query) INTO result;
    RETURN result;
END;

GRANT USAGE ON PROCEDURE tools.mcp_find_companies(STRING) TO APPLICATION ROLE app_public;

CREATE OR REPLACE PROCEDURE tools.mcp_company_tearsheet(
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
    CALL internal._mcp_company_tearsheet(:rp_entity_id, :company_type, :interval) INTO result;
    RETURN result;
END;

GRANT USAGE ON PROCEDURE tools.mcp_company_tearsheet(STRING, STRING, STRING) TO APPLICATION ROLE app_public;

