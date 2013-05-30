class AddShowColumn < ActiveRecord::Migration
  def self.up
    change_table :entries do |t|
      t.boolean :show, :default => true
    end
  end

  def self.down
    change_table :entries do |t|
      t.remove :show
    end
  end
end
