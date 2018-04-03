module Fog
  module OracleCloud
    class Database
      class Real
        def create_instance(config, options)
          parameters = options.select { |key, _value| %i[admin_password backup_destination charset cloud_storage_container cloud_storage_pwd cloud_storage_user cloud_storage_if_missing disaster_recovery failover_database golden_gate is_rac ncharset pdb_name sid timezone usable_storage create_storage_container_if_missing].include?(key) }
          params = {
            'type' => 'db'
          }
          parameters.each do |key, value|
            next if value.nil?
            if key == :cloud_storage_container
              unless value.start_with?('Storage-')
                value = "Storage-#{@identity_domain}/#{value}"
              end
            end
            new_key = key.to_s.split('_').collect(&:capitalize).join
            new_key = new_key[0, 1].downcase + new_key[1..-1]
            params[new_key] = value
          end
          body_data = {
            'serviceName'         => config[:service_name],
            'version'             => config[:version],
            'level'               => config[:level],
            'edition'             => config[:edition],
            'subscriptionType'    => config[:subscription_type],
            'description'         => config[:description],
            'shape'               => config[:shape],
            'vmPublicKeyText'     => config[:ssh_key],
            'parameters'          => [params]
          }
          body_data = body_data.reject { |_key, value| value.nil? }

          request(
            method: 'POST',
            expects: 202,
            path: "/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}",
            body: Fog::JSON.encode(body_data),
            #:headers  => {
            # 'Content-Type'=>'application/vnd.com.oracle.oracloud.provisioning.Service+json'
            # }
          )
        end
      end

      class Mock
        def create_instance(config, options)
          response = Excon::Response.new
          job_id = rand(10_000).to_s
          data = {
            'serviceName' => config[:service_name],
            'shape' => config[:shape],
            'edition' => config[:edition],
            'version' => config[:version],
            'status' => 'Starting Provisioning', # Not a valid status, but we use it to simulate the time that the Oracle Cloud takes to add this to the list of instances
            'charset' => 'AL32UTF8',
            'ncharset' => 'AL16UTF16',
            'pdbName' => 'pdb1', # Note this is only valid for 12c instances. Too hard to fix for mocking
            'timezone' => 'UTC',
            'creation_job_id' => job_id,
            'totalSharedStorage' => options[:usable_storage],
            'domainName' => @identity_domain,
            'creation_date' => Time.now.strftime('%Y-%b-%dT%H:%M:%S'),
            'serviceType' => 'DBaaS',
            'creator' => @username
          }
                 .merge(config.select { |key, _value| %i[description level subscription_type].include?(key) })
                 .merge(options.select { |key, _value| %i[backup_destination failover_database cloud_storage_container is_rac ncharset pdb_name sid timezone].include?(key) })

          self.data[:instances][config[:service_name]] = data
          self.data[:created_at][config[:service_name]] = Time.now

          # Also create some compute nodes
          node = {
            'status' => 'Running',
            'creation_job_id' => '5495118',
            'creation_time' => 'Tue Jun 28 23:52:45 UTC 2016',
            'created_by' => 'dbaasadmin',
            'shape' => 'oc4',
            'sid' => 'ORCL1',
            'pdbName' => 'PDB1',
            'listenerPort' => 1521,
            'connect_descriptor' => '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=db12c-xp-rac2)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=db12c-xp-rac1)(PORT=1521))(LOAD_BALANCE=ON)(FAILOVER=ON))(CONNECT_DATA=(SERVICE_NAME=PDB1.usexample.oraclecloud.internal)))',
            'connect_descriptor_with_public_ip' => '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=129.144.23.176)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=129.144.23.112)(PORT=1521))(LOAD_BALANCE=ON)(FAILOVER=ON))(CONNECT_DATA=(SERVICE_NAME=PDB1.usexample.oraclecloud.internal)))',
            'initialPrimary' => true,
            'storageAllocated' => 97_280,
            'reservedIP' => '129.144.23.112',
            'hostname' => 'db12c-xp-rac1'
          }
          self.data[:servers][config[:service_name]] = [node]

          # And some access rules
          if self.data[:access_rules][config[:service_name]].nil? then self.data[:access_rules][config[:service_name]] = [] end
          self.data[:access_rules][config[:service_name]] << {
            'ruleName' => 'ora_p2_ssh',
            'destination' => 'DB',
            'ports' => 22,
            'source' => 'PUBLIC-INTERNET',
            'status' => 'enabled',
            'database_id' => config[:service_name]
          }

          response.headers['Location'] = "https://dbaas.oraclecloud.com:443/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}/status/create/job/#{job_id}"
          response.status = 202
          response
        end
      end
    end
  end
end
