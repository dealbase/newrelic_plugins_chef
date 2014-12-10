ey_cloud_report "newrelic-postgres-agent" do
  message "Setting up NewRelic postgres agent"
end

# verify ruby dependency
verify_ruby 'Postgres Plugin'

# check required attributes
verify_attributes do
  attributes [
                 'node[:newrelic][:postgres][:download_url]',
                 'node[:newrelic][:postgres][:install_path]',
                 'node[:newrelic][:postgres][:plugin_path]',
                 'node[:newrelic][:postgres][:version]',
                 'node[:environment][:framework_env]',
                 'node[:public_hostname]',
                 'node[:users]'
             ]
end

user = node[:users].first

install_plugin 'newrelic_postgres_plugin' do
  plugin_version   node[:newrelic][:postgres][:version]
  install_path     node[:newrelic][:postgres][:install_path]
  plugin_path      node[:newrelic][:postgres][:plugin_path]
  download_url     node[:newrelic][:postgres][:download_url]
  user             user[:username]
end

node[:engineyard][:environment][:apps].each do |app|

  app_name = app[:name]
  app_license_key do
    app app
  end
  license_key = node[:newrelic][app_name][:license_key]

  if license_key

    case node[:instance_role]
      when "solo", "db_master"

        # reload monit
        execute "restart-newrelic-postgres-agent-for-#{app_name}" do
          command "monit reload && sleep 1 && monit restart all -g #{app_name}_postgres_newrelic_agent"
          action :nothing
        end

        # newrelic template
        template "#{node[:newrelic][:postgres][:plugin_path]}/config/newrelic_plugin.yml" do
          source 'postgres/newrelic_plugin.yml.erb'
          action :create
          owner user[:username]
          group user[:username]
          #notifies :restart, "service[newrelic-memcached-ruby-plugin-#{app_name}]"
          notifies :run, resources(:execute => "restart-newrelic-postgres-agent-for-#{app_name}")
          variables({
                        :app_name => app_name,
                        :environment => node[:environment][:framework_env],
                        :license_key => license_key,
                        :host => node[:public_hostname],
                        :db_name => app[:database_name],
                        :username => user[:username],
                        :password => user[:password]
                    })
        end

        bundle_install do
          path node[:newrelic][:postgres][:plugin_path]
          user user[:username]
        end

        # monit
        template "/etc/monit.d/newrelic_postgres_agent_#{app_name}.monitrc" do
          mode 0644
          source "memcached_ruby/newrelic_postgres_agent.monitrc.erb"
          backup false
          variables({
                        :app_name => app_name,
                        :rails_env => node[:environment][:framework_env],
                        :plugin_path => node[:newrelic][:postgres][:plugin_path],
                        :memory_limit => 200 # MB
                    })
          notifies :run, resources(:execute => "restart-newrelic-postgres-agent-for-#{app_name}")
        end

      # install init.d script and start service
      # plugin_service "newrelic-postgres-plugin-#{app_name}" do
      #   daemon          './newrelic_postgres_agent'
      #   daemon_dir      node[:newrelic][:postgres][:plugin_path]
      #   plugin_name     'Postgres'
      #   plugin_version  node[:newrelic][:postgres][:version]
      #   user            user
      #   run_command     'bundle exec'
      # end
    end
  end
end