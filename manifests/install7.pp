#
#
define jdksolaris::install7 (
  $version      = '7u45',
  $full_version = 'jdk1.7.0_45',
  $x64          = true,
  $download_dir = '/install',
  $source_path  = "puppet:///modules/${module_name}/",
)
{

  case $::kernel {
    'SunOS': {
      $install_version  = 'solaris'
      $path             = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
    }
    default: {
      fail('Unrecognized operating system, please use it on a Solaris host')
    }
  }

  case $::architecture {
    'i86pc': {
      $type_x64 =  'x64'
      $type     = 'i586'
    }
    default: {
      $type_x64 = 'sparcv9'
      $type     = 'sparc'
    }
  }

  $jdkfile   = "jdk-${version}-${install_version}-${type}"
  $jdkfile64 = "jdk-${version}-${install_version}-${type_x64}"

  exec { "create ${$download_dir} directory":
    command => "mkdir -p ${$download_dir}",
    unless  => "test -d ${$download_dir}",
    path    => $path,
  }

  # check install folder
  if !defined(File[$download_dir]) {
    file { $download_dir:
      ensure  => directory,
      require => Exec["create ${$download_dir} directory"],
      replace => false,
      owner   => 'root',
      group   => 'sys',
      mode    => '0777',
    }
  }

  # check java install folder
  if ! defined(File['/usr/java']) {
    file { '/usr/java' :
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0777',
    }
  }

  # download jdk to client

  # download jdk64 to clien t
  if ($x64 == true) {
    file { "${download_dir}/${jdkfile64}.tar.gz":
      ensure  => file,
      source  => "${source_path}/${jdkfile64}.tar.gz",
      replace => false,
      owner   => 'root',
      group   => 'sys',
      mode    => '0777',
      require => File[$download_dir],
    }
    -> exec { "extract java ${jdkfile64}":
      cwd       => '/usr/java',
      command   => "gunzip -d ${download_dir}/${jdkfile64}.tar.gz ; tar -xvf ${download_dir}/${jdkfile64}.tar",
      creates   => "/usr/java/${full_version}/bin/amd64",
      path      => $path,
      logoutput => false,
      require   => File['/usr/java'],
      before    => File['/usr/bin/java'],
    }

  } else {
    file { "${download_dir}/${jdkfile}.tar.gz":
      ensure  => file,
      source  => "${source_path}/${jdkfile}.tar.gz",
      owner   => 'root',
      group   => 'sys',
      mode    => '0777',
      require => File[$download_dir],
    }
    -> exec { "extract java ${full_version}":
      cwd       => '/usr/java',
      command   => "gunzip -d ${download_dir}/${jdkfile}.tar.gz ; tar -xvf ${download_dir}/${jdkfile}.tar",
      creates   => "/usr/java/${full_version}",
      path      => $path,
      logoutput => false,
      require   => File['/usr/java'],
      before    => File['/usr/bin/java'],
    }
  }

  file { '/usr/bin/java':
    ensure => link,
    target => "/usr/java/${full_version}/bin/java",
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }
}
