require 'hex_string'

class Netflow
  def self.parse_packet(data)
    #puts data.to_hex_string
    begin
      header = Header.read(data)
      puts "Version: #{header.version}"
      if header.version == 9
        flowset = Netflow9PDU.read(data)
      elsif header.version == 5
        flowset = Netflow5PDU.read(data)
        puts flowset.records
      else
        raise "Unsupported Netflow version"
      end
    rescue
      raise "Error reading header."
    end
  end
end
