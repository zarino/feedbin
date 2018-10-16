class AddStatusToFeeds < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    add_column :feeds, :status, :integer
    change_column_default(:feeds, :status, 0)
    add_index :feeds, :status, algorithm: :concurrently

    UpdateDefaultColumn.perform_async({
      "klass" => Feed.to_s,
      "column" => "status",
      "default" => 0,
      "schedule" => true,
    })
  end

  def down
    remove_column :feeds, :status
  end
end
