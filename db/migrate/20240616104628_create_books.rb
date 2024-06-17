class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string  :title,           null: false, default: nil
      t.string  :description,     null: true,  default: nil
      t.integer :author_id,       null: false, default: nil
      t.string :author_full_name, null: false, default: nil

      t.timestamps
    end
  end
end
