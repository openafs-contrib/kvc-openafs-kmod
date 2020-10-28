#!/usr/bin/env bash

function createmc() {
echo "Going to create a machine config"


cat <<EOF > mc-base.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 10-kvc-openafs-kmod
spec:
  config:
EOF

cat <<EOF > ./baseconfig.ign
{
  "ignition": { "version": "2.2.0" },
  "systemd": {
    "units": [{
      "name": "require-kvc-openafs-kmod.service",
      "enabled": true,
      "contents": "[Unit]\nRequires=kmods-via-containers@openafs-kmod.service\n[Service]\nType=oneshot\nExecStart=/usr/bin/true\n\n[Install]\nWantedBy=multi-user.target"
    }]
  }
}
EOF

yum install -y git make
FAKEROOT=$(mktemp -d)
git clone https://github.com/kmods-via-containers/kmods-via-containers
cd kmods-via-containers
make install DESTDIR=${FAKEROOT}/usr/local CONFDIR=${FAKEROOT}/etc/
cd ..
make install DESTDIR=${FAKEROOT}/usr/local CONFDIR=${FAKEROOT}/etc/
mkdir ${FAKEROOT}/var
cp ThisCell CellServDB krb5.conf  ${FAKEROOT}/var
cp cacheinfo  ${FAKEROOT}/var
tar -x -C ${FAKEROOT} -f subs.tar.gz
git clone https://github.com/ashcrow/filetranspiler
yum install -y python3
pip3 install python-magic
pip3 install file-magic
pip3 install pyyaml
sed -i 's/25/60/' ${FAKEROOT}/etc/systemd/system/kmods-via-containers\@.service
sed '/unload/ a KillMode=none' -i  ${FAKEROOT}/etc/systemd/system/kmods-via-containers\@.service
./filetranspiler/filetranspile -i ./baseconfig.ign -f ${FAKEROOT} --format=yaml --dereference-symlinks | sed 's/^/     /' | (cat mc-base.yaml -) > mc.yaml
}
createmc
