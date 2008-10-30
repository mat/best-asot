class RemoveDiColumnPrefix < ActiveRecord::Migration
  def self.up
    rename_column :asots, :di_url, :url
    rename_column :asots, :di_votes, :votes
  end

  def self.down
    rename_column :asots, :votes, :di_votes
    rename_column :asots, :url, :di_url
  end
end
