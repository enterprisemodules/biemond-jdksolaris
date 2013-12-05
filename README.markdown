# Solaris JAVA SE 7 puppet module
=================================

installs only the java tar.gz files


installs only the java tar.gz files
-----------------------------------

add the jdk-7u45-solaris-i586.tar.gz and / or jdk-7u45-solaris-x64.tar.gz (download these files from the Oracle website) to the files folder of this jdksolaris module

example usage
-------------

    jdksolaris::install7{'jdk1.7.0_45':
      version              => '7u45',
      fullVersion          => 'jdk1.7.0_45',
      x64                  => true,
      downloadDir          => '/data/install',
      sourcePath           => "/vagrant",
    }

or sourcePath => "puppet:///modules/jdksolaris/"

