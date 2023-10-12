require 'models/binary_models'
require 'parsers/parsers'
require 'date'

class NetflowCollector

  module Collector
    def post_init
      puts "Server listening."
    end
    def receive_data(data)
      puts "Datagram recieved."
      if data != nil
        begin
          flowset = Netflow.parse_packet(data)
          datetime = Time.at(flowset.unix_sec)
          flowset.records.each do |r|
            record = {
              datetime: datetime,
              srcaddr: [r.srcaddr].pack('N').unpack('CCCC').join('.'),
              dstaddr: [r.dstaddr].pack('N').unpack('CCCC').join('.'),
              packets: r.packets.to_i,
              bytes: r.octets.to_i,
              srcport: r.srcport.to_i,
              dstport: r.dstport.to_i,
              proto: r.proto.to_i
            }
            NetflowData.create(record)
          end
          p datetime
          # nfd = NetflowData.new
          # nfd.data.attach(io: StringIO.new(data), filename: "datagram_#{Time.now.strftime("%Y-%m-%d-%H-%M")}.dat")
          # nfd.save
        rescue
          puts "Error parsing packet"
        end
      end
    end
  end

  def self.start_collector(bind_ip = '0.0.0.0', bind_port = 2055)
    EventMachine::run do
      EventMachine::open_datagram_socket(bind_ip, bind_port, Collector)
    end
  end

end