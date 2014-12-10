default[:newrelic][:plugins][:install_path] = "/data/newrelic_plugins"

# aws cloudwatch plugin attributes
default[:newrelic][:aws_cloudwatch][:version] = "3.3.2"
default[:newrelic][:aws_cloudwatch][:download_url] = "https://github.com/newrelic-platform/newrelic_aws_cloudwatch_plugin/archive/#{node[:newrelic][:aws_cloudwatch][:version]}.tar.gz"
default[:newrelic][:aws_cloudwatch][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:aws_cloudwatch][:plugin_path]  = "#{node[:newrelic][:aws_cloudwatch][:install_path]}/newrelic_aws_cloudwatch_plugin"

# mysql plugin attributes
default[:newrelic][:mysql][:version] = "2.0.0"
default[:newrelic][:mysql][:user] = "root"                #mysql auth info is in a conf file controled by this user
default[:newrelic][:mysql][:download_url] = "https://raw.github.com/newrelic-platform/newrelic_mysql_java_plugin/master/dist/newrelic_mysql_plugin-#{node[:newrelic][:mysql][:version]}.tar.gz"
default[:newrelic][:mysql][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:mysql][:plugin_path] = "#{node[:newrelic][:mysql][:install_path]}/newrelic_mysql_plugin"
default[:newrelic][:mysql][:java_options] = '-Xmx128m'

# example plugin attributes
default[:newrelic][:example][:version] = "1.0.1"
default[:newrelic][:example][:download_url] = "https://github.com/newrelic-platform/newrelic_example_plugin/archive/release/#{node[:newrelic][:example][:version]}.tar.gz"
default[:newrelic][:example][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:example][:plugin_path] = "#{node[:newrelic][:example][:install_path]}/newrelic_example_plugin"

# memcached (ruby) plugin attributes
default[:newrelic][:memcached_ruby][:version] = "1.0.1"
default[:newrelic][:memcached_ruby][:download_url] = "https://github.com/newrelic-platform/newrelic_memcached_plugin/archive/release/#{node[:newrelic][:memcached_ruby][:version]}.tar.gz"
default[:newrelic][:memcached_ruby][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:memcached_ruby][:plugin_path] = "#{node[:newrelic][:memcached_ruby][:install_path]}/memcached_ruby"

# postgres plugin attributes
default[:newrelic][:postgres][:version] = "master"
default[:newrelic][:postgres][:download_url] = "https://github.com/GoBoundless/newrelic_postgres_plugin/archive/#{node[:newrelic][:postgres][:version]}.tar.gz"
default[:newrelic][:postgres][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:postgres][:plugin_path] = "#{node[:newrelic][:postgres][:install_path]}/postgres"

# sidekiq plugin attributes
default[:newrelic][:sidekiq][:version] = "1.1.0"
default[:newrelic][:sidekiq][:download_url] = "https://github.com/secondimpression/newrelic_sidekiq_agent/archive/v#{node[:newrelic][:sidekiq][:version]}.tar.gz"
default[:newrelic][:sidekiq][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:sidekiq][:plugin_path] = "#{node[:newrelic][:sidekiq][:install_path]}/sidekiq"
default[:newrelic][:sidekiq][:namespace] = "sq"

# wikipedia example ruby plugin attributes
default[:newrelic][:wikipedia_example_ruby][:version] = "1.0.3"
default[:newrelic][:wikipedia_example_ruby][:download_url] = "https://github.com/newrelic-platform/newrelic_wikipedia_plugin/archive/#{node[:newrelic][:wikipedia_example_ruby][:version]}.tar.gz"
default[:newrelic][:wikipedia_example_ruby][:install_path] = default[:newrelic][:plugins][:install_path]
default[:newrelic][:wikipedia_example_ruby][:plugin_path] = "#{node[:newrelic][:wikipedia_example_ruby][:install_path]}/newrelic_wikipedia_example_ruby_plugin"
