-- =============================================================================
-- Bigdata.com Native App Setup Script
-- =============================================================================

CREATE APPLICATION ROLE IF NOT EXISTS app_public;

CREATE OR ALTER SCHEMA setup;
GRANT USAGE ON SCHEMA setup TO APPLICATION ROLE app_public;

CREATE OR ALTER VERSIONED SCHEMA tools;
GRANT USAGE ON SCHEMA tools TO APPLICATION ROLE app_public;

CREATE OR ALTER SCHEMA internal;

EXECUTE IMMEDIATE FROM './callbacks.sql';
EXECUTE IMMEDIATE FROM './apis.sql';
EXECUTE IMMEDIATE FROM './mcp.sql';
EXECUTE IMMEDIATE FROM './proxies.sql';

-- =============================================================================
-- STREAMLIT APP
-- =============================================================================

CREATE OR REPLACE STREAMLIT tools.bigdata_app
    FROM '/streamlit'
    MAIN_FILE = 'streamlit_app.py';

GRANT USAGE ON STREAMLIT tools.bigdata_app TO APPLICATION ROLE app_public;

-- =============================================================================
-- REBIND EAI/SECRETS ON UPGRADE (if references already set)
-- Note: Binding also happens via register_reference callback when references are set
-- =============================================================================

CALL internal._bind_procedures();


