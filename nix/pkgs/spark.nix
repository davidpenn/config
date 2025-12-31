{ pkgs }:

let
  sparkBase = pkgs.spark;
  hadoopVersion = "3.4.1";

  # Fetch hadoop-aws dependencies using Maven
  hadoopAwsDeps = pkgs.stdenv.mkDerivation {
    name = "hadoop-aws-deps";

    nativeBuildInputs = [ pkgs.maven ];

    buildCommand = ''
      # Set up Maven home directory
      export HOME=$TMPDIR
      export MAVEN_OPTS="-Dmaven.repo.local=$TMPDIR/.m2/repository"

      echo "Using Hadoop version: ${hadoopVersion}"

      # Create a minimal Maven project
      mkdir -p project
      cd project

      cat > pom.xml <<EOF
      <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
        <modelVersion>4.0.0</modelVersion>
        <groupId>com.example</groupId>
        <artifactId>spark-s3</artifactId>
        <packaging>jar</packaging>
        <version>1.0-SNAPSHOT</version>
        <name>spark-s3</name>
        <dependencies>
          <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-aws</artifactId>
            <version>${hadoopVersion}</version>
          </dependency>
          <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client-api</artifactId>
            <version>${hadoopVersion}</version>
          </dependency>
          <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client-runtime</artifactId>
            <version>${hadoopVersion}</version>
          </dependency>
        </dependencies>
      </project>
      EOF

      # Download dependencies
      mvn dependency:copy-dependencies -DoutputDirectory=deps

      # Copy to output
      mkdir -p $out
      cp deps/*.jar $out/
    '';
  };

  # Create a custom Spark package with S3 support
  sparkWithAWS = pkgs.stdenv.mkDerivation {
    name = "spark-with-s3-${sparkBase.version}";

    buildInputs = [ sparkBase pkgs.gnused ];

    buildCommand = ''
      # Copy the entire Spark distribution (dereference symlinks)
      cp -rL ${sparkBase} $out
      chmod -R u+w $out

      # Copy hadoop-aws dependencies
      cp -L ${hadoopAwsDeps}/*.jar $out/jars/

      # Create conf directory and spark-defaults.conf
      mkdir -p $out/conf
      cat > $out/conf/spark-defaults.conf <<EOF
      spark.hadoop.fs.s3a.aws.credentials.provider com.amazonaws.auth.EnvironmentVariableCredentialsProvider,com.amazonaws.auth.profile.ProfileCredentialsProvider,com.amazonaws.auth.InstanceProfileCredentialsProvider
      spark.hadoop.fs.s3a.impl org.apache.hadoop.fs.s3a.S3AFileSystem
      spark.hadoop.fs.s3.impl org.apache.hadoop.fs.s3a.S3AFileSystem
      EOF

      # Fix wrapper scripts to point to our modified Spark
      for wrapper in $out/bin/*; do
        if [ -f "$wrapper" ] && grep -q "${sparkBase}" "$wrapper" 2>/dev/null; then
          ${pkgs.gnused}/bin/sed -i "s|${sparkBase}|$out|g" "$wrapper"
          # Add SPARK_LOCAL_HOSTNAME export at the beginning of the script
          ${pkgs.gnused}/bin/sed -i '2i export SPARK_LOCAL_HOSTNAME=localhost' "$wrapper"
        fi
      done

      # Create a marker file
      echo "Spark with S3 support (hadoop-aws)" > $out/S3_ENABLED
    '';
  };

in
sparkWithAWS
