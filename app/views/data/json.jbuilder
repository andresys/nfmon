json.start @start_date.localtime
json.end @end_date.localtime
json.count @records.count
json.records @dg_records #do |record|
  # json.datetime record[:datetime]
  # json.records record[:records] do |record|
    # json.srcaddr [record[:srcaddr]].pack('N').unpack('CCCC').join('.')
    # json.dstaddr [record[:dstaddr]].pack('N').unpack('CCCC').join('.')
    # json.packets record[:packets].to_i
    # json.srcport record[:srcport].to_i
    # json.dstport record[:dstport].to_i
    # json.proto record[:proto].to_i
  # end
#end
json.data do
  json.labels @records.map{|r| r[:datetime].strftime("%T")}
  json.datasets do
    json.download @records.map{|r| r[:download] }
    json.upload @records.map{|r| r[:upload] }
  end
end