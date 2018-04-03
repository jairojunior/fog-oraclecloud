module Fog
  module Compute
    class OracleCloud
      class Real
        def list_security_rules
          response = request(
            expects: 200,
            method: 'GET',
            path: "/secrule/Compute-#{@identity_domain}/#{@username}/"
          )
          response
        end
      end

      class Mock
        def list_security_rules; end
      end
    end
  end
end
