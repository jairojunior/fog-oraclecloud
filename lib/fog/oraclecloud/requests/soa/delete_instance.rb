module Fog
  module OracleCloud
    class SOA
      class Real
        def delete_instance(service_name, dba_name, dba_password, options = {})
          body_data = {
            'dbaName'     => dba_name,
            'dbaPassword' => dba_password,
            'forceDelete' => options[:force_delete],
            'skipBackupOnTerminate' => options[:skip_backup]
          }

          body_data = body_data.reject { |_key, value| value.nil? }
          request(
            method: 'PUT',
            expects: 202,
            path: "/paas/service/soa/api/v1.1/instances/#{@identity_domain}/#{service_name}",
            body: Fog::JSON.encode(body_data)
          )
        end
      end

      class Mock
        def delete_instance(name, _dba_name, _dba_password, _options = {})
          response = Excon::Response.new
          data[:instances][name]['status'] = 'Terminating'
          data[:deleted_at][name] = Time.now
          response.status = 204
          response
        end
      end
    end
  end
end
