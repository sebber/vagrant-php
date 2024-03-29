class apache 
{      
    package 
    { 
        "apache2":
            ensure  => present,
            require => Exec['apt-get update']
    }
    
    service 
    { 
        "apache2":
            ensure      => running,
            enable      => true,
            require     => Package['apache2'],
            subscribe   => [
                File["/etc/apache2/mods-enabled/rewrite.load"],
                File["/etc/apache2/sites-available/default"],
                File["/etc/apache2/conf.d/phpmyadmin.conf"]
            ],
    }

    file 
    { 
        "/etc/apache2/mods-enabled/rewrite.load":
            ensure  => link,
            target  => "/etc/apache2/mods-available/rewrite.load",
            require => Package['apache2'],
    }

    file 
    { 
        "/etc/apache2/sites-available/default":
            ensure  => present,
            owner   => root,
            group   => root,
            content => template('apache/vhost.erb'),
            require => Package['apache2'],
    }

    file { "/var/www":
      ensure  => "link",
      target  => "/vagrant/public_html",
      require => Package["apache2"],
      notify  => Service["apache2"],
      force   => true,
    }


    exec 
    { 
        'echo "ServerName localhost" | sudo tee /etc/apache2/conf.d/fqdn':
            require => Package['apache2'],
    }
}