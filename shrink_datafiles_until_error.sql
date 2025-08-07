
SET SERVEROUTPUT ON
DECLARE
    v_file_id      NUMBER;
    v_file_name    VARCHAR2(512);
    v_bytes        NUMBER;
    v_new_size     NUMBER;
    v_done         BOOLEAN := FALSE;
    v_step_bytes   CONSTANT NUMBER := 1024 * 1024 * 1024; -- 1GB in bytes
    v_sql          VARCHAR2(1000);
BEGIN
    FOR r IN (
        SELECT file_id, file_name, bytes
        FROM dba_data_files
        ORDER BY file_id
    ) LOOP
        v_file_id   := r.file_id;
        v_file_name := r.file_name;
        v_bytes     := r.bytes;
        v_done      := FALSE;

        DBMS_OUTPUT.PUT_LINE('Processing: ' || v_file_name);

        WHILE NOT v_done LOOP
            BEGIN
                v_new_size := v_bytes - v_step_bytes;
                v_sql := 'ALTER DATABASE DATAFILE ''' || v_file_name || ''' RESIZE ' || v_new_size;
                EXECUTE IMMEDIATE v_sql;
                DBMS_OUTPUT.PUT_LINE('Resized to: ' || ROUND(v_new_size / 1024 / 1024) || ' MB');
                v_bytes := v_new_size;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
                    v_done := TRUE;
            END;
        END LOOP;
    END LOOP;
END;
/ 
