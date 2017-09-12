pipeline {
  agent any
  stages {
    stage('Tests') {
      steps {
        node(label: 'docker-1.13') {
          sh '''echo "WARNING: Building eeacms/www is disabled due to Docker-in-Docker instability Pulling image from DockerHub"
echo "docker build -t eeacms/www ."
docker pull eeacms/www'''
          sh '''echo "WARNING: Building eeacms/www-devel is disabled due to Docker-in-Docker instability. Pulling image from DockerHub"
echo "docker build -t eeacms/www-devel devel"
docker pull eeacms/www-devel'''
          sh '''echo "INFO: Running tests"
docker run -i --net=host --name="$BUILD_TAG" -e EXCLUDE="$EXCLUDE" eeacms/www-devel /debug.sh tests'''
          sh '''echo "INFO: Cleanning up"
docker rm -v $BUILD_TAG'''
        }
        
      }
    }
  }
  environment {
    EXCLUDE = 'sparql-client Products.ZSPARQLMethod'
  }
}