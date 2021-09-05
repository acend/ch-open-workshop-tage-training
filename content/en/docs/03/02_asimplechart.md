---
title: "3.2 A simple chart"
weight: 32
sectionnumber: 3.2
---

In this lab we are going to create our very first Helm chart and deploy it.


## Task {{% param sectionnumber %}}.1: Create Chart

First, let's create our chart. Open your favorite terminal and make sure you're in the workspace for this lab, e.g. `cd ~/<workspace-helm-training>`:

```bash
helm create mychart
```

You will now find a `mychart` directory with the newly created chart. It already is a valid and fully functional chart which deploys a nginx instance. Have a look at the generated files and their content. For an explanation of the files, visit the [Helm Developer Documentation](https://docs.helm.sh/developing_charts/#the-chart-file-structure). In a later section you'll find all the information about Helm templates.

{{% onlyWhen mobi %}}
Because you cannot pull the `nginx` container image on your cluster, you have to use the `docker-registry.mobicorp.ch/puzzle/k8s/kurs/nginx` container image. Change your `values.yaml` to contain the following part:

```yaml
image:
  repository: docker-registry.mobicorp.ch/puzzle/k8s/kurs/nginx
  tag: stable
  pullPolicy: IfNotPresent
```

{{% /onlyWhen %}}
{{% onlyWhen openshift %}}
The default image the freshly created chart deploys is a simple nginx image listening on port `80`.

Since OpenShift doesn't allow to run containers as root by default, we need to change it to an unprivileged one (`nginxinc/nginx-unprivileged:latest`) and also change the containerPort to `8080`.

Change the image in the `mychart/values.yaml`:

```yaml
image:
  repository: nginxinc/nginx-unprivileged
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"
```

And then change the containerPort in the `mychart/templates/deployment.yaml`:

```yaml
ports:
- name: http
  containerPort: 8080
  protocol: TCP
```

{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.2: Install Release

Before actually deploying our generated chart, we can check the (to be) generated Kubernetes resources with the following command:


```bash
helm install --dry-run --debug --namespace <namespace> myfirstrelease ./mychart
```


Finally, the following command creates a new release and deploys the application:

```bash
helm install --namespace <namespace> myfirstrelease ./mychart
```


With `{{% param cliToolName %}} get pods --namespace <namespace>` you should see a new Pod:

```bash
NAME                                     READY   STATUS    RESTARTS   AGE
myfirstrelease-mychart-6d4956b75-ng8x4   1/1     Running   0          2m21s
```

You can list the newly created Helm release with the following command:

```bash
helm ls --namespace <namespace>
```

```
NAME            NAMESPACE       REVISION  UPDATED                                   STATUS    CHART        APP VERSION
myfirstrelease  <namespace>     1         2021-04-14 14:29:58.808282266 +0200 CEST  deployed  mychart-0.1.01.16.0  
```


## Task {{% param sectionnumber %}}.3: Expose the application

Our freshly deployed nginx is not yet accessible from outside the {{% param distroName %}} cluster.
To expose it, we have to make sure a so called ingress resource will be deployed as well.
{{% onlyWhenNot mobi %}}<!-- No TLS on mobi ingress-->
Also make sure the application is accessible via TLS.
{{% /onlyWhenNot %}}

A look into the file `templates/ingress.yaml` reveals that the rendering of the ingress and its values is configurable through values(`values.yaml`):

```yaml
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "mychart.fullname" . -}}
{{- $svcPort := .Values.service.port -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            backend:
              serviceName: {{ $fullName }}
              servicePort: {{ $svcPort }}
          {{- end }}
    {{- end }}
  {{- end }}
```

{{% onlyWhenNot mobi %}}
Thus, we need to change this value inside our `mychart/values.yaml` file. This is also where we enable the TLS part:

{{% alert title="Note" color="primary" %}}
Make sure to replace the `<namespace>` and `<appdomain>` accordingly.
{{% /alert %}}

{{% onlyWhen openshift %}}

```yaml
ingress:
  enabled: true
  annotations:
    # kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
        - path: /
  tls:
    - secretName: mychart-<namespace>-<appdomain>
      hosts:
        - mychart-<namespace>.<appdomain>
```

{{% /onlyWhen %}}
{{% onlyWhenNot openshift %}}

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
        - path: /
  tls:
    - secretName: mychart-<namespace>-<appdomain>
      hosts:
        - mychart-<namespace>.<appdomain>
```

{{% /onlyWhenNot %}}

{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
Therefore, we need to change this value inside our `values.yaml` file.

```yaml
ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: mychart-<namespace>.<appdomain>
      paths:
      - path: /
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local
```

{{% /onlyWhen %}}

{{% alert title="Note" color="primary" %}}
Make sure to set the proper value as hostname. `<appdomain>` will be provided by the trainer.
{{% onlyWhen mobi %}}
Use `mychart-<namespace>.kubedev.mobicorp.test` as your hostname. It might take some time until your ingress hostname is accessible, as the DNS name first has to be propagated correctly.
{{% /onlyWhen %}}
{{% /alert %}}

Apply the change by upgrading our release:

```bash
helm upgrade --namespace <namespace> myfirstrelease ./mychart
```

This will result in something similar to:

```
Release "myfirstrelease" has been upgraded. Happy Helming!
NAME: myfirstrelease
LAST DEPLOYED: Wed Dec  2 14:44:42 2020
NAMESPACE: <namespace>
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
  http://mychart-<namespace>.<appdomain>/
```

{{% onlyWhenNot mobi %}}
Check whether the ingress was successfully deployed by accessing the URL `http://mychart-<namespace>.<appdomain>/`

{{% onlyWhen openshift %}}
{{% alert title="Note" color="primary" %}}
It might take a moment until the app is accessible.
{{% /alert %}}
{{% /onlyWhen %}}

{{% /onlyWhenNot %}}
{{% onlyWhen mobi %}}
Check whether the ingress was successfully deployed by accessing the URL `http://mychart-<namespace>.<appdomain>/`

{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.4: Overwrite value using commandline param

An alternative way to set or overwrite values for charts we want to deploy is the `--set name=value` parameter. `--set name=value` can be used when installing a chart as well as upgrading.

Update the replica count of your nginx Deployment to 2 using `--set name=value`


### Solution Task {{% param sectionnumber %}}.4

```bash
helm upgrade --namespace <namespace> --set replicaCount=2 myfirstrelease ./mychart
```

Values that have been set using `--set` can be reset by helm upgrade with `--reset-values`.

Verify the replicaCount with the following command:


```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

```
NAME                                     READY   STATUS    RESTARTS   AGE
myfirstrelease-mychart-c95cb97d6-g76rc   1/1     Running   0          10m
myfirstrelease-mychart-c95cb97d6-tqztc   1/1     Running   0          8m25s
```


## Task {{% param sectionnumber %}}.5: Rollback a release

Helm also provides the functionality to roll back a release to a specific revision number.
In the previous tasks, you might have noticed the `REVISION` be increased each time you installed or updated a release.

Every change you make to a release by installing or upgrading it will increase the `REVISION`. The actual deployed revision can be displayed with the following command:

```bash
helm ls --namespace <namespace>
```

```
NAME            NAMESPACE       REVISION  UPDATED                                   STATUS    CHART        APP VERSION
myfirstrelease  <namespace>     3         2021-04-14 14:29:58.808282266 +0200 CEST  deployed  mychart-0.1.01.16.0  
```

Let's now rollback our release `myfirstrelease` to revision 2.

```bash
helm rollback myfirstrelease 2 --namespace <namespace>
```

The replicaCount should be back down to 1 after the rollback. Check if that's true with the following command:

```bash
{{% param cliToolName %}} get pods --namespace <namespace>
```

```
NAME                                     READY   STATUS    RESTARTS   AGE
myfirstrelease-mychart-c95cb97d6-g76rc   1/1     Running   0          10m
```


## Task {{% param sectionnumber %}}.6 Explore values.yaml

Have a look at the `values.yaml` file in your chart and study all the possible configuration params introduced in a freshly created chart.


## Task {{% param sectionnumber %}}.7: Remove release

To remove an application, simply remove the Helm release with the following command:

```bash
helm uninstall myfirstrelease --namespace <namespace>
```

Do this with our deployed release. With `{{% param cliToolName %}} get pods --namespace <namespace>` you should no longer see your application Pod.
