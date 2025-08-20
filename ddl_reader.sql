declare
  in_file utl_file.file_type;
  line varchar2(4000);
  oname varchar2(128);
  tname varchar2(128);
  cname varchar2(128);
  dtype varchar2(128);
  is_table_line boolean := false;
  is_column_section boolean := false;
  i integer := 0;
  j integer := 0;
begin
        execute immediate 'truncate table src_tab_columns';
        in_file := utl_file.fopen('CERT_DIR','vprltabddl.txt','r');
        loop
                begin
                        utl_file.get_line(in_file,line);
                exception
                when no_data_found then
                        exit;
                end;
                line := trim(trim(trailing chr(13) from line));
                if not is_table_line and regexp_like(line,'^CREATE\s+TABLE\s+','i')
                then
                        oname := regexp_substr(line,'[^" ]+\.');
                        oname := trim(both '"' from trim(trailing '.' from oname));
                        tname := regexp_substr(line,'\.[^" ]+');
                        tname := trim(both '"' from substr(tname,2));
                        is_table_line := true;
                elsif is_table_line and line = '('
                then
                        is_table_line := false;
                        is_column_section := true;
                elsif  tname is not null and is_column_section and
                       (regexp_like(line,'\s+VARCHAR2','i') or
                        regexp_like(line,'\s+TIMESTAMP','i') or
                        regexp_like(line,'\s+INTEGER','i') or
                        regexp_like(line,'\s+NUMBER','i') or
                        regexp_like(line,'\s+CLOB\s+','i') or
                        regexp_like(line,'\s+BLOB\s+','i') or
                        regexp_like(line,'\s+DATE\s+','i') or
                        regexp_like(line,'\s+BOOLEAN\s+','i'))
                then
                        cname := regexp_substr(line,'[^" ]+',1,1);
                        cname := trim(both '"' from cname);
                        if regexp_like(line,'\s+[^" \(,]+\([^"\)]+\)') and not regexp_like(line,'\s+INTEGER','i') then
                                dtype := regexp_substr(line,'\s+[^" \(,]+\([^"\)]+\)',1,1);
                        else
                                dtype := regexp_substr(line,'\s+[^" \(,]+',1,1);
                        end if;
                        dtype := trim(trim(trailing ',' from dtype));
                        is_table_line := false;
                        if cname is not null then
                              i := i + 1;
                              select count(*) into j from src_tab_columns s
                              where s.owner = oname and s.table_name = tname and s.column_name = cname;
                              if j = 0 then
                                insert into src_tab_columns
                                values (oname, tname, cname, dtype,i);
                                commit;
                              end if;
                        end if;
                elsif tname is not null and is_column_section and line = ')'
                then
                        is_column_section := false;
                else is_table_line := false;
                        i := 0;
                end if;
        end loop;
        utl_file.fclose(in_file);
end;
/
