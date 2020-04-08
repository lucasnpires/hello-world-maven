/* def application = JOB_NAME.split('/')[1] // Espera-se que o job esteja dentro de uma pasta. */

// Podemos setar diversas variaveis nas branches que interessam e colocar variaveis default para todas as outras.
switch(BRANCH_NAME) {
    case 'develop':
        dockerBuild = true
    break

    case 'staging':
        dockerBuild = true
    break

    case 'master':
        dockerBuild = true
    break

    default:
        dockerBuild = false
    break
}

// O container do kaniko pega o jar gerado pelo container do maven e gera a imagem Docker.
podTemplate(
    containers: [
        containerTemplate(
            name: 'maven',
            image: 'maven:3-jdk-11',
            ttyEnabled: true,
            command: 'cat'
        ),

        containerTemplate(
            name: 'kaniko',
            image: 'gcr.io/kaniko-project/executor:debug-v0.16.0',
            ttyEnabled: true,
            command: '/busybox/cat'
        )
    ],

    /* Poderiamos ter volumes para cache, config-maps ou secrets.
    volumes: [
        secretVolume(
            mountPath: '/root/.aws',
            secretName: 'aws-secret'
        ),

        configMapVolume(
            mountPath: '/kaniko/.docker',
            configMapName: 'docker-config'

        ),

        persistentVolumeClaim(
            mountPath: '/root/.m2/repository',
            claimName: 'maven',
            readOnly: false
        )

    ]
    */
) {
    node(POD_LABEL) {
        stage('Git Checkout') {
            checkout scm
        }

        stage('Build Application') {
            // Apenas hello world, sem testes ou coisa assim, apenas para demonstrar o conceito.
            container('maven') {
                try {
                    sh 'mvn package'
                }

                catch(buildErr) {
                    currentBuild.result = 'FAILURE'
                    error('[FAILURE] Failed to build')
                }
            }
        }

        if (dockerBuild == true) {
            stage('Build Docker Image') {
                /*
                    Nao estou colocando tags e estou dizendo para nao fazer push.
                    O kaniko faz push automaticamente para o registry por default,
                    mas estou forcando para so gerar a imagem e nao fazer mais nada.
                */
                container('kaniko') {
                    try {
                        sh """
                            /kaniko/executor \
                                -f `pwd`/Dockerfile \
                                -c `pwd` \
                                --no-push
                        """
                    }

                    catch(dockerErr) {
                        currentBuild.result = 'FAILURE'
                        error('[FAILURE] Failed to create Docker image')
                    }
                }
            }
        }
    }
}
