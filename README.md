# Kubernetes Resource Analyzer

Este projeto é um script em shell que analisa os workloads no Kubernetes que não possuem requests e limits de CPU e memória definidos. Ele gera um relatório em formato CSV com sugestões de requests com base no uso atual.

## Pré-requisitos

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/download/)
- [Metrics Server](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/#metrics-server) instalado no seu cluster Kubernetes
- Permissões para consultar a API do Kubernetes e executar comandos `kubectl top pod`
- Variável de ambiente `KUBECONFIG` configurada corretamente. Se não estiver definida, o script usará o arquivo de configuração padrão (`$HOME/.kube/config`)

## Instalação do Metrics Server

O Metrics Server é um agregador de dados de uso de recursos escalonável que é instalado por padrão em muitos clusters, ou pode ser instalado manualmente.

Para instalar o Metrics Server em seu cluster, você pode seguir os seguintes passos:

1. Instale o Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Agora o Metrics Server deve estar rodando em seu cluster.

## Uso

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/Kubernetes-Resource-Analyzer.git
cd Kubernetes-Resource-Analyzer
```

2. Torne o script executável:

```bash
chmod +x requests_limits.sh
```

3. Execute o script:

```bash
./requests_limits.sh
```

O script irá gerar um arquivo `workloads_without_requests.csv` com as sugestões de requests.

## Contribuição

Contribuições são bem-vindas. Sinta-se à vontade para abrir uma issue ou enviar um pull request.
