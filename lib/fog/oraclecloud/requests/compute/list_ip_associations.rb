module Fog
  module Compute
    class OracleCloud
      class Real
        def list_ip_associations
          response = request(
            expects: 200,
            method: 'GET',
            path: "/ip/association/Compute-#{@identity_domain}/"
          )
          response
        end
      end

      class Mock
        def list_ip_associations
          response = Excon::Response.new

          ips = data[:ip_associations].values
          response.body = {
            'result' => ips
          }
          response
        end
      end
    end
  end
end
