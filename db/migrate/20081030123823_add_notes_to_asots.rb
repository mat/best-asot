class AddNotesToAsots < ActiveRecord::Migration
  def self.up
    add_column :asots, :notes, :text
  end

  def self.down
    remove_column :asots, :notes
  end
end
