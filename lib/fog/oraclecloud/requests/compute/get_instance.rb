module Fog
  module Compute
    class OracleCloud
      class Real
        def get_instance(name)
          unless name.start_with?('/Compute-')
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end
          response = request(
            expects: 200,
            method: 'GET',
            path: "/instance#{name}",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json',
              'Accept' => 'application/oracle-compute-v3+json'
            }
          )
          response
        end
      end

      class Mock
        def get_instance(name)
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''

          if instance = data[:instances][clean_name]
            if instance['state'] == 'stopping'
              if Time.now - data[:deleted_at][clean_name] >= Fog::Mock.delay
                data[:deleted_at].delete(clean_name)
                data[:instances].delete(clean_name)
              end
            end
            response.status = 200
            response.body = instance
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "Instance #{name} does not exist"
          end
        end
      end
    end
  end
end
