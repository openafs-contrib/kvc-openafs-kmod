## kvc-openafs-kmod - README
This is a kmods-via-containers implementation for the openafs-kmod. More information on kmod-via-container refer [here](https://github.com/kmods-via-containers/kmods-via-containers) 

- **OpenAFS specific step:**
    1. Copy ThisCell, CellServDB, krb5.conf and cacheinfo for cell inside kvc-openafs-kmod directory. On RHCOS nodes root filesystem is readonly, So afs will be mounted on /var/afs. Also cache dir is in /var/afscache. 
        While starting AFS we mount /var on host in /openafs inside container, e.g. cacheinfo will have below entry

        **cacheinfo:**
        ```sh
        /openafs/afs:/openafs/afscache:800000 
        ```
    2. Create a subscription tar as below, inside kvc-openafs-kmod directory.
        ```sh
        tar -czf subs.tar.gz /etc/pki/entitlement/ /etc/rhsm/ /etc/yum.repos.d/redhat.repo
        ```
    3. Once above steps are done run ./createmc.sh script. It will create machine config manifest i.e mc.yaml file

    4. Then apply machine config which makes machine config operator in OpenShift to install OpenAFS on all worker nodes.
         ```sh  
        oc create -f mc.yaml
        ```
    5. In case subscription changes repeat from step 2.
