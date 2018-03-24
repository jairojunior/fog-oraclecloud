module Fog
  module Compute
    class OracleCloud
      class Real
      	def stop_instance (name)
          if !name.start_with?("/Compute-") then
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end
          
          body_data = { 'desired_state' => 'shutdown'}

          request(
            :method   => 'PUT',
            :expects  => 200,
            :path     => "/instance#{name}",
            :body     => Fog::JSON.encode(body_data),
            :headers  => {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
      	end
      end

      class Mock
        def stop_instance(name)
          Fog::Mock.not_implemented
        end
      end
    end
  end
end
