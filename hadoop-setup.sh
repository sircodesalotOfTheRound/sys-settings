
HADOOP_VERSION=2.6.0
AS_USER=sircodesalot

function git_hadoop {
  git clone https://github.com/apache/hadoop
  cd hadoop
  git checkout branch-${HADOOP_VERSION}
  mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true
  cd ..
}

function wget_protoc_250 {
  wget http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz 
  tar xzvf protobuf-2.5.0.tar.gz
  cd  protobuf-2.5.0
  ./configure
  make
  sudo make install
  sudo ldconfig
  protoc --version
  cd ..
}

function git_hive {
  git clone git@github.com:apache/hive.git
  cd hive
  mvn clean install -Phadoop-2,dist -DskipTests -Dmaven.javadoc.skip=true
  cd ..
}

function remove_jline {
  # Jline causes problems with Hive CLI.
  # http://stackoverflow.com/questions/28997441/hive-startup-error-terminal-initialization-failed-falling-back-to-unsupporte
  rm hadoop/hadoop-dist/target/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/lib/jline-0.9.94.jar
}

function set_envrionment {
  export PATH=$PATH:/home/sircodesalot/Dev/Cloudera/hadoop/hadoop-dist/target/hadoop-2.6.0/bin:/home/sircodesalot/Dev/Cloudera/hbase/bin
  export HADOOP_HOME=/home/sircodesalot/Dev/Cloudera/hadoop/hadoop-dist/target/hadoop-2.6.0
  export HIVE_HOME=/home/sircodesalot/Dev/Cloudera/hive/packaging/target/apache-hive-1.2.0-SNAPSHOT-bin/apache-hive-1.2.0-SNAPSHOT-bin
}

function create_warehouse_folder {
  sudo mkdir -p /user/hive/warehouse
  sudo chown ${AS_USER} -R /user/hive
}

function post_install {
  remove_jline
  set_environment
  create_warehouse_folder
}

function hadoop_all {
  sudo true # Prompt for sudo password entry (needed later)
  wget_protoc_250
  git_hadoop
  git_hive
  
  # Post setup
  post_install
}
