class FixRoundingTableIdForeignKeyOnExamRules < ActiveRecord::Migration
  def change
    remove_foreign_key :exam_rules, column: :rounding_table_id
    add_foreign_key :exam_rules, :rounding_tables
  end
end
