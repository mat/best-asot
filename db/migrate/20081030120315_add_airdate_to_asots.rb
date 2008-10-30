class AddAirdateToAsots < ActiveRecord::Migration
  def self.up
    add_column :asots, :airdate, :date
  end

  def self.down
    remove_column :asots, :airdate
  end
end
