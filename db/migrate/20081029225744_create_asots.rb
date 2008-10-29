class CreateAsots < ActiveRecord::Migration
  def self.up
    create_table :asots do |t|
      t.integer :no
      t.text :di_url
      t.integer :di_votes

      t.timestamps
    end
  end

  def self.down
    drop_table :asots
  end
end
