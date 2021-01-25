class FillingNaToKnowledgeCategory1 < ActiveRecord::Migration[6.0]
  def up
    Company::Knowledge.where(category_1: "").or(Company::Knowledge.where(category_1: nil)).update_all(category_1: "N/A")
  end

  def down
    Company::Knowledge.where(category_1: "N/A").update_all(category_1: nil)
  end
end
