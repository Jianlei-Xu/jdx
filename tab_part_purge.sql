declare
  cursor cur_part is
    select
      p.table_owner, p.table_name, p.partition_name, p.partition_position,
      rank() over (partition by p.table_owner, p.table_name order by p.partition_position desc) as recent_rk
    from dba_tab_partitions p
         join dba_tables t
         on (p.table_owner = t.owner
             and p.table_name = t.table_name)
    where exists
          (select null
           from dba_part_tables pt
           where p.table_owner = pt.owner
             and p.table_name = pt.table_name
             and pt.partitioning_type = 'RANGE');
begin
  for var_part in cur_part loop
    if var_part.recent_rk > 4 then
      execute immediate 'alter table '||var_part.table_owner||'.'||var_part.table_name||' drop partition '||var_part.partition_name;
    end if;
  end loop;
end;
/
