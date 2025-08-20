declare
  out_file utl_file.file_type;
  ddl_start boolean := true;
begin
        out_file := utl_file.fopen('CERT_DIR','ddl_creater.out','w');
        for tab_line in (select owner, table_name, column_name, data_type, column_pos from src_tab_columns
                         order by owner, table_name, column_pos)
        loop
                if tab_line.column_pos = 1
                then
                        if ddl_start then
                                ddl_start := false;
                        else
                                utl_file.put_line(out_file,',PARTNER_SRC_OP_TABLE VARCHAR2(40)');
                                utl_file.put_line(out_file,',PARTNER_SRC_OP_TYPE VARCHAR2(10)');
                                utl_file.put_line(out_file,',PARTNER_SRC_OP_TS TIMESTAMP(6)');
                                utl_file.put_line(out_file,',PARTNER_SRC_CURRENT_TS TIMESTAMP(6) DEFAULT systimestamp');
                                utl_file.put_line(out_file,',PARTNER_SRC_PRIMARY_KEYS VARCHAR2(4000)');
                                utl_file.put_line(out_file,',PARTNER_SRC_CSN NUMBER(*,0)');
                                utl_file.put_line(out_file,')');
                                utl_file.put_line(out_file,'PARTITION BY RANGE (PARTNER_SRC_CURRENT_TS) INTERVAL (NUMTODSINTERVAL(7,''DAY''))');
                                utl_file.put_line(out_file,'(PARTITION SYS_P000001 VALUES LESS THAN (TIMESTAMP'' '||to_char(sysdate,'yyyy-mm-dd') ||' 00:00:00''));');
                                utl_file.put_line(out_file,chr(10));
                        end if;
                        utl_file.put_line(out_file,'create table '||tab_line.owner||'.'||tab_line.table_name);
                        utl_file.put_line(out_file,'(');
                        utl_file.put_line(out_file,'    '||tab_line.column_name||'      '||tab_line.data_type);
                else
                        utl_file.put_line(out_file,'    ,'||tab_line.column_name||'     '||tab_line.data_type);
                end if;

        end loop;
        utl_file.put_line(out_file,');');
        utl_file.fclose(out_file);
end;
/
