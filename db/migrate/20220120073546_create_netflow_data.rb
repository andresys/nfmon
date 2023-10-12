class CreateNetflowData < ActiveRecord::Migration[6.1]
  def change
    create_table :netflow_data do |t|
      t.datetime "datetime"
      t.string "srcaddr"
      t.string "dstaddr"
      t.integer "packets"
      t.integer "bytes"
      t.integer "srcport"
      t.integer "dstport"
      t.integer "proto"

      t.timestamps
    end
  end
end
