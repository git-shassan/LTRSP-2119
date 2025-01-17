# Module 2 - XRd on OpenShift OnPrem
|[Previous Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%201%20-%20Setup%20Environment/README.md)|[Main Menu](https://github.com/git-shassan/LTRSP-2119/blob/main/README.md)|[Next Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%203%20-%20XRd%20on%20EKS/README.md)|
|----------------------------|----------------------------|----------------------------|



In this module, you will install XRd virtual router on an OpenShift cluster that is running on-prem / private cloud infrastructure. 
This OpenShift cluster has already been installed in the lab environment. Furhter, to save lab time, the cluster's parameters have been fine tuned to meet the requirements for XRd vRouter. 

### Setting up the jump host environment to access OpenShift Cluster: 
To connect to and communicate with an OpenShift cluster, the "OpenShift Client" (oc) applicaiton is used. 
This can be installed using the following simple steps: 

```
cd ~
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.14.9/openshift-client-linux-4.14.9.tar.gz
tar -xvf openshift-client-linux-4.14.9.tar.gz
mv -f oc /usr/bin/
mv -f kubectl /usr/bin/

```
This will extract the binaries "oc" and "kubectl". Only "oc" client is sufficent for our usage, and the above commands move that into "/usr/bin" to make it gloabally 

The "oc" binary supports autocompletion, that can be helpful in completing commands using TAB. To enable autocompletion, use the following set of commands: 
```
oc completion bash > oc.bash
source oc.bash
sudo mv oc.bash /etc/bash_completion.d/

```
### Setting up the OpenShift Node to use VFIO-PCI drivers:
XRd vRouter requires that vfio-pci drivers should be enabled in the host's kernel. By 
default, OpenShift doesn't enable this, but it can be enabled with a simple step. 

Before we enable it, lets check the current state of vfio-pci Kernel module on the OpenShift node. 
```
source LTRSP-2119/scripts/ocp-onprem.sh
oc debug node/$(oc get nodes -ojsonpath='{.items[].metadata.name}') -- chroot /host /bin/bash -c 'echo ============; lsmod | grep vfio; echo ============'

```
The output would show an empty list, as below: 
```
Starting pod/00-50-56-11-88-33-debug-9pnhw ...
To use host binaries, run `chroot /host`
============
============

Removing debug pod ...
```

As expected, this command didn't show any vfio-pci module enabled. Now, to enable the module, use the following command: 
```
oc debug node/$(oc get nodes -ojsonpath='{.items[].metadata.name}') -- chroot /host /bin/bash -c 'echo ============; modprobe vfio-pci ; echo ============'

```

The output will still show it empty, this is default behaviour, ignore it and more forward with the lab.

Now, if you recheck the presense of this module, using the same command that was used earlier, i.e: 
```
oc debug node/$(oc get nodes -ojsonpath='{.items[].metadata.name}') -- chroot /host /bin/bash -c 'echo ============; lsmod | grep vfio; echo ============'

```
...you will not see an empty list like before. Rather, you will see the following:
```
Starting pod/00-50-56-11-88-33-debug-bnmvb ...
To use host binaries, run `chroot /host`
============
vfio_pci               16384  0
vfio_pci_core          69632  1 vfio_pci
vfio_virqfd            16384  1 vfio_pci_core
vfio_iommu_type1       49152  0
vfio                   45056  2 vfio_pci_core,vfio_iommu_type1
irqbypass              16384  2 vfio_pci_core,kvm
============

Removing debug pod ...
```

Use of VFIO-PCI drivers is now enabled, and you can proceed with installing XRd vRouter. 

### Create Service Account

```
cd ~/LTRSP-2119/manifests/xrd_ocp_onprem
oc apply -f sa.yaml

```
The output should look like: 
```
serviceaccount/xrd-sa created
```
You can verify that the service account is created using the following command: 
```
oc get sa -n xrd
```
Output:
```
NAME       SECRETS   AGE
builder    1         3h24m
default    1         3h24m
deployer   1         3h24m
*xrd-sa     1         10s*
```

### Create the role binding for authorization: 
```
oc apply -f role.yaml

```
The output should look like: 
```
clusterrolebinding.rbac.authorization.k8s.io/system:openshift:scc:privileged created
```
The creation of the role brinding between a privilaged role, and the service account can be verified by the following command: 
```
oc get clusterrolebindings.rbac.authorization.k8s.io -o wide | grep xrd
```
Output:
```
*system:openshift:scc:privileged*                                           ClusterRole/system:openshift:scc:privileged        
                                     26s                                                                                       
                            *xrd/xrd-sa*
```

### Create Config Map:
The pre-defined config map can be viewed using the following: 
```
cat configmap.yaml
```

The output should look like this: 
```
 apiVersion: v1
kind: ConfigMap
metadata:
  name: xrd-control-plane-config
  namespace: xrd
  annotations:

  labels:
    helm.sh/chart: xrd-control-plane-1.0.1
    app.kubernetes.io/name: xrd-control-plane
    app.kubernetes.io/instance: release-name
    app.kubernetes.io/version: "7.8.1"
data:
  startup.cfg: |
    hostname XRd5
    username cisco
     group root-lr
     group cisco-support
     password cisco123
    interface Loopback0
     ipv4 address 1.0.0.5 255.255.255.255
    interface TenGigE0/0/0/0
     ipv4 address 198.18.1.11 255.255.255.0
     no shut
```
As may be obvious from the above, this contains the configuration for XRd that will serve as the startup configuration. This config map can be pushed to the OpenShift cluster using the following: 
```
oc apply -f configmap.yaml

```
The creation of the config map can be verified using:  
```
oc get cm -n xrd | grep xrd
```
Output:
```
*xrd-vrouter-config         1      13s*
```
### Create the stateful set to deploy XRd pods: 
Use the following command to create the stateful set, that will result in creation of XRd pods and getting deployed: 
```
oc apply -f statefulset.yaml

```
The output should look like: 
```
statefulset.apps/xrd-vrouter created
```

You can now verify that the stateful set creastion was successful using the following: 
```
oc get statefulsets.apps -n xrd
```
Output (It might take a few minutes for it to get Ready:
```
NAME          READY   AGE
xrd-vrouter   1/1     37s
```
### Verifying XRd is running:
At this point, XRd POD should be up and running. This can be verified using the following:
```
oc get pods -n xrd
```
Output:
```
NAME            READY   STATUS    RESTARTS   AGE
xrd-vrouter-0   1/1     Running   0          43s
```

### Connecting to XRd vRouter:
The following OpenShift command can be used to connect to XRd and run the command "xr" on it. This would take you directly to the familiar XR command shell:
```
oc exec -it -n xrd xrd-vrouter-0 -- xr

```

> [!Note]
>  It will take ~90 secs for XRd to boot and be ready to accept login credentials

The output would like the following. Here you can login using "cisco" as username and "cisco123" as password:
```
User Access Verification

Username: cisco
Password: 


RP/0/RP0/CPU0:XRd5#show ip int br
Mon Feb  5 16:31:01.730 UTC

Interface                      IP-Address      Status          Protocol Vrf-Name
Loopback0                      1.0.0.5         Up              Up       default 
```

### Configure XRd external facing intercace and static route:
Use the folliwng config snippet to configure XRd's TenGigE interface. This interface maps to the OpenShift inteface that is connected to the internet.
```
configure terminal
interface TenGigE0/0/0/0
 ipv4 address 198.18.1.11 255.255.255.0
 no shutdown
!
router static
 address-family ipv4 unicast
  0.0.0.0/0 TenGigE0/0/0/0 198.18.1.1
 !
commit
end

```
>[!TIP]
> Don't forget to "commit" the new configuration after applying it

Following example shows applying this configuration:
```
RP/0/RP0/CPU0:XRd5#conf t
Mon Feb  5 16:32:23.091 UTC
RP/0/RP0/CPU0:XRd5(config)#int gigabitEthernet 0/0/0/0
RP/0/RP0/CPU0:XRd5(config)#int tenGigE 0/0/0/0 
RP/0/RP0/CPU0:XRd5(config-if)#ipv4 add 198.18.1.11 255.255.255.0    
RP/0/RP0/CPU0:XRd5(config-if)#no shut
RP/0/RP0/CPU0:XRd5(config-if)#exit
RRP/0/RP0/CPU0:XRd5(config)#router static 
RP/0/RP0/CPU0:XRd5(config-static)#address-family ipv4 unicast 
RP/0/RP0/CPU0:XRd5(config-static-afi)#0.0.0.0/0 198.18.1.1 tenGigE 0/0/0/0
*RP/0/RP0/CPU0:XRd5(config-static-afi)#commit*
RP/0/RP0/CPU0:XRd5(config-static-afi)#end
```
You shall now be able to ping servers on the internet. For example:
```
RP/0/RP0/CPU0:XRd5#ping 8.8.8.8          
Mon Feb  5 16:50:03.837 UTC
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 8.8.8.8 timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 10/10/12 ms
RP/0/RP0/CPU0:XRd5#
```

**That was easy!!!! You've just instantiated an XRd Instance on Red Hat OpenShift on your private, on-prem environment**  

Do not log out of the XRd5, rather Open a new Linux tab by clicking on the "+" sign on the top left corder of the linux terminal. 

Move on to Module 3.

|[Previous Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%201%20-%20Setup%20Environment/README.md)|[Main Menu](https://github.com/git-shassan/LTRSP-2119/blob/main/README.md)|[Next Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%203%20-%20XRd%20on%20EKS/README.md)|
|----------------------------|----------------------------|----------------------------|
