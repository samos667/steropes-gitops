# Bootstrap Steropes

Don't forget to populate secret.yaml

```
proxmox_password:
proxmox_endpoint:
mac_address:
```

And inventory.yaml

```
# From kube/clusters/steropes/deploy/ansible

ansible-playbook playbook.yaml ; cd talos
./talhelper genconfig
talosctl apply-config --insecure -n fifi.steropes.home.lab --file clusterconfig/steropes-fifi.steropes.home.lab.yaml
talosctl -e fifi.steropes.home.lab -n cp1-steropes.home.lab --talosconfig=./clusterconfig/talosconfig bootstrap
talosctl -e fifi.steropes.home.lab -n cp1-steropes.home.lab --talosconfig=./clusterconfig/talosconfig kubeconfig ~/.kube/steropes.yaml
```

```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

(
helm install cilium cilium/cilium
--version 1.15.6
--namespace kube-system
--set encryption.enabled=true
--set encryption.type=wireguard
--set encryption.nodeEncryption=true
--set kubeProxyReplacement=true
--set k8sServiceHost=localhost
--set k8sServicePort=7445
--set operator.replicas=2
--set bgpControlPlane.enabled=true
--set bpf.masquerade=true
--set ipam.mode=cluster-pool
--set ipam.operator.clusterPoolIPv4PodCIDRList=<pod_network>/16
--set ipam.operator.clusterPoolIPv4MaskSize=22
--set hubble.relay.enabled=true
--set hubble.ui.enabled=true
--set gatewayAPI.enabled=true
--set envoy.enabled=true
--set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
--set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
--set=cgroup.autoMount.enabled=false
--set=cgroup.hostRoot='/sys/fs/cgroup'
)

talosctl apply-config --insecure -n loulou.steropes.home.lab --file clusterconfig/steropes-loulou.steropes.home.lab.yaml
```

Deploy Flux

```
cd ../../../../../../
k apply -k kube/bootstrap/flux/
k apply -f kube/clusters/steropes/flux/flux-install.yaml
sops -d kube/clusters/steropes/flux/secrets-ssh.sops.yaml | k apply -f -
sops -d kube/clusters/steropes/flux/secrets-age.sops.yaml | k apply -f -
k apply -f kube/clusters/steropes/flux/flux-repo.yaml
```
