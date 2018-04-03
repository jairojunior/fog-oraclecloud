module Fog
  module OracleCloud
    class Java
      class Real
        def get_instance(service_name)
          response = request(
            expects: 200,
            method: 'GET',
            path: "/paas/service/jcs/api/v1.1/instances/#{@identity_domain}/#{service_name}"
          )
          response
        end
      end

      class Mock
        def get_instance(name)
          response = Excon::Response.new

          if instance = data[:instances][name]
            case instance['status']
            when 'Terminating'
              if Time.now - data[:deleted_at][name] >= Fog::Mock.delay
                data[:deleted_at].delete(name)
                data[:instances].delete(name)
              end
            when 'In Progress'
              if Time.now - data[:created_at][name] >= Fog::Mock.delay
                data[:instances][name]['status'] = 'Running'
                instance = data[:instances][name]
                data[:created_at].delete(name)
              end
            end
            response.status = 200
            response.body = instance
            response
          else
            raise Fog::OracleCloud::Java::NotFound, "Java #{name} does not exist"
          end
        end
      end
    end
  end
end
