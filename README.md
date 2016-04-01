## Persistent NFS volumes in Kubernetes.

__Volumes, provided by NFS server and which can be retained and used by different containers in Kubernetes cluster.__

_Tested on Ubuntu 14.04_

Persistent Volumes [documentation](http://kubernetes.io/docs/user-guide/persistent-volumes/)

Familiarity with [volumes](http://kubernetes.io/docs/user-guide/volumes/) is suggested.

----
###### Variables in the text:
nfs-server-IP=198.18.11.3<br/>
nfs-persistent-volume-name=nfsvol
----
#### 1. Prepare NFS infrastructure
##### NFS server
###### Nodes assigned as NFS storage providers must have nfs-kernel-server installed:
```bash
sudo apt-get install nfs-kernel-server
```
###### Create or assign folders for storage:
```bash
sudo mkdir -p /export/<nfs-persistent-volume-name>
sudo chmod -R 777 /export
```

###### There are three configuration files that relate to an NFS server:
/etc/default/nfs-kernel-server
/etc/default/nfs-common
/etc/exports

Leave untouched /etc/default/nfs-kernel-server

Add or edit next lines in /etc/default/nfs-common:
```
# Do you want to start the statd daemon? It is not needed for NFSv4.
NEED_STATD="no"

# Do you want to start the idmapd daemon? It is only needed for NFSv4.
NEED_IDMAPD="yes"
```

Edit /etc/exports file
\( \* means - all, so for the security reasons you may change \(\*\) to exact IP addresses or network range\):
```
/export/<nfs-persistent-volume-name>  *(rw,nohide,insecure,no_root_squash,no_subtree_check,sync)
```

In order for the ID names to be automatically mapped, both the client and server require the `/etc/idmapd.conf` file to have the same contents with the correct domain names. Furthermore, this file should have the following lines in the `Mapping` section:
```
[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup
```
This way, server and client do not need the users to share same UID/GUID.

###### Start the service
```bash
service nfs-kernel-server restart
```

##### NFS client
###### Install the required packages:
```bash
sudo apt-get install nfs-common
```

Check nfs mount from all of clients \(cluster nodes\):
```bash
sudo mount -t nfs -o proto=tcp,port=2049 <nfs-server-IP>:/export/<nfs-persistent-volume-name> /mnt
```
Now your node is ready to host the containers that could claim nfs volumes.

#### 2. Create pod and service with persistent volume claims
###### Create pod:
```bash
kubectl create -f kube/nfs-pod.yaml
```
Check pod's status with:
```bash
kubectl get pods
```
or, more informative:
```bash
kubectl describe pods <nfs-persistent-volume-name>
```

###### Create service:
```bash
kubectl create -f kube/nfs-service.yaml
```
Check service status with:
```bash
kubectl get svc
```
or with:
```bash
kubectl describe svc <nfs-persistent-volume-name>
```
#### 3. Check volume status
###### Get host IP where the container has started:
```bash
kubectl get pod <nfs-persistent-volume-name> -o=yaml | grep nodeName
```
###### Connect to host where container is:
```bash
ssh -l vcap $(kubectl get pod <nfs-persistent-volume-name> -o=yaml | grep nodeName | awk '{print $2}')
```

###### Connect to container:
```bash
sudo docker exec -it $(sudo docker ps | grep dockervol | awk '{print $1}') bash
```

###### Check mounted persistent volume status:
```bash
mount | grep nfs
```
Everything is fine if this command output looks like:
```
198.18.11.3:/export/nfsvol on /mnt type nfs4 (rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=198.18.8.161,local_lock=none,addr=198.18.11.3)
```

Additionally you may cd to /mnt folder and test read and write capabilities:
```bash
cd /mnt
touch some.tex
echo '1234567890' > some.tex
cat some.tex
rm -f some.txt
```
