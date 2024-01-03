#!/bin/bash

# Obtém informações do kubeconfig
kubeconfig_path="${KUBECONFIG:-$HOME/.kube/config}"
current_context=$(kubectl config current-context)
cluster_name=$(kubectl config view --minify --output 'jsonpath={.contexts[?(@.name == "'"${current_context}"'")].context.cluster}')
api_server=$(kubectl config view --minify --output "jsonpath={.clusters[?(@.name == "'"${cluster_name}"'")].cluster.server}")
user_name=$(kubectl config view --minify --output 'jsonpath={.contexts[?(@.name == "'"${current_context}"'")].context.user}')
escaped_user_name=$(echo $user_name | sed 's/"/\\"/g')
token=$(kubectl config view --minify --output "jsonpath={.users[?(@.name == "'"${escaped_user_name}"'")].user.token}")


# Inicializa a variável que armazenará as sugestões
suggestions="Namespace,Workload Type,Workload,Suggested CPU Request,Suggested Memory Request\n"

# Obtém todas as namespaces
namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Define os tipos de workloads a serem verificados
workload_types=("cronjobs" "daemonsets" "deployments" "jobs" "statefulsets" "pods")

# Loop através das namespaces
for namespace in $namespaces; do
    # Loop através dos tipos de workloads
    for workload_type in "${workload_types[@]}"; do
        # Obtém todos os workloads do tipo atual na namespace
        workloads=$(kubectl get $workload_type -n $namespace -o jsonpath='{.items[*].metadata.name}')

        # Verifica se existem workloads na namespace
        if [ -z "$workloads" ]; then
            continue
        fi

        # Loop através dos workloads
        for workload in $workloads; do
            # Obtém as informações do workload
            workload_info=$(kubectl get $workload_type $workload -n $namespace -o json)

            # Extrai requests e limits se o tipo de workload não é um pod
            if [ "$workload_type" != "pods" ]; then
                containers=$(echo $workload_info | jq -r '.spec.template.spec.containers')
                if [ "$containers" != "null" ]; then
                    requests=$(echo $containers | jq -r '.[].resources.requests')
                    limits=$(echo $containers | jq -r '.[].resources.limits')

                    # Se requests estão definidos, imprime a informação na tela
                    if [ "$requests" != "null" ]; then
                        echo "Namespace: $namespace, Workload Type: $workload_type, Workload: $workload, Requests and Limits are configured"
                    fi
                fi
            fi

            # Se requests não estão definidos e o tipo de workload não é um pod, sugere valores com base nas métricas atuais do pod
            if [ "$requests" == "null" ] && [ "$workload_type" != "pods" ]; then
                pods=$(kubectl get pods -n $namespace -l app=$workload -o jsonpath='{.items[*].metadata.name}')
                for pod in $pods; do
                    metrics=$(kubectl top pod $pod -n $namespace --no-headers)
                    cpu=$(echo $metrics | awk '{print $2}')
                    memory=$(echo $metrics | awk '{print $3}')
                    suggestions+="$namespace,$workload_type,$workload,$cpu,$memory\n"
                done
            fi
        done
    done
done

# Cria o arquivo CSV com as sugestões
echo -e $suggestions > workloads_without_requests.csv
