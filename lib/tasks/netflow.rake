require 'rake'

namespace :netflow do
  desc "TODO"
  task run: :environment do
    puts "Run Netflow collector"

    require 'netflow_collector'
    # ['models/binary_models','parsers/parsers','storage/storage', 'netflow_collector'].each do |file|
    #   require file
    # end

    NetflowCollector.start_collector
  end
end