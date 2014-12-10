ey_cloud_report "newrelic-memcached-agent" do
  message "Setting up NewRelic memcached agent"
end

# verify ruby dependency
verify_ruby 'Memcached - Ruby Plugin'

# check required attributes
verify_attributes do
  attributes [
    'node[:newrelic][:memcached_ruby][:download_url]',
    'node[:newrelic][:memcached_ruby][:install_path]',
    'node[:newrelic][:memcached_ruby][:plugin_path]',
    'node[:newrelic][:memcached_ruby][:version]',
    'node[:environment][:framework_env]'
  ]
end

user = node[:users].first[:username]

install_plugin 'newrelic_memcached_ruby_plugin' do
  plugin_version   node[:newrelic][:memcached_ruby][:version]
  install_path     node[:newrelic][:memcached_ruby][:install_path]
  plugin_path      node[:newrelic][:memcached_ruby][:plugin_path]
  download_url     node[:newrelic][:memcached_ruby][:download_url] 
  user             user
end

node[:engineyard][:environment][:apps].each do |app|

  app_name = app[:name]
  app_license_key do
    app app
  end
  license_key = node[:newrelic][app_name][:license_key]

  if license_key && node[:members] && node[:members].any?

    case node[:instance_role]
      when "solo", "app_master"

        # reload monit
        execute "restart-newrelic-memcached-agent-for-#{app_name}" do
          command "monit reload && sleep 1 && monit restart all -g #{app_name}_memcached_newrelic_agent"
          action :nothing
        end

        # newrelic template
        template "#{node[:newrelic][:memcached_ruby][:plugin_path]}/config/newrelic_plugin.yml" do
          source 'memcached_ruby/newrelic_plugin.yml.erb'
          action :create
          owner user
          group user
          #notifies :restart, "service[newrelic-memcached-ruby-plugin-#{app_name}]"
          notifies :run, resources(:execute => "restart-newrelic-memcached-agent-for-#{app_name}")
          variables({
                        :app_name => app_name,
                        :environment => node[:environment][:framework_env],
                        :license_key => license_key,
                        :server_names => node[:members]
                    })
        end

        bundle_install do
          path node[:newrelic][:memcached_ruby][:plugin_path]
          user user
        end

        # monit
        template "/etc/monit.d/newrelic_memcached_agent_#{app_name}.monitrc" do
          mode 0644
          source "memcached_ruby/newrelic_memcached_agent.monitrc.erb"
          backup false
          variables({
                        :app_name => app_name,
                        :rails_env => node[:environment][:framework_env],
                        :plugin_path => node[:newrelic][:memcached_ruby][:plugin_path],
                        :memory_limit => 200 # MB
                    })
          notifies :run, resources(:execute => "restart-newrelic-memcached-agent-for-#{app_name}")
        end

        # install init.d script and start service
        # plugin_service "newrelic-memcached-ruby-plugin-#{app_name}" do
        #   daemon          './newrelic_memcached_agent'
        #   daemon_dir      node[:newrelic][:memcached_ruby][:plugin_path]
        #   plugin_name     'Memcached - Ruby'
        #   plugin_version  node[:newrelic][:memcached_ruby][:version]
        #   user            user
        #   run_command     'bundle exec'
        # end
    end
  end
end