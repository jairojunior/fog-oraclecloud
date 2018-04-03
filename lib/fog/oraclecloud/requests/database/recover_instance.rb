module Fog
  module OracleCloud
    class Database
      class Real
        def recover_instance(service_name, type = nil, value = nil)
          body_data = { 'latest' => true } if type == 'latest'
          body_data = { 'tag' => value } if type == 'tag'
          body_data = { 'timestamp' => value } if type == 'timestamp'
          body_data = { 'scn' => value } if type == 'scn'

          response = request(
            method: 'POST',
            expects: 202,
            path: "/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}/#{service_name}/backups/recovery",
            body: Fog::JSON.encode(body_data)
          )
          response.database_id = service_name
          response
        end
      end

      class Mock
        def recover_instance(service_name, type = nil, value = nil)
          response = Excon::Response.new

          unless data[:recoveries][service_name].is_a? Array
            data[:recoveries][service_name] = []
          end

          unless data[:created_at][:recoveries]
            data[:created_at][:recoveries] = {}
            data[:created_at][:recoveries][service_name] = []
          end

          # Find the backup first
          backups = data[:backups][service_name]
          backup = nil
          if type == 'tag'
            backup = backups.find { |b| b['dbTag'] = value }
          elsif type == 'timestamp'
            # Too hard to do this logic in mock. Just return the latest
            backup = backups.last
          elsif type.nil?
            # Default to searching for the latest
            backup = backups.last
          end
          if backup.nil?
            response.status = 500
          else
            if type == 'tag'
              data[:recoveries][service_name].push(
                'recoveryStartDate' => Time.now.strftime('%d-%b-%Y %H:%M:%S UTC'),
                'status' => 'IN PROGRESS',
                'dbTag' => value,
                'database_id' => service_name
              )
              data[:created_at][:recoveries][service_name].push(Time.now)
            elsif type == 'timestamp'
              data[:recoveries][service_name].push(
                'recoveryStartDate' => Time.now.strftime('%d-%b-%Y %H:%M:%S UTC'),
                'status' => 'IN PROGRESS',
                'timestamp' => value.strftime('%d-%b-%Y %H:%M:%S'),
                'database_id' => service_name
              )
              data[:created_at][:recoveries][service_name].push(Time.now)
            elsif type.nil?
              data[:recoveries][service_name].push(
                'recoveryStartDate' => Time.now.strftime('%d-%b-%Y %H:%M:%S UTC'),
                'status' => 'IN PROGRESS',
                'latest' => true,
                'database_id' => service_name
              )
              data[:created_at][:recoveries][service_name].push(Time.now)
            end
            response.status = 202
          end
          response
        end
      end
    end
  end
end
