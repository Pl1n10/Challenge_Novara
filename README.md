# Challenge_Novara
ecco i files della mia challenge Configurazione del Cluster Kubernetes con Terraform e Ansible Panoramica

Questo progetto dimostra l'approccio Infrastructure as Code (IaC) utilizzando Terraform e Ansible per configurare un cluster Kubernetes. L'ambiente scelto per il deployment è AWS, specificatamente nella regione eu-west-3 (Parigi). Abbiamo scelto un AMI Ubuntu per la sua facilità di configurazione e vasto supporto. Configurazione dell'infrastruttura

Regione: AWS eu-west-3 (Parigi)
AMI: Ubuntu (scelto per la sua facilità di configurazione e ampio supporto)
Sicurezza: L'accesso alle istanze VM è strettamente controllato, permesso solo da un indirizzo IP pubblico specifico per una maggiore sicurezza. L'accesso SSH è gestito tramite autenticazione con chiave SSH.
Considerazioni Future: Prevediamo di esplorare l'uso di un host Bastion per una sicurezza e gestione migliorate.
Configurazione di Kubernetes

Provisioning: Le VM vengono provisionate tramite Terraform, che sfrutta la sua capacità di descrivere l'infrastruttura come codice.
Configurazione del Cluster: I playbook Ansible sono utilizzati per configurare i nodi di Kubernetes, aderendo al principio del deployment automatizzato.
Strumentazione: La creazione del cluster Kubernetes è facilitata da kubeadm, senza il bisogno di strumenti aggiuntivi.
Networking: Il networking del cluster è gestito tramite Calico.
Deploy dell'Applicazione

Una volta configurato il cluster Kubernetes, l'applicazione scelta per il deploy è Nextcloud. Sarà gestita e deployata utilizzando Helm, che semplifica il deploy e la gestione di applicazioni sui cluster Kubernetes.
