HADOOP_VERSION=2.6.0
PROTOCOL_BUFFER_VERSION=2.5.0
HIVE_VERSION=1.2.0
AS_USER=sircodesalot
CURRENT_WORKING_DIRECTORY=${CURRENT_WORKING_DIRECTORY}
 
function git_hadoop {
  git clone https://github.com/apache/hadoop
  cd hadoop
 
  git checkout branch-${HADOOP_VERSION}
  mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true
  cd ..
}
 
function wget_protoc_250 {
  # Download and untar
  wget http://protobuf.googlecode.com/files/protobuf-${PROTOCOL_BUFFER_VERSION}.tar.gz
  tar xzvf protobuf-${PROTOCOL_BUFFER_VERSION}.tar.gz
  
  # Make protocol buffers
  cd  protobuf-${PROTOCOL_BUFFER_VERSION}
    ./configure
    make
    sudo make install
    sudo ldconfig
    protoc --version
  cd ..
}
 
function git_hive {
  # Clone the repo
  git clone git@github.com:apache/hive.git
  
  # Maven install:
  cd hive
    mvn clean install -Phadoop-2,dist -DskipTests -Dmaven.javadoc.skip=true
 
    # Run datanucleus:enhance
    cd metastore; 
      mvn datanucleus:enhance; 
    cd ..;
  cd ..
}
 
function remove_jline {
  # Jline causes problems with Hive CLI.
  # http://stackoverflow.com/questions/28997441/hive-startup-error-terminal-initialization-failed-falling-back-to-unsupporte
  rm hadoop/hadoop-dist/target/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/lib/jline-0.9.94.jar
}
 
function set_environment {
  # Set environment variables:
  export PATH=$PATH:${CURRENT_WORKING_DIRECTORY}/hadoop/hadoop-dist/target/hadoop-${HADOOP_VERSION}/bin
  export HADOOP_HOME=${CURRENT_WORKING_DIRECTORY}/hadoop/hadoop-dist/target/hadoop-${HADOOP_VERSION}
  export HIVE_HOME=${CURRENT_WORKING_DIRECTORY}/hive/packaging/target/apache-hive-${HIVE_VERSION}-SNAPSHOT-bin/apache-hive-${HIVE_VERSION}-SNAPSHOT-bin
}
 
function create_warehouse_folder {
  # This is where hive stores its databases.
  sudo mkdir -p /user/hive/warehouse
  sudo chown ${AS_USER} -R /user/hive
}
 
function post_install {
  # Post install functions
  remove_jline
  set_environment
  create_warehouse_folder
}
 
function hadoop_all {
  # Install all hadoop components.
  sudo true # Prompt for sudo password entry so we don't have to do this later.
  wget_protoc_250
  git_hadoop
  git_hive
 
  # Post setup
  post_install
}
 
# Run the setup script
hadoop_all
