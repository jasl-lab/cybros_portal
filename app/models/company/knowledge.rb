module Company
  class Knowledge < ApplicationRecord
    has_rich_text :answer
  end
end
