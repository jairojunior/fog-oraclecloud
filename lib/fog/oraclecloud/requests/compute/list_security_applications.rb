module Fog
  module Compute
    class OracleCloud
      class Real
        def list_security_applications(public_list = false)
          path = '/secapplication'
          path += if public_list
                    '/oracle/public/'
                  else
                    "/Compute-#{@identity_domain}/#{@username}/"
                  end
          response = request(
            expects: 200,
            method: 'GET',
            path: path
          )
          response
        end
      end
      class Mock
        def list_security_applications(public_list = false)
          response = Excon::Response.new
          check = if public_list then '/oracle/public'
                  else '/Compute-' end
          instances = data[:security_applications].values.select { |app| app['name'].include? check }
          response.body = {
            'result' => instances
          }
          response
        end
      end
    end
  end
end
