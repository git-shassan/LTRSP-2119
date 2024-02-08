# Module 6 - Install and Configure XRd on OpenShift in Public Cloud: 

|[Previous Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%205%20-%20Connecting%20Physical%20and%20Cloud%20Infrastructure/README.md)|[Main Menu](https://github.com/git-shassan/LTRSP-2119/blob/main/README.md)||
|----------------------------|----------------------------|----------------------------|

In Module #1, you had started the installation of an OpenShift cluster on AWS. This cluster would have completed its installation 
by now (normally takes around 30 mins since the time you started the installation). You can revisit the termminal window where the 
installation was run to verify the installation is completed. 

#### Switching context to OpenShift Cluster on AWS: 
Towards the end of the installation, the tool prints the location of kubeconfig file as well as kubeadmin credentials. You can always retrive that information later as well. However, for the purpose of the lab, you dont need to manually retrieve that and you can  start accessing the OpenShift cluster on AWS by altering the shell environmnet for "openshift client" 
to use this kubeconfig for subsequent commands: 
```
source ~/LTRSP-2119/scripts/ocp-aws.sh

```
> [!TIP]
> You can always switch back to the OpenShift cluster on-prem by using "source ~/LTRSP-2119/scripts/ocp-onprem.sh". 
> Similarly, to switch the context of openshift client to EKS cluster, use "source ~/LTRSP-2119/scripts/eks.sh"

#### Verifying the basic health of the cluster: 
You can run the following basic commands to verify that the cluster is in good health: 
```
oc get co

```
This command shows the state of all of the default installed clsuter operators. All the operators should be showing up as AVAIALABLE (True), and not DEGRADED (False) 
```
oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.14.7    True        False         False      3h7m    
baremetal                                  4.14.7    True        False         False      3h22m   
cloud-controller-manager                   4.14.7    True        False         False      3h25m
<snip>
```
Another command to check will be: 
```
oc get clusterversion

```
The output wil show the cluter's version and its availability: 
```
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.14.7    True        False         3h10m   Cluster version is 4.14.7

```

> [!TIP]
> If you don't see the desired output, you can check if the installation was successfully run by pasting the folloiwng commands:
> ```
> cd ~/ocpaws/
> openshift-install wait-for install-complete --dir=./ 
> ```

#### Add extra interface to the cluster node: 
By default, the installer provisioned OpenShift cluster has one interface assigned to in the public cloud environment. This is sufficent for most use cases and applications, and the traffic coming in through the interface can use kubernetes services, ingress and/or routes to be directed to the appropriate application. 

However, some applications require one or more dedicated interfaces for their use. XRd is one such application, where its data interfaces do not use the primary kubernetes interface (often referred to as "primary CNI interface"). 

To add a second interface to the openshift cluster that we have deployed in the lab, the following simple script can be run: 
```
python ~/LTRSP-2119/scripts/interface_add.py

```

You can verify that this interface was added and allocated an IP address using the following command: 
```
oc describe nodes | grep -A2 Addresses:

```
The output will look similiar to : 
```
oc describe nodes | grep -A2 Addresses:
Addresses:
  InternalIP:   10.0.16.116
  InternalIP:   10.0.11.151
```

Make a note of this new IP address in the 10.0.11.0/24 subnet. 

### Installing XRd: 
To install XRd on this OpenShift cluster, we don't need to apply the manifests one by one. Now that you are well aware of the purpose of the manifests, you can apply them in a batch using a method call "Kustomize". The following command will do that for you: 
```
cd ~
source LTRSP-2119/scripts/ocp-aws.sh
oc apply -k LTRSP-2119/manifests/xrd_ocp_onprem/
```

### Connect to the XRd router running on OpenShift in AWS: 
To connect to the router, you can now run: 
```
oc exec -it -n xrd xrd-control-plane-0 -- xr

```


|[Previous Module](https://github.com/git-shassan/LTRSP-2119/blob/main/Module%205%20-%20Connecting%20Physical%20and%20Cloud%20Infrastructure/README.md)|[Main Menu](https://github.com/git-shassan/LTRSP-2119/blob/main/README.md)||
|----------------------------|----------------------------|----------------------------|


