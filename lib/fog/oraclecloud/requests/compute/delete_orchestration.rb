module Fog
  module Compute
    class OracleCloud
      class Real
        def delete_orchestration(name)
          unless name.start_with?('/Compute-')
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end
          request(
            method: 'DELETE',
            expects: 204,
            path: "/orchestration#{name}",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def delete_orchestration(name)
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''
          if data[:orchestrations][clean_name]
            data[:orchestrations].delete(clean_name)
            response.status = 204
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "Orchestration #{name} does not exist"
          end
        end
      end
    end
  end
end
