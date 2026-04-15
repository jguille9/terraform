pipeline {
    // ⚠️ CRÍTIC: Ha d'executar-se a l'agent on Terraform està instal·lat
    // Si s'executa al Master, el comando 'terraform' no existirà i fallarà
    agent { label 'terraform' }

    // Variables d'entorn globals del Pipeline
    environment {
        // Directori on es troba el codi Terraform dins del repositori
        TF_DIR = 'infra'

        // Desactivem el color ANSI als outputs de Terraform
        // per millorar la llegibilitat als logs de Jenkins
        TF_CLI_ARGS = '-no-color'
    }

    stages {

        // ─────────────────────────────────────────────
        // STAGE 1: Obtenir el codi del repositori
        // ─────────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo "📥 Descarregant el codi des de Git..."

                // checkout scm usa automàticament la configuració SCM del Job
                // No cal especificar la URL ni la branca — Jenkins ja les sap
                checkout scm

                echo "✅ Codi descarregat correctament."

                // Mostrem informació del commit per traçabilitat
                sh '''
                    echo "📋 Informació del commit actual:"
                    echo "  Branca:  $(git rev-parse --abbrev-ref HEAD)"
                    echo "  Commit:  $(git rev-parse --short HEAD)"
                    echo "  Missatge: $(git log -1 --pretty=%B)"
                    echo "  Autor:   $(git log -1 --pretty=%an)"
                '''
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 2: Inicialitzar Terraform
        // ─────────────────────────────────────────────
        stage('Terraform Init') {
            steps {
                echo "🔧 Inicialitzant Terraform..."

                // Ens movem al directori on es troba el main.tf
                dir(env.TF_DIR) {
                    // terraform init descarrega el provider 'hashicorp/local'
                    // des del registre oficial de Terraform (registry.terraform.io)
                    // Crea el directori ocult .terraform amb els binaris del provider
                    sh 'terraform init'

                    // Verifiquem que la inicialització ha estat correcta
                    sh 'terraform version'
                }

                echo "✅ Terraform inicialitzat correctament."
            }
        }

        // ─────────────────────────────────────────────
        // STAGE 3: Generar el Pla d'Execució
        // ─────────────────────────────────────────────
        stage('Terraform Plan') {
            steps {
                echo "🔍 Generant pla d'execució de Terraform..."

                dir(env.TF_DIR) {

                    // Generem el pla i el guardem en un fitxer binari 'tfplan'
                    // L'opció -out és VITAL per garantir que l'apply posterior
                    // executi EXACTAMENT el que hem revisat aquí — ni més ni menys
                    sh 'terraform plan -out=tfplan'

                    echo "📄 Convertint el pla a format llegible per als logs..."

                    // Convertim el pla binari a text pla per a revisió humana
                    // -no-color evita caràcters especials d'ANSI als logs de Jenkins
                    sh 'terraform show -no-color tfplan | tee tfplan.txt'

                    // Guardem el pla en text com a artefacte del build
                    // Això permet revisar el pla des de la interfície de Jenkins
                    // sense haver d'entrar als logs complets
                    archiveArtifacts artifacts: 'tfplan.txt',
                                     fingerprint: true,
                                     allowEmptyArchive: false

                    echo "📦 Pla guardat com a artefacte del build."
                }

                echo "✅ Pla generat i arxivat correctament."
            }
        }

    }

    // ─────────────────────────────────────────────
    // POST: Accions finals independents del resultat
    // ─────────────────────────────────────────────
    post {
        success {
            echo """
            ✅ PIPELINE COMPLETAT AMB ÈXIT
            ════════════════════════════════
            El pla de Terraform s'ha generat correctament.
            Revisa l'artefacte 'tfplan.txt' per veure els canvis planificats.
            Quan estiguis llest, executa la segona part del Pipeline per aplicar-los.
            ════════════════════════════════
            """
        }
        failure {
            echo """
            ❌ EL PIPELINE HA FALLAT
            ════════════════════════════════
            Revisa els logs per identificar l'error.
            Errors habituals:
              - L'agent 'terraform' no està disponible o offline.
              - El fitxer main.tf conté errors de sintaxi.
              - El repositori Git no és accessible des de Jenkins.
              - El directori 'infra/' no existeix al repositori.
            ════════════════════════════════
            """
        }
        always {
            echo "🧹 Finalitzant el Pipeline. Workspace conservat per al stage Apply."
        }
    }
}