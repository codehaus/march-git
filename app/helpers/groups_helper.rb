module GroupsHelper
  include TagHelper
  
  def tags(group)
      sql = <<EOF
  SELECT * from 
    ts_stat('select data_tsv 
             from contents 
             where list_id IN (
               SELECT id FROM LISTS WHERE GROUP_ID = #{group.id}
             ) order by id desc limit 1000') ts
  WHERE NOT EXISTS (SELECT * FROM stop_words sw WHERE sw.word = ts.word)
  order by ndoc desc, nentry desc,word limit 100;
EOF
#SELECT ID FROM sp_lists_in_group(#{group.id})
    return Group.find_by_sql(sql)
  end
  
end
