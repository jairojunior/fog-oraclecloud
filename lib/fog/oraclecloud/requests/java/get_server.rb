module Fog
  module OracleCloud
    class Java
      class Real
        def get_server(service_name, server_name)
          response = request(
            expects: 200,
            method: 'GET',
            path: "/paas/service/jcs/api/v1.1/instances/#{@identity_domain}/#{service_name}/servers/#{server_name}"
          )
          response
        end
      end

      class Mock
        def get_server(service_name, server_name)
          response = Excon::Response.new

          if server = data[:servers][service_name][server_name]
            case server[:status]
            when 'Maintenance'
              info = data[:maintenance_at][server_name]
              if Time.now - info['time'] >= Fog::Mock.delay
                data[:servers][service_name][server_name][:status] = 'Ready'
                data[:servers][service_name][server_name][info['attribute']] = info['value']
                data[:maintenance_at].delete(server_name)
              end
            end

            response.status = 200
            response.body = {
              'servers' => data[:servers][service_name].values
            }
            response
          else
            raise Fog::OracleCloud::Java::NotFound, "Java Server #{name} does not exist"
          end
        end
      end
    end
  end
end
