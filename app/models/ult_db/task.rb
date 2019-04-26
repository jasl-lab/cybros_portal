module UltDb
  class Task < ApplicationRecord
    # No corresponding table in the DB.
    self.abstract_class = true
    establish_connection :ultdb2014r2
    def readonly?
      true
    end

    def self.get_tasks(process_name = nil, assigned_to_user = nil)
      sql = "
select TOP 100 TASKID, PROCESSNAME, INCIDENT, STEPLABEL, ASSIGNEDTOUSER, STARTTIME
from TASKS
where STATUS=1 -- 1 = 处理中
  "
      sql += "  AND PROCESSNAME = '#{process_name}'" if process_name.present?
      sql += "  AND ASSIGNEDTOUSER = 'Thape/#{assigned_to_user}'" if assigned_to_user.present?
      Task.connection.select_rows(sql)
    end

    def self.all_process_name
      Task.connection.select_rows("
select ext02, Process
from UltBusinessDB_TH.dbo.PROC_CONFIG group by Process, EXT02
  ")
    end
  end
end
