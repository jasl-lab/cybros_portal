module UltDb
  class Task < ApplicationRecord
    # No corresponding table in the DB.
    self.abstract_class = true
    establish_connection :ultdb2014r2
    def readonly?
      true
    end

    def self.all_tasks
      Task.connection.select_rows("
select TASKID, PROCESSNAME, INCIDENT, STEPLABEL, ASSIGNEDTOUSER, STARTTIME
from TASKS
where ASSIGNEDTOUSER = 'Thape/009740'
  and STATUS=1 -- 1 = 处理中
  ")
    end
  end
end
