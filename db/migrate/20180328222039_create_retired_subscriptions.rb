class CreateRetiredSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :retired_subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :feed

      t.timestamps
    end

    add_index :retired_subscriptions, [:user_id, :feed_id]
  end
end
