module Fog
  module Compute
    class OracleCloud
      class Real
        def start_orchestration(name)
          unless name.start_with?('/Compute-')
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end
          request(
            method: 'PUT',
            expects: 200,
            path: "/orchestration#{name}?action=start",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def start_orchestration(name)
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''

          if data[:orchestrations][clean_name]
            data[:orchestrations][clean_name]['status'] = 'running'
            instance = data[:orchestrations][clean_name]
            response.status = 200
            response.body = instance
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "Orchestration #{name} does not exist"
          end
        end
      end
    end
  end
end
