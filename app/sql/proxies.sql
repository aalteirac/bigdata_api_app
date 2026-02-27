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
