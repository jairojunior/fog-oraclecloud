module Fog
  module Compute
    class OracleCloud
      class Real
        def list_vnics
          response = request(
            expects: 200,
            method: 'GET',
            path: "/network/v1/vnic/Compute-#{@identity_domain}/#{@username}/"
          )
          response
        end
      end

      class Mock
        def list_vnics
          response = Excon::Response.new

          vnics = data[:vnics].values
          response.body = {
            'result' => vnics
          }
          response
        end
      end
    end
  end
end
