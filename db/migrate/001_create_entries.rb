class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.text :reason
      t.string :username
      t.text :response
      t.datetime :date

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
