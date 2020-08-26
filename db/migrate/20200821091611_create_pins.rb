class CreatePins < ActiveRecord::Migration[6.0]
  def change
    create_table :pins do |t|
      t.string :cid
      t.string :name
      t.string :origins
      t.string :meta
      t.string :status
      t.string :delegates
      t.string :info

      t.timestamps
    end
  end
end
