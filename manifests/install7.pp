#
#
define jdksolaris::install7 (
  $version              = '7u45',
  $fullVersion          = 'jdk1.7.0_45',
  $x64                  = true,
  $downloadDir          = '/install',
  $sourcePath           = "puppet:///modules/${module_name}/",
)
{

  case $::kernel {
    'SunOS': {
      $installVersion   = 'solaris'
      $path             = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
    }
    'default': {
      fail('Unrecognized operating system, please use it on a Solaris host')
    }
  }

  case $::architecture {
    'i86pc': {
      $type_x64 =  'x64'
      $type     = 'i586'
    }
    'default': {
      $type_x64 = 'sparcv9'
      $type     = 'sparc'
    }
  }

  $jdkfile   = "jdk-${version}-${installVersion}-${type}"
  $jdkfile64 = "jdk-${version}-${installVersion}-${type_x64}"

  exec { "create ${$downloadDir} directory":
    command => "mkdir -p ${$downloadDir}",
    unless  => "test -d ${$downloadDir}",
    path    => $path,
  }

  # check install folder
  if !defined(File[$downloadDir]) {
    file { $downloadDir:
      ensure  => directory,
      require => Exec["create ${$downloadDir} directory"],
      replace => false,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
    }
  }

  # check java install folder
  if ! defined(File['/usr/jdk']) {
    file { '/usr/jdk' :
      ensure  => directory,
      replace => false,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
    }
  }

  # download jdk to client
  file { "${downloadDir}/${jdkfile}.tar.gz":
    ensure  => file,
    source  => "${sourcePath}/${jdkfile}.tar.gz",
    require => File[$downloadDir],
    replace => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
  }

  # download jdk64 to client
  if ($x64 == true) {
    file { "${downloadDir}/${jdkfile64}.tar.gz":
      ensure  => file,
      source  => "${sourcePath}/${jdkfile64}.tar.gz",
      require => File[$downloadDir],
      replace => false,
      owner   => 'root',
      group   => 'root',
      mode    => '0777',
    }
  }

  # extract gz file in /usr/jdk
  exec { "extract java ${fullVersion}":
    cwd       => '/usr/jdk',
    command   => "gunzip -d ${downloadDir}/${jdkfile}.tar.gz ; tar -xvf ${downloadDir}/${jdkfile}.tar",
    creates   => "/usr/jdk/${fullVersion}",
    require   => File['/usr/jdk',"${downloadDir}/${jdkfile}.tar.gz"],
    path      => $path,
    logoutput => false,
  }

  # extract x64 gz file in /usr/jdk
  if ($x64 == true) {
    exec { "extract java ${jdkfile64}":
      cwd       => '/usr/jdk',
      command   => "gunzip -d ${downloadDir}/${jdkfile64}.tar.gz ; tar -xvf ${downloadDir}/${jdkfile64}.tar",
      creates   => "/usr/jdk/${fullVersion}/bin/amd64",
      require   => [File['/usr/jdk',"${downloadDir}/${jdkfile64}.tar.gz"],
                    Exec["extract java ${fullVersion}"],],
      path      => $path,
      logoutput => false,
    }
  }

  # java link to latest
  file { '/usr/java':
    ensure  => link,
    target  => "/usr/jdk/${fullVersion}/bin/java",
    require => Exec["extract java ${fullVersion}"],
    replace => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
  }
}
