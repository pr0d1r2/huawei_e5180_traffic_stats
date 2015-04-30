require 'huawei_e5180_api'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'huawei_e5180_stats.db'
)

class CreateStatsTable < ActiveRecord::Migration
  def up
    create_table :stats do |t|
      t.integer :current_connect_time, limit: 8
      t.integer :current_upload, limit: 8
      t.integer :current_download, limit: 8
      t.integer :current_download_rate, limit: 8
      t.integer :current_upload_rate, limit: 8
      t.integer :total_upload, limit: 8
      t.integer :total_download, limit: 8
      t.integer :total_connect_time, limit: 8
      t.timestamps
    end
  end

  def down
    drop_table :stats
  end
end

begin
  CreateStatsTable.migrate(:up)
rescue
end

agent = HuaweiE5180Api.new

class Stat < ActiveRecord::Base
  validates :current_connect_time,
            :current_upload,
            :current_download,
            :current_download_rate,
            :current_upload_rate,
            :total_upload,
            :total_download,
            :total_connect_time, numericality: true
end

while true
  stats = agent.traffic_statistics
  stat = Stat.create!(
    current_connect_time: stats["CurrentConnectTime"],
    current_upload: stats["CurrentUpload"],
    current_download: stats["CurrentDownload"],
    current_download_rate: stats["CurrentDownloadRate"],
    current_upload_rate: stats["CurrentUploadRate"],
    total_upload: stats["TotalUpload"],
    total_download: stats["TotalDownload"],
    total_connect_time: stats["TotalConnectTime"]
  )
  puts stat.inspect
  sleep 5
end
