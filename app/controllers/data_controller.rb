require 'date'

class DataController < ApplicationController
  def index
    @start_date = params[:start] && DateTime.parse("#{params[:start]} #{Time.zone}").utc || NetflowData.pick('MIN(datetime)')
    @end_date = params[:end] && DateTime.parse("#{params[:end]} #{Time.zone}").utc || NetflowData.pick('MAX(datetime)')

    range = @end_date.to_i - @start_date.to_i # Интервал в секундах
    group_by = range_to_group_by(range)

    @dg_records = netflow_records(@start_date, @end_date)
    first_date = @dg_records.pluck(:datetime).min

    @records = []
    @dg_records.each do |r|
      idx = (r.datetime.to_i - first_date.to_i) / group_by[2]
      @records[idx] ||= {datetime: r.datetime.localtime, download: nil, upload: nil}
      @records[idx][:download] = r.bytes * 8 / group_by[2] if r.direction == "download"
      @records[idx][:upload] = r.bytes * 8 / group_by[2] if r.direction == "upload"
      # proto - IP protocol type (for example, TCP = 6; UDP = 17)
    end
    @records.each_with_index do |r, idx|
      if r.nil?
        datetime = Time.at(first_date.to_i + idx * group_by[2]).localtime
        @records[idx] = {datetime: datetime, download: nil, upload: nil}
        next
      end
    end
    # @records.compact!
    render :json
  end

private

  def netflow_records(start_date, end_date)
    k,v, interval = range_to_group_by(end_date.to_i - start_date.to_i) # Example: [:minute, 1, 60]
    idx = [1.second, 1.minute, 1.hour, 1.day, 7.day, 1.month, 3.month, 1.year, 10.year, 100.year, 1000.year].select{|i| interval >= i.to_i}.size
    trunc = %w(second minute hour day week month quarter year decade century millennium)[idx]

    date_trunc = "date_trunc('#{trunc}', datetime)"
    interval = "(interval '#{v} #{k}')"
    part = "(extract(#{k} FROM datetime)::int / #{v})"
    range = "(datetime BETWEEN '#{start_date}' AND '#{end_date}')"
    upload = "(srcaddr::inet << '127.0.0.0/8' OR srcaddr::inet << '10.0.0.0/8' OR srcaddr::inet << '172.16.0.0/12' OR srcaddr::inet << '192.168.0.0/16') AND NOT (dstaddr::inet << '127.0.0.0/8' OR dstaddr::inet << '10.0.0.0/8' OR dstaddr::inet << '172.16.0.0/12' OR dstaddr::inet << '192.168.0.0/16')"
    download = "NOT (srcaddr::inet << '127.0.0.0/8' OR srcaddr::inet << '10.0.0.0/8' OR srcaddr::inet << '172.16.0.0/12' OR srcaddr::inet << '192.168.0.0/16') AND (dstaddr::inet << '127.0.0.0/8' OR dstaddr::inet << '10.0.0.0/8' OR dstaddr::inet << '172.16.0.0/12' OR dstaddr::inet << '192.168.0.0/16')"

    select_fields = "(#{date_trunc} + #{interval} * #{part}) as datetime, sum(packets) as packets, sum(bytes) as bytes"
    order_by = "datetime, direction"
    group_by = "#{date_trunc}, #{part}"

    upload = "SELECT #{select_fields}, 'upload' as direction FROM netflow_data WHERE #{upload} AND #{range}"
    download = "SELECT #{select_fields}, 'download' as direction FROM netflow_data WHERE #{download} AND #{range}"

    NetflowData.find_by_sql("(#{upload} GROUP BY #{group_by}) UNION (#{download} GROUP BY #{group_by}) ORDER BY #{order_by}")
  end

  def range_to_group_by(range)
    parts = [1.second, 2.second, 5.second, 10.second, 15.second, 20.second, 30.second, 1.minute, 2.minute, 5.minute, 10.minute, 15.minute, 20.minute, 30.minute, 1.hour, 2.hour, 3.hour, 4.hour, 6.hour, 12.hour, 1.day, 1.week, 1.month, 3.month, 6.month, 1.year]
    result = parts.select{|i| range / 20 <= i.to_i}.first
    # result = case range
    # when 0.second..1.minute
    #   1.second
    # when 1.minute..1.hour
    #   1.minute
    # when 1.hour..1.day
    #   # 1.hour
    #   15.minute
    # when 1.day..1.week
    #   1.day
    # when 1.week..1.month
    #   1.week
    # when 1.month..1.year
    #   1.month
    # else
    #   1.year
    # end
    result.parts.to_a.first + [result.to_i]
  end
end
