class Netflow
  def self.parse_packet(data)
    begin
      header = Header.read(data)
      #puts "Version: #{header.version}"
      if header.version == 9
        flowset = Netflow9PDU.read(data)
      elsif header.version == 5
        flowset = Netflow5PDU.read(data)
        # puts flowset
      else
        raise "Unsupported Netflow version"
      end
    rescue
      raise "Error reading header."
    end
    flowset if flowset
  end
end
