#!/bin/bash
c=$(cat hosts | wc -l)
k=$(kubectl get svc -n {{SW}} | awk 'NR==2{print $4}')
gf=$(cat hosts | grep -v "hosts")

if [ $c != 3 ] && [ $k != $gf ]; then
    kubectl get svc -n {{SW}} | awk 'NR==2{print $4}' >> hosts
else
    echo "Nada a preencher"
fi

