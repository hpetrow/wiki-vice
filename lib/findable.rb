module Findable
  module InstanceMethods
    def get_geoip_location(author_collection)
      author_collection.collect do |aa| 
        begin
          regex = /\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}:\w{3,4}/
          if regex.match(aa.name)
            nil
          else 
            GeoIP.new('lib/assets/GeoIP.dat').country(aa.name)
          end
        rescue Exception => e
          puts e
        end
      end.compact
    end
  end

end