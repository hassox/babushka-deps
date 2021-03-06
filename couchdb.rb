src 'couchdb' do
  requires 'help2man',
           'erlang-dev', 'erlang-nox', 'libicu-dev', 'libmozjs-dev', 'libcurl4-openssl-dev'
  source 'git://git.apache.org/couchdb.git'
  preconfigure do
    shell './bootstrap'
  end
  install do
    shell 'make install', :sudo => true
  end
end

dep 'couchdb startup script' do
  requires 'couchdb', 'couchdb user'
  met? { shell("rcconf --list").val_for('couchdb') == 'on' }
  meet :on => :linux do
    sudo "ln -sf /usr/local/etc/init.d/couchdb /etc/init.d/couchdb"
    sudo "ln -sf /usr/local/etc/default/couchdb /etc/default/couchdb"
    sudo 'update-rc.d couchdb defaults'
  end
end

dep 'couchdb user' do
  set :username, 'couchdb'
  set :home_base, '/usr/local/var/run'
  requires 'user exists'
end

def couchdb_running?
  shell "netstat -an | grep -E '^tcp.*[.:]5984 +.*LISTEN'"
end

dep 'couchdb running' do
  requires 'couchdb startup script'
  met? {
    returning couchdb_running? do |result|
      result "There is #{result ? 'something' : 'nothing'} listening on #{result ? result.scan(/[0-9.*]+[.:]5984/).first : 'port 5984'}", :result => result
    end
  }
  meet :on => :linux do
    sudo '/etc/init.d/couchdb start'
  end
end

