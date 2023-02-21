#!/bin/bash
c=$(cat hosts | wc -l)

if [[ $c != 3 ]]; then
    kubectl get svc -n {{SW}} | awk 'NR==2{print $4}' >> hosts
else
    echo "Nada a preencher"
fi

