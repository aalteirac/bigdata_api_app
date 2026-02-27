-- =============================================================================
-- Bigdata.com Native App - Reference Callbacks
-- =============================================================================

CREATE OR REPLACE PROCEDURE internal._bind_procedures()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
BEGIN
    ALTER PROCEDURE internal._bigdata_search(STRING, STRING, INT)
        SET EXTERNAL_ACCESS_INTEGRATIONS = (reference('bigdata_external_access'))
            SECRETS = ('api_key' = reference('bigdata_api_key'));
    
    ALTER PROCEDURE internal._bigdata_research_agent(STRING, STRING)
        SET EXTERNAL_ACCESS_INTEGRATIONS = (reference('bigdata_external_access'))
            SECRETS = ('api_key' = reference('bigdata_api_key'));
    
    ALTER PROCEDURE internal._mcp_call(STRING, VARIANT)
        SET EXTERNAL_ACCESS_INTEGRATIONS = (reference('bigdata_external_access'))
            SECRETS = ('api_key' = reference('bigdata_api_key'));
    
    RETURN 'All procedures bound successfully';
END;

CREATE OR REPLACE PROCEDURE setup.register_reference(ref_name STRING, operation STRING, ref_or_alias STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
BEGIN
    SYSTEM$LOG_INFO('register_reference called: ref_name=' || ref_name || ', operation=' || operation || ', ref_or_alias=' || ref_or_alias);
    
    CASE (operation)
        WHEN 'ADD' THEN
            SELECT SYSTEM$SET_REFERENCE(:ref_name, :ref_or_alias);
            SYSTEM$LOG_INFO('Reference ADD completed for: ' || ref_name);
        WHEN 'REMOVE' THEN
            SELECT SYSTEM$REMOVE_REFERENCE(:ref_name, :ref_or_alias);
            SYSTEM$LOG_INFO('Reference REMOVE completed for: ' || ref_name);
        WHEN 'CLEAR' THEN
            SELECT SYSTEM$REMOVE_ALL_REFERENCES(:ref_name);
            SYSTEM$LOG_INFO('Reference CLEAR completed for: ' || ref_name);
    END CASE;
    
    IF (UPPER(ref_name) = 'BIGDATA_EXTERNAL_ACCESS' AND operation = 'ADD') THEN
        SYSTEM$LOG_INFO('Binding EAI and secret to internal procedures...');
        CALL internal._bind_procedures();
        SYSTEM$LOG_INFO('All procedures bound successfully');
    END IF;
    
    RETURN 'Reference ' || ref_name || ' ' || operation || ' completed';
END;

GRANT USAGE ON PROCEDURE setup.register_reference(STRING, STRING, STRING) TO APPLICATION ROLE app_public;

CREATE OR REPLACE PROCEDURE setup.get_configuration_for_reference(ref_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
    CASE (UPPER(ref_name))
        WHEN 'BIGDATA_EXTERNAL_ACCESS' THEN
            RETURN '{
                "type": "CONFIGURATION",
                "payload": {
                    "host_ports": ["api.bigdata.com", "agents.bigdata.com", "mcp.bigdata.com"],
                    "allowed_secrets": "LIST",
                    "secret_references": ["BIGDATA_API_KEY"]
                }
            }';
        WHEN 'BIGDATA_API_KEY' THEN
            RETURN '{
                "type": "CONFIGURATION",
                "payload": {
                    "type": "GENERIC_STRING"
                }
            }';
        ELSE
            RETURN '{"type": "ERROR", "payload": {"message": "Unknown reference: ' || ref_name || '"}}';
    END CASE;
END;

GRANT USAGE ON PROCEDURE setup.get_configuration_for_reference(STRING) TO APPLICATION ROLE app_public;
