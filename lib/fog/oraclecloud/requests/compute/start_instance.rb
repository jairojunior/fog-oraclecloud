module Fog
  module Compute
    class OracleCloud
      class Real
        def start_instance(name)
          unless name.start_with?('/Compute-')
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end

          body_data = { 'desired_state' => 'running' }

          request(
            method: 'PUT',
            expects: 200,
            path: "/instance#{name}",
            body: Fog::JSON.encode(body_data),
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def start_instance(_name)
          Fog::Mock.not_implemented
        end
      end
    end
  end
end
