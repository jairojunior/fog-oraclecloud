module Fog
  module Compute
    class OracleCloud
      class Real
        def get_security_list(name)
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''

          response = request(
            expects: 200,
            method: 'GET',
            path: "/seclist/Compute-#{@identity_domain}/#{@username}/#{name}",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json',
              'Accept' => 'application/oracle-compute-v3+json'
            }
          )
          response
        end
      end

      class Mock
        def get_security_list(name)
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''

          if instance = data[:security_lists][clean_name]
            response.status = 200
            response.body = instance
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "Security List #{name} does not exist"
          end
        end
      end
    end
  end
end
