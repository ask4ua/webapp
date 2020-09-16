#!/bin/bash
set -o nounset
set -o errexit

NAMESPACE=$1
KUBE_CONFIG_PATH=$2

get_pvc_names() {
  PVC_NAMES=$(kubectl get pvc -n "${NAMESPACE}" --kubeconfig "${KUBE_CONFIG_PATH}" | tail -n +2 | cut -d' ' -f1)
  echo "${PVC_NAMES}"
}

RETRIES=10;
SLEEP_TIMER=0;
SLEEP_STEP=10;

echo "Waiting for all pods to be removed from namespace ${NAMESPACE}"
while [[ $RETRIES -ge 0 ]]
  do
    LEFT_PODS=$(kubectl get pods -n ${NAMESPACE} --kubeconfig ${KUBE_CONFIG_PATH} 2>&1)
    if [[ ${LEFT_PODS} == *'No resources found'* ]]
    then
        echo "No Pods left - continuing with pvc removal"
        break
    else
        echo "Remaining pods:"
        echo -e "\n${LEFT_PODS}\n";
    fi
    RETRIES=$(expr $RETRIES - 1);
    SLEEP_TIMER=$(expr $SLEEP_TIMER + $SLEEP_STEP);

    echo "Sleeping for ${SLEEP_TIMER} seconds. Retries left ${RETRIES}";
    sleep ${SLEEP_TIMER};
done;

# TODO: Remove sleep when SM-60794 is resolved
sleep 10
echo "Started deleting all pvcs in namespace ${NAMESPACE}"
for PVC in $(get_pvc_names)
do
  # TODO: Remove the if and echo and just leave the kubectl command when SM-60794 is resolved
  if ! `kubectl delete pvc ${PVC} -n "${NAMESPACE}" --kubeconfig "${KUBE_CONFIG_PATH}" >> /dev/null 2>&1`
  then
    echo "kubectl delete pvc ${PVC} : failed"
  fi
  sleep 4
done
echo "Completed deleting all pvcs in namespace ${NAMESPACE}"

echo "Started waiting for all pvcs to be removed from namespace ${NAMESPACE}"
MAX_ATTEMPTS=120
ATTEMPT_NUMBER=1
while true
do
  echo "Attempt ${ATTEMPT_NUMBER} of ${MAX_ATTEMPTS}."
  PVCS=$(kubectl get pvc  -n "${NAMESPACE}" --kubeconfig "${KUBE_CONFIG_PATH}" 2>&1)
  if ! `echo "$PVCS" | grep "No resources found" >> /dev/null 2>&1`
  then
    echo "$PVCS"
    if [[ $ATTEMPT_NUMBER -eq $MAX_ATTEMPTS ]]
    then
      echo "ERROR: The pvcs didn't get deleted after $MAX_ATTEMPTS attempts to check them"
      exit 1
    fi
    echo "Some PVCs above still remain, waiting 10 seconds before checking again"
    sleep 10
    ATTEMPT_NUMBER=$((ATTEMPT_NUMBER+1))
  else
    break
  fi
done
echo "Completed waiting for all pvcs to be removed from namespace ${NAMESPACE}"

echo "Started waiting for all pvs to be removed from namespace ${NAMESPACE}"
MAX_ATTEMPTS=120
ATTEMPT_NUMBER=1
while true
do
  echo "Attempt ${ATTEMPT_NUMBER} of ${MAX_ATTEMPTS}."
  PVS=$(kubectl get pv --kubeconfig "${KUBE_CONFIG_PATH}")
  if `echo "$PVS" | grep " ${NAMESPACE}/"`
  then
    echo "$PVS" | grep " ${NAMESPACE}/"
    if [[ $ATTEMPT_NUMBER -eq $MAX_ATTEMPTS ]]
    then
      echo "ERROR: The pvs didn't get deleted after $MAX_ATTEMPTS attempts to check them"
      exit 1
    fi
    echo "Some PVs above still remain, waiting 10 seconds before checking again"
    sleep 10
    ATTEMPT_NUMBER=$((ATTEMPT_NUMBER+1))
  else
    break
  fi
done
echo "Completed waiting for all pvs to be removed from namespace ${NAMESPACE}"
