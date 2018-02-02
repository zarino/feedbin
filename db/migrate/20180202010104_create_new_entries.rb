class CreateNewEntries < ActiveRecord::Migration[5.1]
  def change
    create_table "new_entries", id: :bigserial, force: :cascade do |t|
      t.integer "feed_id", null: false
      t.bigint "thread_id"
      t.text "title"
      t.text "url"
      t.text "author"
      t.text "entry_id"
      t.text "summary"
      t.string "public_id", limit: 255, null: false
      t.json "data"
      t.json "original"
      t.json "image"
      t.text "source"
      t.text "content"

      t.integer "recently_played_entries_count", default: 0, null: false
      t.integer "starred_entries_count", default: 0, null: false

      t.datetime "updated"
      t.datetime "published", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index :new_entries, :feed_id
    add_index :new_entries, :public_id, unique: true
    add_index :new_entries, :thread_id, where: "(thread_id IS NOT NULL)"
  end
end
