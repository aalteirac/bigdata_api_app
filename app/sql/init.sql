-- =============================================================================
-- Bigdata.com Native App Setup Script
-- =============================================================================

EXECUTE IMMEDIATE FROM './callbacks.sql';
EXECUTE IMMEDIATE FROM './apis.sql';
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
-- =============================================================================

BEGIN
    LET eai_ref STRING := (SELECT SYSTEM$GET_REFERENCE_DEFINITIONS('BIGDATA_EXTERNAL_ACCESS'));
    LET key_ref STRING := (SELECT SYSTEM$GET_REFERENCE_DEFINITIONS('BIGDATA_API_KEY'));
    
    IF (eai_ref IS NOT NULL AND eai_ref != '' AND key_ref IS NOT NULL AND key_ref != '') THEN
        SYSTEM$LOG_INFO('References found, rebinding EAI and secrets to procedures...');
        
        ALTER PROCEDURE internal._bigdata_search(STRING, STRING, INT)
            SET EXTERNAL_ACCESS_INTEGRATIONS = (reference('bigdata_external_access'))
                SECRETS = ('api_key' = reference('bigdata_api_key'));
        
        ALTER PROCEDURE internal._bigdata_research_agent(STRING, STRING)
            SET EXTERNAL_ACCESS_INTEGRATIONS = (reference('bigdata_external_access'))
                SECRETS = ('api_key' = reference('bigdata_api_key'));
        
        SYSTEM$LOG_INFO('Rebind complete');
    ELSE
        SYSTEM$LOG_INFO('References not yet configured, skipping rebind');
    END IF;
EXCEPTION
    WHEN OTHER THEN
        SYSTEM$LOG_INFO('Rebind skipped: ' || SQLERRM);
END;
