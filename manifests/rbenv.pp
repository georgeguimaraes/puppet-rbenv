class rbenv::install {
  # STEP 1
  exec { "checkout rbenv":
    command => "git clone git://github.com/sstephenson/rbenv.git rbenv",
    user    => "root",
    group   => "root",
    cwd     => "/usr/local",
    creates => "/usr/local/rbenv",
    path    => ["/usr/bin", "/usr/sbin"],
    timeout => 100,
    require => Class['git'],
  }

  # STEP 2
  exec { "configure rbenv path":
    command => 'echo "export PATH=/usr/local/rbenv/bin:\$PATH" >> .bashrc',
    user    => $rbenv::user,
    group   => $rbenv::user,
    cwd     => "/home/${rbenv::user}",
    onlyif  => "[ -f /home/${rbenv::user}/.bashrc ]", 
    unless  => "grep .rbenv /home/${rbenv::user}/.bashrc 2>/dev/null",
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # STEP 3
  exec { "configure rbenv init":
    command => 'echo "eval \"\$(rbenv init -)\"" >> .bashrc',
    user    => $rbenv::user,
    group   => $rbenv::user,
    cwd     => "/home/${rbenv::user}",
    onlyif  => "[ -f /home/${rbenv::user}/.bashrc ]", 
    unless  => "grep '.rbenv init -' /home/${rbenv::user}/.bashrc 2>/dev/null",
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  # STEP 4
  exec { "checkout ruby-build":
    command => "git clone git://github.com/sstephenson/ruby-build.git",
    user    => "root",
    group   => "root",
    cwd     => "/usr/local",
    creates => "/usr/local/ruby-build",
    path    => ["/usr/bin", "/usr/sbin"],
    timeout => 100,
    require => Class['git'],
  }

  # STEP 5
  exec { "install ruby-build":
    command => "sh install.sh",
    user    => "root",
    group   => "root",
    cwd     => "/usr/local/ruby-build",
    onlyif  => '[ -z "$(which ruby-build)" ]',
    path    => ["/bin", "/usr/local/bin", "/usr/bin", "/usr/sbin"],
    require => Exec['checkout ruby-build'],
  }

  # STEP 6
  file { "/usr/local/rbenv":
    owner => $rbenv::user,
    group => 'deploy',
    ensure => 'directory',
    recurse => true,
    require => Exec['install ruby-build']
  }

  file { "/usr/local/ruby-build":
    owner => 'deploy',
    group => 'deploy',
    ensure => 'directory',
    recurse => true,
    require => Exec['install ruby-build']
  }
}
