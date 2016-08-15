#cloud-config

---
write-files:
  - path: /opt/bin/wupiao
    permissions: '0755'
    content: |
      #!/bin/bash
      # [w]ait [u]ntil [p]ort [i]s [a]ctually [o]pen
      [ -n "$1" ] && \
        until curl -o /dev/null -sIf http://$${1}; do \
          sleep 1 && echo .;
        done;
      exit $?
  - path: /opt/bin/get_secrets.sh
    permissions: 0755
    content: |
      #!/bin/bash
      cd /opt/bin/
      wget https://storage.googleapis.com/kubernetes-release/release/v1.3.5/bin/linux/amd64/kubectl

      chmod +x kubectl
      cd /opt/
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret auth -o go-template='{{index .data "auth-policy.json"}}' | /usr/bin/base64 -d > /opt/auth-policy.json
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret ca.pem -o go-template='{{index .data "ca.pem"}}' | /usr/bin/base64 -d > /opt/ca.pem
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret kube-serviceaccount.key -o go-template='{{index .data "kube-serviceaccount.key"}}' | /usr/bin/base64 -d > /opt/kube-serviceaccount.key
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret kubernetes-key.pem -o go-template='{{index .data "kubernetes-key.pem"}}' | /usr/bin/base64 -d > /opt/kubernetes-key.pem
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret kubernetes.pem -o go-template='{{index .data "kubernetes.pem"}}' | /usr/bin/base64 -d > /opt/kubernetes.pem
      /opt/bin/kubectl --namespace=sub-cluster1 --kubeconfig=/opt/host-kubeconfig get secret tokens -o go-template='{{index .data "tokens.csv"}}'  | /usr/bin/base64 -d > /opt/tokens.csv
  - path: /opt/host-kubeconfig
    permissions: 0755
    content: |
      apiVersion: v1
      kind: Config
      clusters:
      - cluster:
          server: ${hostclustername}
          insecure-skip-tls-verify: true
        name: host-cluster
      contexts:
      - context:
          cluster: host-cluster
          user: sub-cluster1
        name: sub-cluster1
      current-context: sub-cluster1
      users:
        - name: sub-cluster1
          user:
            token: ${host_account_token}
coreos:
  fleet:
    metadata: "role=master"
  etcd2:
    advertise-client-urls: "http://$private_ipv4:2379"
    listen-client-urls: "http://0.0.0.0:2379"
  units:
    - name: etcd2.service
      command: start
    - name: get-secrets.service
      command: start
      content: |
        [Unit]
        Description=Get from host-cluster
        Requires=network-online.target
        After=network-online.target

        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStart=/opt/bin/get_secrets.sh
        RemainAfterExit=yes
        Type=oneshot
    - name: setup-network-environment.service
      command: start
      content: |
        [Unit]
        Description=Setup Network Environment
        Documentation=https://github.com/kelseyhightower/setup-network-environment
        Requires=network-online.target
        After=network-online.target

        [Service]
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStartPre=/usr/bin/curl -L -o /opt/bin/setup-network-environment -z /opt/bin/setup-network-environment https://github.com/kelseyhightower/setup-network-environment/releases/download/v1.0.0/setup-network-environment
        ExecStartPre=/usr/bin/chmod +x /opt/bin/setup-network-environment
        ExecStart=/opt/bin/setup-network-environment
        RemainAfterExit=yes
        Type=oneshot
    - name: flanneld.service
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Service]
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{"Network":"10.192.0.0/16", "Backend": {"Type": "vxlan"}}'
    - name: docker.service
      command: start
    - name: kube-apiserver.service
      command: start
      content: |
        [Unit]
        Description=Kubernetes API Server
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=setup-network-environment.service 
        After=setup-network-environment.service 

        [Service]
        EnvironmentFile=/etc/network-environment
        ExecStartPre=-/usr/bin/mkdir -p /opt/bin
        ExecStartPre=/usr/bin/curl -L -o /opt/bin/kube-apiserver -z /opt/bin/kube-apiserver ${kube-apiserver-binary}
        ExecStartPre=/usr/bin/chmod +x /opt/bin/kube-apiserver
        ExecStartPre=/opt/bin/wupiao 127.0.0.1:2379/v2/machines
        ExecStart=/opt/bin/kube-apiserver \
          --service-account-key-file=/opt/kube-serviceaccount.key \
          --service-account-lookup=false \
          --admission-control=NamespaceLifecycle,NamespaceAutoProvision,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
          --authorization-mode=ABAC \
          --authorization-policy-file=/opt/auth-policy.json \
          --token-auth-file=/opt/tokens.csv \
          --allow-privileged=true \
          --insecure-bind-address=0.0.0.0 \
          --bind-address=0.0.0.0 \
          --insecure-port=8080 \
          --kubelet-https=true \
          --secure-port=6443 \
          --tls-cert-file="/opt/kubernetes.pem" \
          --tls-private-key-file="/opt/kubernetes-key.pem" \
          --client-ca-file="/opt/ca.pem" \
          --service-cluster-ip-range=10.100.0.0/16 \
          --etcd-servers=http://127.0.0.1:2379 \
          --v=2 \
          --logtostderr=true
        Restart=always
        RestartSec=10
    - name: kube-controller-manager.service
      command: start
      content: |
        [Unit]
        Description=Kubernetes Controller Manager
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=kube-apiserver.service
        After=kube-apiserver.service

        [Service]
        EnvironmentFile=/etc/network-environment
        ExecStartPre=/usr/bin/curl -L -o /opt/bin/kube-controller-manager -z /opt/bin/kube-controller-manager ${kube-controller-manager-binary}
        ExecStartPre=/usr/bin/chmod +x /opt/bin/kube-controller-manager
        ExecStart=/opt/bin/kube-controller-manager \
          --service-account-private-key-file=/opt/kube-serviceaccount.key \
          --root-ca-file=/opt/ca.pem \
          --master=$${DEFAULT_IPV4}:8080 \
          --cluster-name=k8s \
          --logtostderr=true \
          --v=2
        Restart=always
        RestartSec=10
    - name: kube-scheduler.service
      command: start
      content: |
        [Unit]
        Description=Kubernetes Scheduler
        Documentation=https://github.com/kubernetes/kubernetes
        Requires=kube-apiserver.service
        After=kube-apiserver.service

        [Service]
        EnvironmentFile=/etc/network-environment
        ExecStartPre=/usr/bin/curl -L -o /opt/bin/kube-scheduler -z /opt/bin/kube-scheduler ${kube-scheduler-binary}
        ExecStartPre=/usr/bin/chmod +x /opt/bin/kube-scheduler
        ExecStart=/opt/bin/kube-scheduler \
          --master=$${DEFAULT_IPV4}:8080 \
          --v=2
        Restart=always
        RestartSec=10
  update:
    group: alpha
    reboot-strategy: off
