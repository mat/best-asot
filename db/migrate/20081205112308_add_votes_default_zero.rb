class AddVotesDefaultZero < ActiveRecord::Migration
  def self.up
    change_column :asots, :votes, :integer, :default => 0, :null => false
  end

  def self.down
    change_column :asots, :votes, :integer
  end
end
