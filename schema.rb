ActiveRecord::Schema.define(version: 2021_04_29_143800) do
  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.bigint "pages"
  end
  
  create_table "restaurants", force: :cascade do |t|
    t.bigint "rating"
    t.string "name"
    t.string "opens_at"
    t.string "closes_at"
  end
end