# Steps for creating environment

## Create one master and two nodes machines

### master, node1, node2
```xml
<domain type="kvm">
  <name>master</name>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <!-- I use Oracle Linux 10 but it was not available during env creation in kvm -->
      <libosinfo:os id="http://oracle.com/ol/9-unknown"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory unit="KiB">5120000</memory>
  <currentMemory unit="KiB">5120000</currentMemory>
  <vcpu placement="static">2</vcpu>
```

## Run play.yaml from main folder

- Before run you must change IP in your inventory and ssh-copy-id from your laptop to VM. __TODO__: Create static IP-s. For now I still got a long lease.
- Login to each machine and change host names respectively. __TODO__: Suse change main service for virtualization and libvirt terraform provider do not handle that well. Machines are populated from my own golden image. Terraform is not necessary in that POC because cloning is quick and VM change only once, at the creation phase. Maybe topic for future investigation. 


```bash
ansible-playbook play.yaml
```

## For HAProxy additional setting

HAProxy server is localhost so I take IP from my wifi inet. After that i put on __/etc/hosts__ file string like __192.168.0.185 grafana.local hello.local__. Local IP is my HAProxy server IP and after something hit ```grafana.local``` or ```hello.local``` HAproxy will behave based on __haproxy.cfg__ configuration file.

## Deploy 

- Go to __deploy folder__ and deploy instructions / configs from it sub-folders (1 to 4)
- Detailed instructions for every folder can be found in README.md file inside __deploy folder__
  - __Folder 1__: set up HAProxy using that configuration file
  - __Folder 2__: Install ingress controller via helm (PS. I could not use Metallab because Oracle Linux 10 do not support iptables-legacy any more).
  - __Folder 3__: apply test app
  - __Folder 4__: install monitoring stack via helm.
  - __Folder 5__: install kubernetes dashboard via deployment

  
## Result after deployment
  
```bash
  HAProxy (192.168.0.185:80 → local) 
├── grafana.local           → monitoring-grafana:30008 (NodePort)
├── https://dashboard.local → kubernetes-dashboard:30080 (Ingress)
└── http://hello.local/app  → nginx-test:30080 (Ingress)

```































