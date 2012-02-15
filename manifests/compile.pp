# The following part is optional! It just compiles and installs the chosen
# global ruby version to help on bootstrapping. To achieve this, it uses
# "ruby-build" utility.
define rbenv::compile($global_ruby="1.9.3-p0") {

  # Set Timeout to disabled cause we need a lot of time to compile.
  # Use HOME variable and define PATH correctly.
  exec { "install ruby ${global_ruby}":
    command     => "rbenv-install ${global_ruby}",
    timeout     => 0,
    user        => $user,
    group       => $user,
    cwd         => "/home/${user}",
    environment => [ "HOME=/home/${user} PATH=/usr/local/rbenv/bin"],
    onlyif      => ['[ -n "$(which rbenv-install)" ]', "[ ! -e /usr/local/rbenv/versions/${global_ruby} ]"],
    path        => ["/usr/local/rbenv/shims", "/usr/local/rbenv/bin", "/bin", "/usr/local/bin", "/usr/bin", "/usr/sbin"],
    require     => [Class['curl'], Exec['install ruby-build']],
  }

  exec { "rehash-rbenv":
    command     => "rbenv rehash",
    user        => $user,
    group       => $user,
    cwd         => "/home/${user}",
    environment => [ "HOME=/home/${user} PATH=/usr/local/rbenv/bin"],
    onlyif      => '[ -n "$(which rbenv)" ]',
    path        => ["/usr/local/rbenv/shims", "/usr/local/rbenv/bin", "/bin", "/usr/local/bin", "/usr/bin", "/usr/sbin"],
    require     => Exec["install ruby ${global_ruby}"],
  }

  exec { "set-global_ruby":
    command     => "rbenv global ${global_ruby}",
    user        => $user,
    group       => $user,
    cwd         => "/home/${user}",
    environment => [ "HOME=/home/${user} PATH=/usr/local/rbenv/bin"],
    onlyif      => '[ -n "$(which rbenv)" ]',
    unless      => "grep ${global_ruby} /home/${user}/.rbenv/version 2>/dev/null",
    path        => ["/usr/local/rbenv/shims", "/usr/local/rbenv/bin", "/bin", "/usr/local/bin", "/usr/bin", "/usr/sbin"],
    require     => [Exec["install ruby ${global_ruby}"], Exec['rehash-rbenv']],
  }
}
